import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});
  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String _selectedType   = 'Kekerasan Fisik';
  bool   _isAnonymous    = false;
  bool   _loading        = false;
  XFile? _evidence;

  final List<String> _types = [
    'Kekerasan Fisik',
    'Kekerasan Seksual',
    'Pelecehan Verbal',
    'Kekerasan Dalam Rumah Tangga (KDRT)',
  ];

  Future<void> _submit() async {
    print('=== SUBMIT BUTTON PRESSED ===');

    if (_locationCtrl.text.isEmpty || _descriptionCtrl.text.isEmpty) {
      _showSnack('Lokasi dan deskripsi wajib diisi', AppColors.danger);
      return;
    }

    setState(() => _loading = true);

    try {
      print('Type: $_selectedType');
      print('Location: ${_locationCtrl.text}');
      print('Anonymous: $_isAnonymous');

      final result = await SupabaseService.createReport(
        type: _selectedType,
        location: _locationCtrl.text,
        description: _descriptionCtrl.text,
        isAnonymous: _isAnonymous,
      );

      print('Report created successfully: $result');

      _showSuccess();
      _locationCtrl.clear();
      _descriptionCtrl.clear();
      setState(() {
        _isAnonymous = false;
        _evidence    = null;
      });
    } catch (e) {
      print('Report submit error: $e');
      _showSnack('Gagal mengirim laporan: ${e.toString()}', AppColors.danger);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 44),
            ),
            const SizedBox(height: 16),
            const Text('Laporan Terkirim',
              style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'Laporan Anda telah diterima dan akan segera ditangani.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
              child: const Text('Mengerti'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final file   = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _evidence = file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ---- Jenis Kekerasan ----
            _sectionLabel('Jenis Kekerasan'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  onChanged: (v) => setState(() => _selectedType = v!),
                  items: _types.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t,
                      style: const TextStyle(fontSize: 14)),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ---- Lokasi ----
            _sectionLabel('Lokasi Kejadian'),
            const SizedBox(height: 8),
            _textField('Contoh: Halte Bus Blok M', _locationCtrl),
            const SizedBox(height: 18),

            // ---- Deskripsi ----
            _sectionLabel('Deskripsi Kejadian'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ceritakan detail kejadian secara singkat...',
                hintStyle: TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.divider)),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 18),

            // ---- Lampiran Bukti ----
            _sectionLabel('Lampiran Bukti (Opsional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider)),
                child: _evidence == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upload_file_rounded,
                            color: AppColors.textMuted, size: 28),
                          const SizedBox(height: 4),
                          Text('Ketuk untuk mengunggah Foto/Video',
                            style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.attach_file_rounded,
                            color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(_evidence!.name,
                            style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 18),

            // ---- Toggle Anonim ----
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider)),
              child: Row(
                children: [
                  Switch(
                    value: _isAnonymous,
                    onChanged: (v) => setState(() => _isAnonymous = v),
                    activeColor: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kirim secara Anonim',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDark)),
                        Text('Identitas Anda tidak akan ditampilkan',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ---- Tombol Kirim ----
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label: const Text('Kirim Laporan',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark));

  Widget _textField(String hint, TextEditingController ctrl) =>
    TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.divider)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
      ),
    );
}