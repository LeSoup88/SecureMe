import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await ApiService.getToken();
      print('Token for history: $token');

      final res = await ApiService.getMyReports();
      print('History response status: ${res.statusCode}');
      print('History response body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        setState(() {
          _reports = decoded is List ? decoded : [];
        });
      } else {
        setState(() => _error = 'Gagal memuat riwayat (${res.statusCode})');
      }
    } catch (e) {
      print('History error: $e');
      setState(() => _error = 'Tidak dapat terhubung ke server');
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    if (status == 'Sedang Ditangani') return AppColors.info;
    if (status == 'Sudah Ditangani') return AppColors.success;
    return AppColors.warning;
  }

  IconData _statusIcon(String status) {
    if (status == 'Sedang Ditangani') return Icons.autorenew_rounded;
    if (status == 'Sudah Ditangani') return Icons.check_circle_rounded;
    return Icons.schedule_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Riwayat Laporan',
          style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                        color: AppColors.danger, size: 48),
                      const SizedBox(height: 12),
                      Text(_error!,
                        style: TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _reports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded,
                            color: AppColors.textMuted, size: 64),
                          const SizedBox(height: 12),
                          Text('Belum ada laporan',
                            style: TextStyle(
                              color: AppColors.textMuted, fontSize: 15)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final r = _reports[i];
                          final status = r['status'] ?? 'Belum Ditangani';
                          final isPanic = r['source'] == 'Panic Button';
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPanic
                                    ? AppColors.danger.withOpacity(0.3)
                                    : AppColors.divider,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isPanic
                                            ? AppColors.danger.withOpacity(0.1)
                                            : AppColors.primary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isPanic ? 'PANIC BUTTON' : 'FORM LAPORAN',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isPanic
                                              ? AppColors.danger
                                              : AppColors.primary,
                                          letterSpacing: 0.5,
                                        )),
                                    ),
                                    const Spacer(),
                                    Text(
                                      r['created_at'] != null
                                          ? r['created_at']
                                              .toString()
                                              .substring(0, 10)
                                          : '',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(r['type'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.textDark)),
                                const SizedBox(height: 4),
                                Text(r['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 13,
                                    height: 1.4)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                      size: 14, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(r['location'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _statusColor(status)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(_statusIcon(status),
                                            size: 12,
                                            color: _statusColor(status)),
                                          const SizedBox(width: 4),
                                          Text(status,
                                            style: TextStyle(
                                              color: _statusColor(status),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}