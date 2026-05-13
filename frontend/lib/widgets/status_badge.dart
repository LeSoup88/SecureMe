import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum ReportStatus { belumDitangani, sedangDitangani, sudahDitangani }

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  ReportStatus get _parsed {
    if (status == 'Sedang Ditangani') return ReportStatus.sedangDitangani;
    if (status == 'Sudah Ditangani') return ReportStatus.sudahDitangani;
    return ReportStatus.belumDitangani;
  }

  Color get _color {
    switch (_parsed) {
      case ReportStatus.belumDitangani:
        return AppColors.warning;
      case ReportStatus.sedangDitangani:
        return AppColors.info;
      case ReportStatus.sudahDitangani:
        return AppColors.success;
    }
  }

  IconData get _icon {
    switch (_parsed) {
      case ReportStatus.belumDitangani:
        return Icons.schedule_rounded;
      case ReportStatus.sedangDitangani:
        return Icons.autorenew_rounded;
      case ReportStatus.sudahDitangani:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}