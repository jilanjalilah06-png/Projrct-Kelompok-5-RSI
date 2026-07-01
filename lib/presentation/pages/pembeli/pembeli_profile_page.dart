import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/profile_photo_picker.dart';
import 'profile/informasi_pribadi_page.dart';
import 'profile/alamat_pengiriman_page.dart';
import 'profile/notifikasi_settings_page.dart';
import 'profile/keamanan_akun_page.dart';
import 'profile/hubungi_kami_page.dart';
import 'profile/pengaturan_page.dart';

class PembeliProfilePage extends StatefulWidget {
  const PembeliProfilePage({super.key});

  @override
  State<PembeliProfilePage> createState() => _PembeliProfilePageState();
}

class _PembeliProfilePageState extends State<PembeliProfilePage> {
  Uint8List? _profilePhotoBytes;

  // Green theme colors matching the app design
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);
  static const Color _greenAccent = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: _greenLight,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(user),
            _buildStatsRow(),
            const SizedBox(height: 8),
            _buildMenuSection(context),
            const SizedBox(height: 12),
            _buildLogoutButton(context, auth),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Green gradient header with profile photo, name, email, and badge
  Widget _buildHeader(UserModel? user) {
    final name = user?.name ?? 'Aryo';
    final email = user?.email ?? 'aryo@agriconnect.id';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_greenDark, _green, _greenAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('🌾', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Profil Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Profile avatar
          ProfilePhotoPicker(
            radius: 40,
            uploadContext: 'profil pembeli',
            initialBytes: _profilePhotoBytes,
            initialImagePath: user?.avatar,
            onPreviewChanged: (bytes) =>
                setState(() => _profilePhotoBytes = bytes),
          ),
          const SizedBox(height: 14),
          // Name
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              'Pembeli Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Stats row: Pesanan, Selesai, Ulasan
  Widget _buildStatsRow() {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildStatItem('12', 'Pesanan', _green),
              _buildDivider(),
              _buildStatItem('9', 'Selesai', _green),
              _buildDivider(),
              _buildStatItem('7', 'Ulasan', _green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE4E7EC),
    );
  }

  /// Menu section with navigable items
  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
          children: [
            _buildMenuItem(
              icon: Icons.person_outline,
              iconColor: _green,
              bgColor: _greenLight,
              title: 'Informasi Pribadi',
              subtitle: 'Nama, email, nomor HP',
              onTap: () => _navigateTo(context, const InformasiPribadiPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: 'Alamat & Pengiriman',
              subtitle: 'Kelola alamat tersimpan',
              onTap: () => _navigateTo(context, const AlamatPengirimanPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: 'Notifikasi',
              subtitle: 'Atur preferensi notifikasi',
              onTap: () => _navigateTo(context, const NotifikasiSettingsPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.shield_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: 'Keamanan Akun',
              subtitle: 'Password & verifikasi',
              onTap: () => _navigateTo(context, const KeamananAkunPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.phone_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: 'Hubungi Kami',
              subtitle: 'CS 24/7 siap membantu',
              onTap: () => _navigateTo(context, const HubungiKamiPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: 'Pengaturan',
              subtitle: 'Bahasa, tema, dan lainnya',
              onTap: () => _navigateTo(context, const PengaturanPage()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFD0D5DD),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: Color(0xFFF2F4F7)),
    );
  }

  /// Logout button
  Widget _buildLogoutButton(BuildContext context, AuthController auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context, auth),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.shade100,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to sub-page with a slide transition
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 22),
              SizedBox(width: 10),
              Text('Keluar'),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(color: Color(0xFF667085)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                auth.executeLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
