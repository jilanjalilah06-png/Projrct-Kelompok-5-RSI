import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/profile_photo_picker.dart';
import '../shared/edit_profile_page.dart';
import 'p6a_verifikasi_screen.dart';
import '../../../data/models/user_model.dart';

// ─────────────────────────────────────────────
//  P6 – Profil Petani
// ─────────────────────────────────────────────
class P6ProfilScreen extends StatefulWidget {
  const P6ProfilScreen({super.key});
  @override
  State<P6ProfilScreen> createState() => _P6ProfilScreenState();
}

class _P6ProfilScreenState extends State<P6ProfilScreen> {
  bool _notifJadwal = true;
  bool _notifOrder = true;
  bool _notifHarga = false;
  Uint8List? _profilePhotoBytes;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;
    final bool isVerified = user?.isVerified ?? true;
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => _openEditProfilePage(context, user),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          children: [
            // ── Avatar + nama ──
            _buildProfileHeader(user),
            const SizedBox(height: 16),

            // ── Verifikasi banner ──
            _buildVerifikasiBanner(context, isVerified),
            const SizedBox(height: 16),

            // ── Info pribadi ──
            _buildSectionCard(
              title: 'INFORMASI PRIBADI',
              children: [
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? 'budi@mail.com',
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'No. HP',
                  value: user?.phone ?? '0812-3456-7890',
                ),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Lokasi',
                  value: user?.address ?? 'Bandung',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Notifikasi ──
            _buildSectionCard(
              title: 'NOTIFIKASI',
              children: [
                _SwitchRow(
                  icon: Icons.notifications_active_outlined,
                  color: AgriColors.primary,
                  label: 'Pengingat jadwal panen',
                  value: _notifJadwal,
                  onChanged: (v) => setState(() => _notifJadwal = v),
                ),
                _SwitchRow(
                  icon: Icons.shopping_bag_outlined,
                  color: const Color(0xFF4CC9F0),
                  label: 'Order masuk (stok)',
                  value: _notifOrder,
                  onChanged: (v) => setState(() => _notifOrder = v),
                ),
                _SwitchRow(
                  icon: Icons.show_chart,
                  color: const Color(0xFFE9A824),
                  label: 'Info harga komoditas',
                  value: _notifHarga,
                  onChanged: (v) => setState(() => _notifHarga = v),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Aksi ──
            _buildSectionCard(
              title: 'AKUN',
              children: [
                _MenuRow(
                  icon: Icons.lock_outline,
                  label: 'Ganti Password',
                  color: AgriColors.textDark,
                  onTap: () => _showPasswordSheet(context),
                ),
                _MenuRow(
                  icon: Icons.logout,
                  label: 'Keluar (Logout)',
                  color: AgriColors.danger,
                  onTap: () async {
                    await auth.executeLogout();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfilePhotoPicker(
            radius: 40,
            uploadContext: 'profil petani',
            initialBytes: _profilePhotoBytes,
            initialImagePath: user?.avatar,
            onPreviewChanged: (bytes) =>
                setState(() => _profilePhotoBytes = bytes),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'Budi Santoso',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AgriColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user?.address ?? 'Bandung, Jawa Barat',
            style: const TextStyle(fontSize: 13, color: AgriColors.textLight),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AgriColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🌾  ${user?.role ?? "Petani"}',
              style: const TextStyle(
                color: AgriColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifikasiBanner(BuildContext context, bool isVerified) {
    return GestureDetector(
      onTap: isVerified
          ? null
          : () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const P6aVerifikasiScreen()),
            ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isVerified ? const Color(0xFFD1FAE5) : const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isVerified
                ? AgriColors.primaryLight
                : const Color(0xFFE9C46A),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.pending_outlined,
              color: isVerified ? AgriColors.primary : const Color(0xFF9A6E00),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVerified
                        ? '✅  Akun Terverifikasi'
                        : '⏳  Menunggu Verifikasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isVerified
                          ? AgriColors.primary
                          : const Color(0xFF9A6E00),
                    ),
                  ),
                  Text(
                    isVerified
                        ? 'Identitas & lahan telah diverifikasi oleh pendamping.'
                        : 'Ketuk untuk melengkapi data verifikasi.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isVerified
                          ? AgriColors.primary.withValues(alpha: 0.8)
                          : const Color(0xFF856404),
                    ),
                  ),
                ],
              ),
            ),
            if (!isVerified)
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFF9A6E00),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AgriColors.textLight,
                letterSpacing: 0.8,
              ),
            ),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _openEditProfilePage(BuildContext context, UserModel? user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          title: 'Edit Profil Petani',
          roleLabel: 'Profil Petani',
          user: user,
          profilePhotoBytes: _profilePhotoBytes,
          onPhotoChanged: (bytes) => setState(() => _profilePhotoBytes = bytes),
        ),
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(
      text: user?.name ?? 'Budi Santoso',
    );
    final phoneController = TextEditingController(
      text: user?.phone ?? '0812-3456-7890',
    );
    final addressController = TextEditingController(
      text: user?.address ?? 'Bandung',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profil Petani',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. HP',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Lokasi / alamat usaha',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnack(context, 'Profil petani berhasil disimpan.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgriColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan Profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ganti Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password lama',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password baru',
                prefixIcon: Icon(Icons.lock_reset),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showSnack(context, 'Password berhasil diperbarui.');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgriColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simpan Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

// ─── Info Row ─────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AgriColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AgriColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AgriColors.textLight,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AgriColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Switch Row ───────────────────────────────
class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AgriColors.textDark, fontSize: 14),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AgriColors.primary,
            activeTrackColor: AgriColors.primaryLight.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Row ─────────────────────────────────
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
