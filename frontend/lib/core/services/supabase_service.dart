import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;

  // ── SESSION ───────────────────────────────────────────

  static Future<String> ensureSession() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> allSessionIds = prefs.getStringList('all_session_ids') ?? [];

  if (currentUser != null) {
    print('Supabase session exists: ${currentUser!.id}');
    if (!allSessionIds.contains(currentUser!.id)) {
      allSessionIds.add(currentUser!.id);
      await prefs.setStringList('all_session_ids', allSessionIds);
    }
    await prefs.setString('user_session_id', currentUser!.id);
    return currentUser!.id;
  }

  try {
    print('Creating anonymous session...');
    final res = await client.auth.signInAnonymously();
    if (res.user != null) {
      print('Anonymous session created: ${res.user!.id}');
      if (!allSessionIds.contains(res.user!.id)) {
        allSessionIds.add(res.user!.id);
        await prefs.setStringList('all_session_ids', allSessionIds);
      }
      await prefs.setString('user_session_id', res.user!.id);
      return res.user!.id;
    }
  } catch (e) {
    print('signInAnonymously error: $e');
  }

  // Fallback: pakai saved ID
  String? savedId = prefs.getString('user_session_id');
  if (savedId != null) {
    print('Using saved session ID: $savedId');
    return savedId;
  }

  // Last resort
  final newId = 'user-${DateTime.now().millisecondsSinceEpoch}';
  allSessionIds.add(newId);
  await prefs.setStringList('all_session_ids', allSessionIds);
  await prefs.setString('user_session_id', newId);
  print('Created new fallback ID: $newId');
  return newId;
}

  static Future<String?> getSavedSessionId() async {
    // Prioritas: Supabase auth user
    if (currentUser != null) return currentUser!.id;

    // Fallback: SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_session_id');
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
      if (response == null) return null;
      return Map<String, dynamic>.from(response);
    } catch (e) {
      print('Admin login error: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    await client.auth.signOut();
  }

  // ── REPORTS (USER) ────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMyReports() async {
  final userId = await getSavedSessionId();
  print('=== GET MY REPORTS ===');
  print('User ID: $userId');

  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> allSessionIds =
        prefs.getStringList('all_session_ids') ?? [];

    if (userId != null && !allSessionIds.contains(userId)) {
      allSessionIds.add(userId);
      await prefs.setStringList('all_session_ids', allSessionIds);
    }

    print('All session IDs: $allSessionIds');

    // Fetch semua laporan
    final response = await client
        .from('reports')
        .select()
        .order('created_at', ascending: false);

    print('Total reports in DB: ${response.length}');

    // Tampilkan semua laporan yang:
    // 1. user_id cocok dengan salah satu session ID
    // 2. ATAU user_id null (laporan anonim)
    final filtered = (response as List).where((r) {
      final reportUserId = r['user_id'];
      if (reportUserId == null) return true; // tampilkan laporan anonim
      return allSessionIds.contains(reportUserId);
    }).toList();

    print('Reports fetched: ${filtered.length}');
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
    final userId = await ensureSession();
    print('=== CREATE REPORT ===');
    print('User ID: $userId, Anonymous: $isAnonymous');

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
      print('Status updated successfully');
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
    final userId = await ensureSession();
    print('=== TRIGGER PANIC ===');
    print('User ID: $userId');
    print('Lat: $latitude, Lng: $longitude');
    print('Location: $locationName');

    try {
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
    } catch (e) {
      print('Panic error: $e');
      rethrow;
    }
  }

  static Future<void> updateLocation({
    required String reportId,
    required double latitude,
    required double longitude,
  }) async {
    final userId = currentUser?.id;
    try {
      await client.from('location_tracking').insert({
        'user_id': userId,
        'report_id': reportId,
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      print('Update location error: $e');
    }
  }
}