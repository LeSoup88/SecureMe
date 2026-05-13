class Validators {
  /// Tidak boleh kosong
  static String? required(String? value, {String fieldName = 'Field ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Format email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// Minimal panjang karakter
  static String? minLength(String? value, int min, {String fieldName = 'Field ini'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    if (value.length < min) {
      return '$fieldName minimal $min karakter';
    }
    return null;
  }

  /// Nomor telepon Indonesia
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{8,12}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Format nomor telepon tidak valid';
    }
    return null;
  }

  /// Password konfirmasi cocok
  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != original) {
      return 'Password tidak cocok';
    }
    return null;
  }
}