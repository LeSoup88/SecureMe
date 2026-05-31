import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../widgets/status_badge.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _reports = [];
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
    print('=== HISTORY PAGE LOAD ===');
    final savedId = await SupabaseService.getSavedSessionId();
    print('Saved session ID: $savedId');
    print('Current user: ${SupabaseService.currentUser?.id}');

    // Cek semua laporan yang ada di database
    final allReports = await SupabaseService.client
        .from('reports')
        .select('id, user_id, type, created_at')
        .order('created_at', ascending: false);
    print('ALL reports in DB: ${allReports.length}');
    for (var r in allReports) {
      print('  Report: id=${r['id']}, user_id=${r['user_id']}, type=${r['type']}');
    }

    final data = await SupabaseService.getMyReports();
    print('Reports received: ${data.length}');
    setState(() => _reports = data);
  } catch (e) {
    print('History load error: $e');
    setState(() => _error = e.toString());
  } finally {
    setState(() => _loading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                      Text('Gagal memuat riwayat',
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(_error!,
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _load,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white),
                          child: const Text('Coba Lagi')),
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
                          const SizedBox(height: 4),
                          Text('Laporan yang kamu buat akan muncul di sini',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final r = _reports[i];
                          final status = r['status'] ?? 'Belum Ditangani';
                          final isPanic = r['source'] == 'Panic Button';
                          final createdAt = r['created_at'] != null
                              ? r['created_at']
                                  .toString()
                                  .substring(0, 10)
                              : '';

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
                                            ? AppColors.danger
                                                .withOpacity(0.1)
                                            : AppColors.primary
                                                .withOpacity(0.08),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isPanic
                                            ? 'PANIC BUTTON'
                                            : 'FORM LAPORAN',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isPanic
                                              ? AppColors.danger
                                              : AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(createdAt,
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11)),
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
                                        size: 14,
                                        color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(r['location'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 11)),
                                    ),
                                    StatusBadge(status: status),
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