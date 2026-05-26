import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ── AUTH USER ─────────────────────────────────────────

  static Future<void> logout() async {
    await client.auth.signOut();
  }

  // ── AUTH ADMIN ────────────────────────────────────────

  static Future<Map<String, dynamic>?> loginAdmin({
  required String email,
  required String password,
}) async {
  print('=== ADMIN LOGIN ===');
  print('Email: $email');

  try {
    final response = await client
        .from('admins')
        .select()
        .eq('email', email)
        .eq('password_hash', password)
        .maybeSingle();

    print('Admin login result: $response');

    if (response == null) {
      print('Admin not found');
      return null;
    }

    return Map<String, dynamic>.from(response);
  } catch (e) {
    print('Admin login error: $e');
    return null;
  }
}

  // ── REPORTS (USER) ────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMyReports() async {
    final userId = currentUser?.id;
    print('=== GET MY REPORTS ===');
    print('Current user ID: $userId');

    if (userId == null) return [];

    try {
      final response = await client
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      final filtered = (response as List)
          .where((r) => r['user_id'] == userId || r['user_id'] == null)
          .toList();

      print('Filtered reports: ${filtered.length}');
      return List<Map<String, dynamic>>.from(filtered);
    } catch (e) {
      print('Error fetching reports: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createReport({
    required String type,
    required String location,
    required String description,
    required bool isAnonymous,
    String? evidenceUrl,
  }) async {
    final userId = currentUser?.id;
    print('=== CREATE REPORT ===');
    print('User ID: $userId');

    try {
      final response = await client.from('reports').insert({
        'user_id': isAnonymous ? null : userId,
        'type': type,
        'location': location,
        'description': description,
        'is_anonymous': isAnonymous,
        'evidence_url': evidenceUrl,
        'source': 'Form Laporan',
        'status': 'Belum Ditangani',
        'reported_by': isAnonymous ? 'Anonim' : 'Identitas Terlampir',
      }).select().single();

      print('Report created: ${response['id']}');
      return response;
    } catch (e) {
      print('Error creating report: $e');
      rethrow;
    }
  }

  // ── REPORTS (ADMIN) ───────────────────────────────────

  static Future<List<Map<String, dynamic>>> getAllReports() async {
    print('=== GET ALL REPORTS (ADMIN) ===');
    try {
      final response = await client
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      print('Total reports: ${response.length}');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all reports: $e');
      rethrow;
    }
  }

  static Future<void> updateReportStatus({
    required String reportId,
    required String status,
  }) async {
    print('=== UPDATE REPORT STATUS ===');
    print('Report ID: $reportId, Status: $status');

    try {
      await client
          .from('reports')
          .update({'status': status})
          .eq('id', reportId);
      print('Status updated');
    } catch (e) {
      print('Error updating status: $e');
      rethrow;
    }
  }

  // ── PANIC ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> triggerPanic({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    final userId = currentUser?.id;
    print('=== TRIGGER PANIC ===');
    print('User ID: $userId');
    print('Lat: $latitude, Lng: $longitude');

    if (userId == null) {
      throw Exception('User tidak terautentikasi');
    }

    final response = await client.from('reports').insert({
      'user_id': userId,
      'type': 'Darurat',
      'location': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'description':
          'Pengguna menekan tombol PANIK dan membutuhkan bantuan segera.',
      'is_anonymous': false,
      'source': 'Panic Button',
      'status': 'Belum Ditangani',
      'reported_by': 'Identitas Terlampir',
    }).select().single();

    print('Panic report created: ${response['id']}');

    try {
      await client.from('location_tracking').insert({
        'user_id': userId,
        'report_id': response['id'],
        'latitude': latitude,
        'longitude': longitude,
      });
      print('Location tracking saved');
    } catch (e) {
      print('Location tracking error (non-fatal): $e');
    }

    return response;
  }

  static Future<void> updateLocation({
    required String reportId,
    required double latitude,
    required double longitude,
  }) async {
    final userId = currentUser?.id;
    await client.from('location_tracking').insert({
      'user_id': userId,
      'report_id': reportId,
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}