import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../home/home_shell.dart';
import '../admin/admin_login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PortalPage extends StatelessWidget {
  const PortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 32),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ---- Logo Placeholder ----
                // Ganti AssetImage di bawah dengan logo kamu
                // Letakkan file gambar di: frontend/assets/images/logo.png
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildLogo(),
                  ),
                ),
                const SizedBox(height: 24),

                // ---- Title ----
                const Text(
                  'SecureMe',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lindungi diri Anda,\nlaporkan kekerasan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // ---- Card Pilihan ----
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masuk sebagai',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---- Tombol Pengguna ----
                      _PortalButton(
                        icon: Icons.person_rounded,
                        label: 'Pengguna',
                        subtitle: 'Akses fitur pelaporan dan darurat',
                        color: AppColors.accent,
                        onTap: () async {
                          // Simpan session ID lama secara manual (hapus setelah sekali jalan)
                          final prefs = await SharedPreferences.getInstance();
                          final allIds = prefs.getStringList('all_session_ids') ?? [];
                            final oldIds = [
                              'a4537231-2757-43ca-8b33-5a1ee3e30721',
                              '31f406f7-a645-4784-a773-48e1f8459e2b',
                            ];
                            for (final id in oldIds) {
                              if (!allIds.contains(id)) allIds.add(id);
                            }
                          await prefs.setStringList('all_session_ids', allIds);

                          await SupabaseService.ensureSession();
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeShell()),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // ---- Tombol Admin ----
                      _PortalButton(
                        icon: Icons.admin_panel_settings_rounded,
                        label: 'Admin',
                        subtitle: 'Kelola dan pantau laporan masuk',
                        color: AppColors.primaryDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminLoginPage()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ---- Info keamanan ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Data Anda dilindungi dan aman',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'SecureMe v1.0.0',
                  style: TextStyle(
                    color: AppColors.textMuted.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    // Cek apakah file logo sudah ada di assets
    // Jika sudah ada, tampilkan gambar
    // Jika belum, tampilkan placeholder icon
    try {
      return Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Placeholder jika gambar belum ada
          return Container(
            color: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.shield_rounded,
              color: AppColors.primary,
              size: 56,
            ),
          );
        },
      );
    } catch (_) {
      return Container(
        color: AppColors.primary.withOpacity(0.1),
        child: Icon(
          Icons.shield_rounded,
          color: AppColors.primary,
          size: 56,
        ),
      );
    }
  }
}

// ── Portal Button Widget ──────────────────────────────────────────────────────

class _PortalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PortalButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withOpacity(0.5), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}