import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  static const _contacts = [
    {
      'name': 'Polisi',
      'phone': '110',
      'desc': 'Layanan darurat kepolisian 24 jam',
      'icon': Icons.local_police_rounded,
      'color': AppColors.primary,
    },
    {
      'name': 'Ambulans',
      'phone': '118',
      'desc': 'Layanan medis darurat',
      'icon': Icons.local_hospital_rounded,
      'color': AppColors.danger,
    },
    {
      'name': 'Komnas Perempuan',
      'phone': '021-3903963',
      'desc': 'Komisi Nasional Anti Kekerasan terhadap Perempuan',
      'icon': Icons.wc_rounded,
      'color': AppColors.accent,
    },
    {
      'name': 'LBH APIK Jakarta',
      'phone': '021-8779-0146',
      'desc': 'Lembaga Bantuan Hukum untuk perempuan dan anak',
      'icon': Icons.balance_rounded,
      'color': AppColors.info,
    },
    {
      'name': 'SAPA Indonesia',
      'phone': '1500-454',
      'desc': 'Layanan konseling dan pendampingan gratis',
      'icon': Icons.headset_mic_rounded,
      'color': AppColors.success,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Kontak Darurat',
          style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _contacts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final c = _contacts[i];
          final color = c['color'] as Color;
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
                  child: Icon(c['icon'] as IconData, color: color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14,
                          color: AppColors.textDark)),
                      Text(c['phone'] as String,
                        style: TextStyle(
                          color: AppColors.primary, fontSize: 13,
                          fontWeight: FontWeight.w600)),
                      Text(c['desc'] as String,
                        style: TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},  // Sambungkan ke url_launcher jika diperlukan
                  icon: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.phone_rounded,
                      color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}