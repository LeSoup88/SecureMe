import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ── AUTH ──────────────────────────────────────────────

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
    );
    return response;
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  static Future<void> logout() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ── REPORTS ───────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMyReports() async {
    final userId = currentUser?.id;
    print('=== GET MY REPORTS ===');
    print('Current user ID: $userId');

    if (userId == null) {
      print('User ID null, return empty');
      return [];
    }

    try {
      // Ambil semua laporan — baik yang ber-user_id maupun anonim
      // yang dibuat dalam sesi ini (kita ambil semua lalu filter di client)
      final response = await client
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      print('Total reports from DB: ${response.length}');

      // Filter di sisi client: tampilkan laporan milik user ini
      // atau laporan anonim yang ada di database
      final filtered = (response as List)
          .where((r) =>
              r['user_id'] == userId ||
              r['user_id'] == null)
          .toList();

      print('Filtered reports for user: ${filtered.length}');
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
    print('Type: $type, Anonymous: $isAnonymous');

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
      }).select().single();

      print('Report created successfully: ${response['id']}');
      return response;
    } catch (e) {
      print('Error creating report: $e');
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
      throw Exception('User tidak terautentikasi. Silakan login ulang.');
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