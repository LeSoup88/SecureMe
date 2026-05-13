import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://sdysppbphuudsyaanlhm.supabase.co/rest/v1/',   // Ganti dengan URL Supabase Anda
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkeXNwcGJwaHV1ZHN5YWFubGhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1NTc2NTAsImV4cCI6MjA5NDEzMzY1MH0.8XWlsiJtlv-MjuL5sGl8xZmIqZb4koiUXdmc0k3Pr2E',  // Ganti dengan anon key Supabase Anda
  );

  runApp(const SecureMeApp());
}