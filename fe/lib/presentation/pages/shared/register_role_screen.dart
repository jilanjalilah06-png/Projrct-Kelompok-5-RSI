import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../controllers/auth_controller.dart';

class RegisterRoleScreen extends StatefulWidget {
  final String name;
  final String username;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterRoleScreen({
    super.key,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  State<RegisterRoleScreen> createState() => _RegisterRoleScreenState();
}

class _RegisterRoleScreenState extends State<RegisterRoleScreen> {
  bool _loading = false;
  String? _error;
  String? _selectedRole; // 'Petani' or 'Pembeli'

  Future<void> _register(String role) async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedRole = role;
    });

    final auth = Provider.of<AuthController>(context, listen: false);
    final ok = await auth.executeRegister(
      name: widget.name,
      email: widget.email,
      password: widget.password,
      passwordConfirmation: widget.passwordConfirmation,
      role: role,
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    if (ok) {
      Navigator.popUntil(context, (r) => r.isFirst);
    } else {
      setState(() {
        _error = auth.lastError ?? 'Registrasi gagal. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFDE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih Peran Anda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Peran menentukan cara Anda berinteraksi di sistem',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),

                // ── Form Card ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Warning Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFE082)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(Icons.info_outline, color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Pilihan peran bersifat permanen dan tidak dapat diubah setelah didaftarkan.',
                                style: TextStyle(
                                  color: Color(0xFFE65100),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Error Banner
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Color(0xFFD32F2F), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Color(0xFFD32F2F),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Button Petani
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32), // Petani Green
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _loading ? null : () => _register('Petani'),
                          child: _loading && _selectedRole == 'Petani'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Daftar Sebagai Petani',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Button Pembeli
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0), // Pembeli Blue
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _loading ? null : () => _register('Pembeli'),
                          child: _loading && _selectedRole == 'Pembeli'
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Daftar Sebagai Pembeli',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Kembali ke login
                      Center(
                        child: TextButton(
                          onPressed: _loading
                              ? null
                              : () {
                                  Navigator.of(context).pop(); // Back to Info
                                  Navigator.of(context).pop(); // Back to Login
                                },
                          child: const Text(
                            'Sudah punya akun? Masuk',
                            style: TextStyle(
                              color: AgriColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
