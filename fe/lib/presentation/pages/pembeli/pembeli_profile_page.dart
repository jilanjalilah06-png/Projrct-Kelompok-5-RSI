import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/profile_photo_picker.dart';
import '../shared/edit_profile_page.dart';
import '../shared/virtual_assistant_page.dart';

class PembeliProfilePage extends StatefulWidget {
  const PembeliProfilePage({super.key});

  @override
  State<PembeliProfilePage> createState() => _PembeliProfilePageState();
}

class _PembeliProfilePageState extends State<PembeliProfilePage> {
  Uint8List? _profilePhotoBytes;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 720;
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AgriColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AgriColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Kelola informasi akun Anda',
                style: TextStyle(color: AgriColors.textLight, fontSize: 13),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfilePhotoPicker(
                      radius: 34,
                      uploadContext: 'profil pembeli',
                      initialBytes: _profilePhotoBytes,
                      initialImagePath: user?.avatar,
                      onPreviewChanged: (bytes) =>
                          setState(() => _profilePhotoBytes = bytes),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Sari Dewi',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AgriColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'sari@email.com',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AgriColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.address ?? 'Bandung, Jawa Barat',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AgriColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openEditProfilePage(context, user),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AgriColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Information
              const Text(
                'Informasi Akun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AgriColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              _buildProfileMenuItem(
                Icons.person_outline,
                'Ubah Profil',
                'Update data pribadi Anda',
                () => _openEditProfilePage(context, user),
              ),
              _buildProfileMenuItem(
                Icons.lock_outline,
                'Ubah Kata Sandi',
                'Tingkatkan keamanan akun',
                () => _showChangePasswordDialog(context),
              ),
              _buildProfileMenuItem(
                Icons.phone_outlined,
                'Nomor Telepon',
                user?.phone ?? '0856-7890-1234',
                () => _showPhoneDialog(context, user),
              ),
              _buildProfileMenuItem(
                Icons.location_on_outlined,
                'Alamat',
                'Kelola alamat pengiriman',
                () => _showAddressDialog(context),
              ),
              const SizedBox(height: 24),

              // Settings
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AgriColors.textDark,
                ),
              ),
              const SizedBox(height: 12),

              _buildProfileMenuItem(
                Icons.notifications_outlined,
                'Notifikasi',
                'Atur preferensi notifikasi',
                () => _showNotificationSheet(context),
              ),
              _buildProfileMenuItem(
                Icons.security_outlined,
                'Privasi & Keamanan',
                'Kelola pengaturan keamanan',
                () => _showSecuritySheet(context),
              ),
              _buildProfileMenuItem(
                Icons.help_outline,
                'Bantuan & Dukungan',
                'Hubungi customer service',
                () => _showSupportSheet(context),
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: Consumer<AuthController>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: () => _showLogoutDialog(context, auth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AgriColors.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AgriColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgriColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AgriColors.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel? user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: TextEditingController(
                      text: user?.name ?? 'Sari Dewi',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(
                      text: user?.email ?? 'sari@email.com',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(
                      text: user?.phone ?? '0856-7890-1234',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSavedSnack(
                              context,
                              'Profil berhasil disimpan.',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSavedSnack(
                              context,
                              'Kata sandi berhasil diperbarui.',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ubah Kata Sandi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Lama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showSavedSnack(
                              context,
                              'Alamat berhasil disimpan.',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ubah Kata Sandi'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kelola Alamat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: TextEditingController(text: 'Rumah'),
                    decoration: InputDecoration(
                      labelText: 'Label Alamat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(
                      text: 'Jl. Merdeka No. 12, Bandung',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: 'Bandung'),
                          decoration: InputDecoration(
                            labelText: 'Kota',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: '40123'),
                          decoration: InputDecoration(
                            labelText: 'Kode Pos',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                auth.executeLogout();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _openEditProfilePage(BuildContext context, UserModel? user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          title: 'Edit Profil Pembeli',
          roleLabel: 'Profil Pembeli',
          user: user,
          profilePhotoBytes: _profilePhotoBytes,
          onPhotoChanged: (bytes) => setState(() => _profilePhotoBytes = bytes),
        ),
      ),
    );
  }

  void _showPhoneDialog(BuildContext context, UserModel? user) {
    final phoneController = TextEditingController(
      text: user?.phone ?? '0856-7890-1234',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Nomor Telepon'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Nomor aktif',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSavedSnack(context, 'Nomor telepon berhasil disimpan.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AgriColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    bool order = true;
    bool promo = false;
    bool delivery = true;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Notifikasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                value: order,
                onChanged: (v) => setModalState(() => order = v),
                title: const Text('Status pesanan'),
              ),
              SwitchListTile(
                value: delivery,
                onChanged: (v) => setModalState(() => delivery = v),
                title: const Text('Pengiriman'),
              ),
              SwitchListTile(
                value: promo,
                onChanged: (v) => setModalState(() => promo = v),
                title: const Text('Promo dan rekomendasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecuritySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.verified_user_outlined),
              title: Text('Perlindungan akun aktif'),
              subtitle: Text('Token login dan akses API sudah memakai JWT.'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Ubah kata sandi'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bantuan & Dukungan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Chat Bantuan'),
              subtitle: const Text('Buka Agri Asisten Bot.'),
              onTap: () {
                Navigator.pop(context);
                _openChatbot(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Hubungi Email'),
              subtitle: const Text('agriconnect0626@gmail.com'),
              onTap: () {
                Navigator.pop(context);
                _launchSupportEmail(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VirtualAssistantPage(
          roleContext: context.read<AuthController>().currentRole,
        ),
      ),
    );
  }

  Future<void> _launchSupportEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'agriconnect0626@gmail.com',
      queryParameters: const {'subject': 'Bantuan AgriConnect'},
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      final gmailUri = Uri.https('mail.google.com', '/mail/', {
        'view': 'cm',
        'fs': '1',
        'to': 'agriconnect0626@gmail.com',
        'su': 'Bantuan AgriConnect',
      });
      final openedGmail = await launchUrl(
        gmailUri,
        mode: LaunchMode.externalApplication,
      );
      if (!openedGmail && context.mounted) {
        _showSavedSnack(context, 'Aplikasi email tidak tersedia.');
      }
    }
  }

  void _showSavedSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
