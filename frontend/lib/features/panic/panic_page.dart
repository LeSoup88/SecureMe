import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/location_service.dart';

class PanicPage extends StatefulWidget {
  const PanicPage({super.key});
  @override
  State<PanicPage> createState() => _PanicPageState();
}

class _PanicPageState extends State<PanicPage>
    with SingleTickerProviderStateMixin {
  bool _isActive = false;
  bool _loading  = false;
  String _locationLabel = 'Mengambil lokasi...';

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final pos = await LocationService.getCurrentLocation();
    if (pos != null) {
      setState(() {
        _locationLabel =
            '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      });
    } else {
      setState(() => _locationLabel = 'Izin lokasi diperlukan');
    }
  }

  Future<void> _triggerPanic() async {
  print('=== PANIC BUTTON PRESSED ===');

  setState(() {
    _loading = true;
    _isActive = true;
  });

  try {
    // Cek dan minta permission GPS secara eksplisit
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('GPS enabled: $serviceEnabled');

    if (!serviceEnabled) {
      if (!mounted) return;
      _showSnack(
        'GPS tidak aktif. Aktifkan GPS lalu coba lagi.',
        AppColors.danger,
      );
      setState(() { _loading = false; _isActive = false; });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('Permission: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        _showSnack(
          'Izin lokasi diperlukan untuk fitur ini.',
          AppColors.danger,
        );
        setState(() { _loading = false; _isActive = false; });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      _showSnackPermanent(
        'Izin lokasi diblokir permanen. Aktifkan di pengaturan aplikasi.',
      );
      setState(() { _loading = false; _isActive = false; });
      return;
    }

    // Ambil posisi
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 15));
      print('Posisi: ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      print('Gagal ambil GPS: $e');
      // Coba last known position
      pos = await Geolocator.getLastKnownPosition();
      print('Last known: $pos');
    }

    // Tentukan nama lokasi
    String locationName = 'Lokasi tidak diketahui';
    if (pos != null) {
      locationName =
          '${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';

      try {
        final geocoded = await LocationService.reverseGeocode(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${pos.latitude}&lon=${pos.longitude}&format=json',
        ).timeout(const Duration(seconds: 5));
        if (geocoded != null && geocoded.isNotEmpty) {
          locationName = geocoded;
        }
      } catch (_) {
        print('Geocoding gagal, pakai koordinat');
      }

      if (mounted) setState(() => _locationLabel = locationName);
    }

    print('Location name: $locationName');

    // Kirim ke Supabase
    await SupabaseService.triggerPanic(
      latitude: pos?.latitude ?? 0.0,
      longitude: pos?.longitude ?? 0.0,
      locationName: locationName,
    );

    print('Panic berhasil dikirim');
    if (!mounted) return;
    _showSuccessDialog();
  } catch (e) {
    print('Panic error: $e');
    if (!mounted) return;
    setState(() => _isActive = false);
    _showSnack('Gagal mengirim sinyal: ${e.toString()}', AppColors.danger);
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sinyal Darurat Terkirim!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi Anda telah dikirim ke pihak berwajib. '
              'Bantuan sedang dalam perjalanan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isActive = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Mengerti'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: color),
  );
}

  void _showSnackPermanent(String msg) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.danger,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Pengaturan',
        textColor: Colors.white,
        onPressed: () => Geolocator.openAppSettings(),
      ),
    ),
  );
}
  
  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: Column(
      children: [
        // ---- Status lokasi ----
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: _isActive
              ? AppColors.danger.withOpacity(0.08)
              : AppColors.primary.withOpacity(0.04),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: _isActive ? AppColors.danger : AppColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _locationLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: _loadLocation,
                child: const Text(
                  'Perbarui',
                  style: TextStyle(fontSize: 11, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        // ---- Tombol Panik ----
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isActive)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Mengirimkan sinyal darurat...',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: _isActive ? _pulseAnim.value : 1.0,
                  child: child,
                ),
                child: _PanicButton(
                  isActive: _isActive,
                  loading: _loading,
                  onTap: _loading ? null : _triggerPanic,
                ),
              ),
              const SizedBox(height: 36),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _isActive
                      ? 'Tetap tenang. Bantuan sedang diproses.'
                      : 'Tekan tombol jika Anda dalam bahaya. '
                          'Lokasi GPS Anda akan langsung dikirim ke pihak berwajib.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ---- Nomor darurat ----
        Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            children: [
              _EmergencyChip(
                icon: Icons.local_police_rounded,
                label: 'Polisi',
                number: '110',
              ),
              const SizedBox(width: 12),
              _EmergencyChip(
                icon: Icons.local_hospital_rounded,
                label: 'Ambulans',
                number: '118',
              ),
              const SizedBox(width: 12),
              _EmergencyChip(
                icon: Icons.wc_rounded,
                label: 'Komnas',
                number: '021-3903963',
                flex: 2,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}

// ── Widget Tombol Panik ───────────────────────────────────────────────────────

class _PanicButton extends StatelessWidget {
  final bool isActive;
  final bool loading;
  final VoidCallback? onTap;

  const _PanicButton({
    required this.isActive,
    required this.loading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? AppColors.danger : const Color(0xFFD32F2F),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withOpacity(isActive ? 0.6 : 0.35),
              blurRadius: isActive ? 48 : 28,
              spreadRadius: isActive ? 12 : 4,
            ),
          ],
        ),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PANIK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Widget Chip Nomor Darurat ─────────────────────────────────────────────────

class _EmergencyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final int flex;

  const _EmergencyChip({
    required this.icon,
    required this.label,
    required this.number,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Text(
              number,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}