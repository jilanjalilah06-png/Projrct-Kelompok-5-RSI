import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/agri_brand_logo.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _success;
  String? _otpVal; // To hold offline/sandbox OTP code
  bool _showResetForm = false; // Step 2 flag
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  static const Color primaryGreen = Color(0xFF558B2F);
  static const Color textDark = Color(0xFF2C3E26);

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Nomor WhatsApp tidak boleh kosong');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final auth = context.read<AuthController>();
      final res = await auth.requestOtp(phone);
      
      setState(() {
        _success = res['message'] ?? 'Kode OTP telah dikirim ke nomor WhatsApp Anda.';
        _otpVal = res['otp'];
        _showResetForm = true;
        if (_otpVal != null) {
          _otpController.text = _otpVal!;
        }
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();

    if (otp.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      setState(() => _error = 'Semua kolom harus diisi');
      return;
    }

    if (newPw.length < 6) {
      setState(() => _error = 'Kata sandi baru minimal 6 karakter');
      return;
    }

    if (newPw != confirmPw) {
      setState(() => _error = 'Konfirmasi kata sandi tidak cocok');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = context.read<AuthController>();
      
      // Directly call resetPasswordOtp using the public endpoint
      await auth.resetPasswordOtp(
        phone: phone,
        otp: otp,
        newPassword: newPw,
      );

      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Berhasil', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
          content: const Text('Kata sandi Anda berhasil diperbarui. Silakan masuk kembali dengan kata sandi baru Anda.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx); // close dialog
                Navigator.pop(context); // go back to login screen
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBE7), // Light greenish background matching theme
      appBar: AppBar(
        title: const Text('Atur Ulang Kata Sandi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AgriBrandLogo(),
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _showResetForm ? 'Masukkan Kata Sandi Baru' : 'Lupa Kata Sandi?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (!_showResetForm) ...[
                        const Text(
                          'Masukkan nomor WhatsApp Anda yang terdaftar untuk menerima kode OTP reset password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Nomor WhatsApp',
                            hintText: '08xxxxxxxxxx',
                            prefixIcon: const Icon(Icons.phone_android_outlined, color: primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _requestOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Kirim Kode OTP WA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ] else ...[
                        // Step 2: Reset Form
                        if (_otpVal != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kode OTP Sandbox (Tampil otomatis untuk simulasi):',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber),
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  _otpVal!,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent, letterSpacing: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            _success ?? 'Silakan periksa pesan masuk WhatsApp Anda.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Kode OTP WhatsApp',
                            prefixIcon: const Icon(Icons.lock_open_outlined, color: primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi Baru',
                            prefixIcon: const Icon(Icons.lock_outline, color: primaryGreen),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureNew = !_obscureNew),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Kata Sandi Baru',
                            prefixIcon: const Icon(Icons.lock_reset, color: primaryGreen),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryGreen, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Simpan Password Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
