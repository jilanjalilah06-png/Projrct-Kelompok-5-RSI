import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/order_controller.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().loadOrders();
    });
  }

  // Green theme colors matching the app design
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);
  static const Color _greenAccent = Color(0xFF4CAF50);

  Color _getBgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF121212) : _greenLight;
  }

  Color _getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : const Color(0xFF1D2939);
  }

  Color _getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : const Color(0xFF667085);
  }

  String _t(String key, bool isEnglish) {
    final translations = {
      'profil_saya': {'id': 'Profil Saya', 'en': 'My Profile'},
      'pembeli_aktif': {'id': 'Pembeli Aktif', 'en': 'Active Buyer'},
      'pesanan': {'id': 'Pesanan', 'en': 'Orders'},
      'selesai': {'id': 'Selesai', 'en': 'Completed'},
      'ulasan': {'id': 'Ulasan', 'en': 'Reviews'},
      'informasi_pribadi': {'id': 'Informasi Pribadi', 'en': 'Personal Information'},
      'informasi_pribadi_sub': {'id': 'Nama, email, nomor HP', 'en': 'Name, email, phone number'},
      'alamat_pengiriman': {'id': 'Alamat & Pengiriman', 'en': 'Address & Shipping'},
      'alamat_pengiriman_sub': {'id': 'Kelola alamat tersimpan', 'en': 'Manage saved addresses'},
      'notifikasi': {'id': 'Notifikasi', 'en': 'Notifications'},
      'notifikasi_sub': {'id': 'Atur preferensi notifikasi', 'en': 'Configure notification preferences'},
      'keamanan_akun': {'id': 'Keamanan Akun', 'en': 'Account Security'},
      'keamanan_akun_sub': {'id': 'Password & verifikasi', 'en': 'Password & verification'},
      'hubungi_kami': {'id': 'Hubungi Kami', 'en': 'Contact Us'},
      'hubungi_kami_sub': {'id': 'CS 24/7 siap membantu', 'en': '24/7 Support ready to help'},
      'pengaturan': {'id': 'Pengaturan', 'en': 'Settings'},
      'pengaturan_sub': {'id': 'Bahasa, tema, dan lainnya', 'en': 'Language, theme, and others'},
      'keluar': {'id': 'Keluar', 'en': 'Logout'},
      'yakin_keluar': {'id': 'Apakah Anda yakin ingin keluar dari aplikasi?', 'en': 'Are you sure you want to log out of the application?'},
      'batal': {'id': 'Batal', 'en': 'Cancel'},
    };
    return translations[key]?[isEnglish ? 'en' : 'id'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final langCtrl = context.watch<LanguageController>();
    final isEnglish = langCtrl.isEnglish;
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: _getBgColor(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: _green,
          onRefresh: () async {
            await context.read<OrderController>().loadOrders();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(user, isEnglish),
              _buildStatsRow(isEnglish),
              const SizedBox(height: 8),
              _buildMenuSection(context, isEnglish),
              const SizedBox(height: 12),
              _buildLogoutButton(context, auth, isEnglish),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Green gradient header with profile photo, name, email, and badge
  Widget _buildHeader(UserModel? user, bool isEnglish) {
    final name = user?.name ?? 'Pembeli';
    final email = user?.email ?? 'pembeli@agriconnect.id';

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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo_round.png',
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _t('profil_saya', isEnglish),
                  style: const TextStyle(
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
            child: Text(
              _t('pembeli_aktif', isEnglish),
              style: const TextStyle(
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
  Widget _buildStatsRow(bool isEnglish) {
    final orderCtrl = context.watch<OrderController>();
    final orders = orderCtrl.orders;
    final totalOrders = orders.length;
    final completedOrders = orders.where((o) => o.status.toLowerCase() == 'completed' || o.status.toLowerCase() == 'selesai').length;
    final reviewsCount = 0; // Start clean from 0 for ulasan

    return Transform.translate(
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: _getCardColor(context),
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
              _buildStatItem('$totalOrders', _t('pesanan', isEnglish), _green),
              _buildDivider(),
              _buildStatItem('$completedOrders', _t('selesai', isEnglish), _green),
              _buildDivider(),
              _buildStatItem('$reviewsCount', _t('ulasan', isEnglish), _green),
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
            style: TextStyle(
              fontSize: 12,
              color: _getSecondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 36,
      color: isDark ? Colors.white10 : const Color(0xFFE4E7EC),
    );
  }

  /// Menu section with navigable items
  Widget _buildMenuSection(BuildContext context, bool isEnglish) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(context),
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
              title: _t('informasi_pribadi', isEnglish),
              subtitle: _t('informasi_pribadi_sub', isEnglish),
              onTap: () => _navigateTo(context, const InformasiPribadiPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.location_on_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: _t('alamat_pengiriman', isEnglish),
              subtitle: _t('alamat_pengiriman_sub', isEnglish),
              onTap: () => _navigateTo(context, const AlamatPengirimanPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: _t('notifikasi', isEnglish),
              subtitle: _t('notifikasi_sub', isEnglish),
              onTap: () => _navigateTo(context, const NotifikasiSettingsPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.shield_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: _t('keamanan_akun', isEnglish),
              subtitle: _t('keamanan_akun_sub', isEnglish),
              onTap: () => _navigateTo(context, const KeamananAkunPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.phone_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: _t('hubungi_kami', isEnglish),
              subtitle: _t('hubungi_kami_sub', isEnglish),
              onTap: () => _navigateTo(context, const HubungiKamiPage()),
            ),
            _menuDivider(),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              iconColor: _green,
              bgColor: _greenLight,
              title: _t('pengaturan', isEnglish),
              subtitle: _t('pengaturan_sub', isEnglish),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                color: isDark ? const Color(0xFF2A2A2A) : bgColor,
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white24 : const Color(0xFFD0D5DD),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF2F4F7)),
    );
  }

  /// Logout button
  Widget _buildLogoutButton(BuildContext context, AuthController auth, bool isEnglish) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context, auth, isEnglish),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2D1F1F) : Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.red.shade900.withValues(alpha: 0.4) : Colors.red.shade100,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: isDark ? Colors.red.shade400 : Colors.red.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                _t('keluar', isEnglish),
                style: TextStyle(
                  color: isDark ? Colors.red.shade400 : Colors.red.shade600,
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

  void _showLogoutDialog(BuildContext context, AuthController auth, bool isEnglish) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.logout, color: Colors.red, size: 22),
              const SizedBox(width: 10),
              Text(_t('keluar', isEnglish)),
            ],
          ),
          content: Text(_t('yakin_keluar', isEnglish)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                _t('batal', isEnglish),
                style: const TextStyle(color: Color(0xFF667085)),
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
              child: Text(_t('keluar', isEnglish)),
            ),
          ],
        );
      },
    );
  }
}
