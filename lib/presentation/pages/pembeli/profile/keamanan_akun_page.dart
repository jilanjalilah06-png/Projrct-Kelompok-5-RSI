import 'package:flutter/material.dart';

class KeamananAkunPage extends StatefulWidget {
  const KeamananAkunPage({super.key});

  @override
  State<KeamananAkunPage> createState() => _KeamananAkunPageState();
}

class _KeamananAkunPageState extends State<KeamananAkunPage> {
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);

  bool _biometric = false;
  bool _twoFactor = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSecurityStatus(),
                    const SizedBox(height: 20),
                    _buildPasswordSection(),
                    const SizedBox(height: 16),
                    _buildSecurityOptions(),
                    const SizedBox(height: 16),
                    _buildLoginHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_greenDark, _green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Keamanan Akun',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green, Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.verified_user, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun Terlindungi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Keamanan akun Anda dalam kondisi baik',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: _green, size: 20),
              SizedBox(width: 10),
              Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terakhir diubah',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '15 Juni 2026',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D2939),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _showChangePasswordDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ubah', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOptions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opsi Keamanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _twoFactor,
            onChanged: (v) => setState(() => _twoFactor = v),
            activeColor: _green,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Verifikasi 2 Langkah',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Tambahkan lapisan keamanan ekstra',
              style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
            activeColor: _green,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Login Biometrik',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Gunakan sidik jari atau wajah',
              style: TextStyle(fontSize: 12, color: Color(0xFF667085)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHistory() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: _green, size: 20),
              SizedBox(width: 10),
              Text(
                'Riwayat Login',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLoginItem(
            device: 'Chrome - Windows',
            time: 'Hari ini, 08:30',
            isActive: true,
          ),
          const SizedBox(height: 12),
          _buildLoginItem(
            device: 'Flutter App - Android',
            time: 'Kemarin, 19:45',
            isActive: false,
          ),
          const SizedBox(height: 12),
          _buildLoginItem(
            device: 'Safari - iPhone',
            time: '28 Jun 2026, 14:20',
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginItem({
    required String device,
    required String time,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? _greenLight : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: _green.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.computer : Icons.smartphone,
            color: isActive ? _green : const Color(0xFF98A2B3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? _green : const Color(0xFF1D2939),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Aktif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubah Kata Sandi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi Lama',
                prefixIcon: const Icon(Icons.lock_outline, color: _green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Kata Sandi Baru',
                prefixIcon: const Icon(Icons.lock_reset, color: _green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Kata Sandi Baru',
                prefixIcon: const Icon(Icons.lock, color: _green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _green, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: _green),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Batal', style: TextStyle(color: _green)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Kata sandi berhasil diperbarui'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: _green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
