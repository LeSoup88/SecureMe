import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../widgets/status_badge.dart';
import '../portal/portal_page.dart';

class AdminHomePage extends StatefulWidget {
  final String adminName;
  const AdminHomePage({super.key, required this.adminName});
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  List<Map<String, dynamic>> _reports = [];
  bool _loading = true;
  String? _error;
  String _filterStatus = 'Semua';

  final List<String> _statusFilters = [
    'Semua',
    'Belum Ditangani',
    'Sedang Ditangani',
    'Sudah Ditangani',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await SupabaseService.getAllReports();
      setState(() => _reports = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_filterStatus == 'Semua') return _reports;
    return _reports.where((r) => r['status'] == _filterStatus).toList();
  }

  int _countByStatus(String status) =>
      _reports.where((r) => r['status'] == status).length;

  void _openDetail(Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportDetailSheet(
        report: report,
        onStatusChanged: (newStatus) async {
          await SupabaseService.updateReportStatus(
            reportId: report['id'],
            status: newStatus,
          );
          Navigator.pop(context);
          await _loadReports();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,  // Hapus tombol back kiri
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.adminName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _loadReports,
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Keluar',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                  title: const Text('Keluar',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                  content: const Text(
                    'Apakah Anda yakin ingin keluar dari Admin Dashboard?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal',
                        style: TextStyle(color: AppColors.textMuted)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PortalPage()),
                        (route) => false,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          elevation: 0,
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
                        Text('Gagal memuat data',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadReports,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white),
                          child: const Text('Coba Lagi')),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // ---- Overview Cards ----
                      Container(
                        color: AppColors.primaryDark,
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          children: [
                            _StatCard(
                              label: 'Total',
                              count: _reports.length,
                              color: Colors.white,
                              textColor: AppColors.primaryDark,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Belum',
                              count: _countByStatus('Belum Ditangani'),
                              color: AppColors.warning,
                              textColor: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Proses',
                              count: _countByStatus('Sedang Ditangani'),
                              color: AppColors.info,
                              textColor: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Selesai',
                              count: _countByStatus('Sudah Ditangani'),
                              color: AppColors.success,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      // ---- Filter ----
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _statusFilters.map((f) {
                              final isActive = _filterStatus == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(f),
                                  selected: isActive,
                                  onSelected: (_) => setState(
                                      () => _filterStatus = f),
                                  selectedColor: AppColors.primary
                                      .withOpacity(0.15),
                                  checkmarkColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // ---- List Laporan ----
                      Expanded(
                        child: _filteredReports.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inbox_rounded,
                                      color: AppColors.textMuted,
                                      size: 56),
                                    const SizedBox(height: 12),
                                    Text('Tidak ada laporan',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 15)),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadReports,
                                child: ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredReports.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (_, i) {
                                    final r = _filteredReports[i];
                                    return _ReportCard(
                                      report: r,
                                      onTap: () => _openDetail(r),
                                    );
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Report Card ──────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPanic = report['source'] == 'Panic Button';
    final status = report['status'] ?? 'Belum Ditangani';
    final createdAt = report['created_at'] != null
        ? report['created_at']
            .toString()
            .substring(0, 16)
            .replaceAll('T', ' ')
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPanic
                  ? AppColors.danger.withOpacity(0.4)
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
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isPanic
                          ? AppColors.danger.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPanic
                              ? Icons.warning_amber_rounded
                              : Icons.description_outlined,
                          size: 11,
                          color: isPanic
                              ? AppColors.danger
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPanic ? 'PANIC' : 'LAPORAN',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: isPanic
                                ? AppColors.danger
                                : AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                report['type'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report['location'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time_rounded,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    createdAt,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Report Detail Bottom Sheet ────────────────────────────────────────────────

class _ReportDetailSheet extends StatefulWidget {
  final Map<String, dynamic> report;
  final Function(String) onStatusChanged;

  const _ReportDetailSheet({
    required this.report,
    required this.onStatusChanged,
  });

  @override
  State<_ReportDetailSheet> createState() => _ReportDetailSheetState();
}

class _ReportDetailSheetState extends State<_ReportDetailSheet> {
  late String _selectedStatus;
  bool _loading = false;

  final List<String> _statuses = [
    'Belum Ditangani',
    'Sedang Ditangani',
    'Sudah Ditangani',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.report['status'] ?? 'Belum Ditangani';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final isPanic = r['source'] == 'Panic Button';
    final createdAt = r['created_at'] != null
        ? r['created_at']
            .toString()
            .substring(0, 16)
            .replaceAll('T', ' ')
        : '';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
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
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  createdAt,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _detailRow(
                Icons.category_rounded, 'Jenis', r['type'] ?? ''),
            const SizedBox(height: 12),
            _detailRow(Icons.location_on_rounded, 'Lokasi',
                r['location'] ?? ''),
            const SizedBox(height: 12),
            _detailRow(
              r['is_anonymous'] == true
                  ? Icons.visibility_off_rounded
                  : Icons.person_rounded,
              'Pelapor',
              r['reported_by'] ?? 'Tidak diketahui',
            ),
            const SizedBox(height: 12),

            const Text(
              'Deskripsi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                r['description'] ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Update Status Laporan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            ..._statuses.map((s) {
              final isSelected = _selectedStatus == s;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStatus = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          s,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await widget.onStatusChanged(_selectedStatus);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}