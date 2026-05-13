import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_strings.dart';

class ApiService {
  static final _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // AUTH
  static Future<http.Response> register(Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('${AppStrings.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> login(Map<String, dynamic> body) async {
    return http.post(
      Uri.parse('${AppStrings.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  // PANIC
  static Future<http.Response> triggerPanic(double lat, double lng) async {
    final headers = await _authHeaders();
    return http.post(
      Uri.parse('${AppStrings.baseUrl}/panic/trigger'),
      headers: headers,
      body: jsonEncode({'latitude': lat, 'longitude': lng}),
    );
  }

  // REPORTS
  static Future<http.Response> createReport(Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    return http.post(
      Uri.parse('${AppStrings.baseUrl}/reports'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> getMyReports() async {
    final headers = await _authHeaders();
    return http.get(
      Uri.parse('${AppStrings.baseUrl}/reports/my'),
      headers: headers,
    );
  }
}