import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';
import '../home/home_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading       = false;
  bool _obscure       = true;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.login({
        'email': _emailCtrl.text.trim(),
        'password': _passwordCtrl.text,
      });
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        await ApiService.saveToken(body['token']);
        if (!mounted) return;
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomeShell()));
      } else {
        _showError(body['message'] ?? 'Login gagal');
      }
    } catch (e) {
      _showError('Tidak dapat terhubung ke server');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header area ----
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo placeholder — ganti dengan Image.asset jika gambar sudah ada
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield, color: Colors.white, size: 44),
                    ),
                    const SizedBox(height: 16),
                    const Text('SecureMe',
                      style: TextStyle(
                        color: Colors.white, fontSize: 32,
                        fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text('Lindungi diri Anda, laporkan kekerasan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75), fontSize: 14)),
                  ],
                ),
              ),
            ),

            // ---- Form area ----
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: const BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Masuk',
                        style: TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                      const SizedBox(height: 24),

                      _buildField('Email', _emailCtrl,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildField('Password', _passwordCtrl,
                        icon: Icons.lock_outline,
                        obscure: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                            color: AppColors.textMuted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        )),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Masuk',
                                style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const RegisterPage())),
                          child: RichText(
                            text: TextSpan(
                              text: 'Belum punya akun? ',
                              style: const TextStyle(color: AppColors.textMuted),
                              children: [
                                TextSpan(text: 'Daftar Sekarang',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {IconData? icon,
      bool obscure = false,
      TextInputType? keyboardType,
      Widget? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: AppColors.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: icon != null
              ? Icon(icon, color: AppColors.textMuted, size: 20) : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}