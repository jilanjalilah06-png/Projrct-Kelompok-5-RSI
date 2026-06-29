class ValidationHelper {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value)) {
      return 'Format email salah';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName wajib diisi';
    return null;
  }
}
