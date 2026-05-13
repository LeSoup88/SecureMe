import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  static const _articles = [
    {
      'title': 'Mengenal Jenis Kekerasan',
      'desc': 'Pahami perbedaan kekerasan fisik, psikis, dan seksual menurut hukum Indonesia.',
      'icon': Icons.info_outline_rounded,
      'color': AppColors.info,
    },
    {
      'title': 'Langkah Hukum yang Bisa Ditempuh',
      'desc': 'Prosedur melaporkan ke polisi, mendapat surat visum, dan mencari bantuan hukum.',
      'icon': Icons.gavel_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Layanan Konseling Gratis',
      'desc': 'Daftar lembaga yang menyediakan konseling psikologis dan pendampingan hukum gratis.',
      'icon': Icons.support_agent_rounded,
      'color': AppColors.success,
    },
    {
      'title': 'Hak-Hak Korban',
      'desc': 'Ketahui hak Anda sebagai korban kekerasan berdasarkan UU PKDRT dan UU TPKS.',
      'icon': Icons.verified_user_rounded,
      'color': AppColors.accent,
    },
    {
      'title': 'Cara Menjaga Keselamatan Diri',
      'desc': 'Tips praktis untuk mengenali situasi bahaya dan melindungi diri sebelum bantuan tiba.',
      'icon': Icons.security_rounded,
      'color': AppColors.warning,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Pusat Edukasi',
          style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final a = _articles[i];
          final color = a['color'] as Color;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14)),
                  child: Icon(a['icon'] as IconData, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14,
                          color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Text(a['desc'] as String,
                        style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted, height: 1.4)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}