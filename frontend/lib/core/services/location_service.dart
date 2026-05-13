import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    print('=== GET CURRENT LOCATION ===');

    // Cek apakah GPS service aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('GPS service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      print('GPS service tidak aktif');
      return null;
    }

    // Cek permission
    LocationPermission permission = await Geolocator.checkPermission();
    print('Current permission: $permission');

    if (permission == LocationPermission.denied) {
      print('Permission denied, meminta permission...');
      permission = await Geolocator.requestPermission();
      print('Permission setelah request: $permission');
      if (permission == LocationPermission.denied) {
        print('Permission tetap denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permission denied forever');
      return null;
    }

    print('Permission OK, mengambil posisi...');

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 15));
      print('Position didapat: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error ambil posisi: $e');

      // Coba ambil posisi terakhir yang diketahui sebagai fallback
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        print('Pakai last known position: $lastKnown');
        return lastKnown;
      } catch (_) {
        return null;
      }
    }
  }

  static Future<String?> reverseGeocode(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'SecureMeApp/1.0'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}