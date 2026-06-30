import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constanst/agri_colors.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/auth_controller.dart';
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
  bool _darkMode = true;

  static const Color _surface = Color(0xFF17191D);
  static const Color _surfaceSoft = Color(0xFF22252B);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final backgroundColor = _darkMode
        ? const Color(0xFF0B0D10)
        : AgriColors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _TopBar(
              title: 'Profil Pembeli',
              onEdit: () => _openEditProfilePage(context, user),
            ),
            const SizedBox(height: 14),
            _ModeToggle(
              darkMode: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
            const SizedBox(height: 18),
            _ProfileHero(
              user: user,
              roleLabel: user?.role ?? 'Pembeli',
              darkMode: _darkMode,
              profilePhotoBytes: _profilePhotoBytes,
              onPhotoChanged: (bytes) =>
                  setState(() => _profilePhotoBytes = bytes),
            ),
            const SizedBox(height: 12),
            _ActionChips(
              darkMode: _darkMode,
              onEdit: () => _openEditProfilePage(context, user),
              onPassword: () => _showChangePasswordDialog(context),
              onSupport: () => _showSupportSheet(context),
            ),
            const SizedBox(height: 18),
            _DarkSection(
              darkMode: _darkMode,
              children: [
                _InfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? 'sari@email.com',
                  darkMode: _darkMode,
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Nomor telepon',
                  value: user?.phone ?? '0856-7890-1234',
                  darkMode: _darkMode,
                  onTap: () => _showPhoneDialog(context, user),
                ),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: user?.address ?? 'Bandung, Jawa Barat',
                  darkMode: _darkMode,
                  onTap: () => _showAddressDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DarkSection(
              darkMode: _darkMode,
              children: [
                _MenuTile(
                  icon: Icons.person_outline,
                  title: 'Ubah Profil',
                  subtitle: 'Update data pribadi Anda',
                  darkMode: _darkMode,
                  onTap: () => _openEditProfilePage(context, user),
                ),
                _MenuTile(
                  icon: Icons.lock_outline,
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Tingkatkan keamanan akun',
                  darkMode: _darkMode,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifikasi',
                  subtitle: 'Atur preferensi notifikasi',
                  darkMode: _darkMode,
                  onTap: () => _showNotificationSheet(context),
                ),
                _MenuTile(
                  icon: Icons.security_outlined,
                  title: 'Privasi & Keamanan',
                  subtitle: 'Kelola pengaturan keamanan',
                  darkMode: _darkMode,
                  onTap: () => _showSecuritySheet(context),
                ),
                _MenuTile(
                  icon: Icons.help_outline,
                  title: 'Bantuan & Dukungan',
                  subtitle: 'Hubungi customer service',
                  darkMode: _darkMode,
                  onTap: () => _showSupportSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, auth),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Keluar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
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
                  const SizedBox(height: 18),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Lama',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru',
                      prefixIcon: Icon(Icons.lock_reset),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Kata Sandi',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
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

  void _showAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
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
                  const SizedBox(height: 18),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Label Alamat',
                      prefixIcon: Icon(Icons.label_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSavedSnack(context, 'Alamat berhasil disimpan.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AgriColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onEdit;

  const _TopBar({required this.title, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AgriColors.primaryDark, AgriColors.primary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.darkMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF17191D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: darkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeSegment(
              icon: Icons.dark_mode_outlined,
              label: 'Dark',
              selected: darkMode,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ModeSegment(
              icon: Icons.light_mode_outlined,
              label: 'Putih',
              selected: !darkMode,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AgriColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AgriColors.textLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AgriColors.textLight,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserModel? user;
  final String roleLabel;
  final bool darkMode;
  final Uint8List? profilePhotoBytes;
  final ValueChanged<Uint8List> onPhotoChanged;

  const _ProfileHero({
    required this.user,
    required this.roleLabel,
    required this.darkMode,
    required this.profilePhotoBytes,
    required this.onPhotoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfilePhotoPicker(
          radius: 44,
          uploadContext: 'profil pembeli',
          initialBytes: profilePhotoBytes,
          initialImagePath: user?.avatar,
          onPreviewChanged: onPhotoChanged,
        ),
        const SizedBox(height: 12),
        Text(
          user?.name ?? 'Sari Dewi',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: darkMode ? Colors.white : AgriColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          roleLabel,
          style: TextStyle(
            color: darkMode
                ? Colors.white.withValues(alpha: 0.58)
                : AgriColors.textLight,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ActionChips extends StatelessWidget {
  final bool darkMode;
  final VoidCallback onEdit;
  final VoidCallback onPassword;
  final VoidCallback onSupport;

  const _ActionChips({
    required this.darkMode,
    required this.onEdit,
    required this.onPassword,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChipButton(
          icon: Icons.shopping_bag_outlined,
          label: 'Pembeli',
          highlighted: true,
          darkMode: darkMode,
          onTap: onEdit,
        ),
        _ChipButton(
          icon: Icons.lock_outline,
          label: 'Password',
          darkMode: darkMode,
          onTap: onPassword,
        ),
        _ChipButton(
          icon: Icons.support_agent,
          label: 'Bantuan',
          darkMode: darkMode,
          onTap: onSupport,
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final bool darkMode;
  final VoidCallback? onTap;

  const _ChipButton({
    required this.icon,
    required this.label,
    required this.darkMode,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 15,
        color: highlighted
            ? Colors.white
            : darkMode
            ? Colors.white70
            : AgriColors.textLight,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: highlighted
            ? Colors.white
            : darkMode
            ? Colors.white
            : AgriColors.textDark,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      backgroundColor: highlighted
          ? AgriColors.primary
          : darkMode
          ? _PembeliProfilePageState._surfaceSoft
          : Colors.white,
      side: BorderSide(
        color: darkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.06),
      ),
      shape: const StadiumBorder(),
    );
  }
}

class _DarkSection extends StatelessWidget {
  final bool darkMode;
  final List<Widget> children;

  const _DarkSection({required this.darkMode, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: darkMode ? _PembeliProfilePageState._surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: darkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool darkMode;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.darkMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Icon(icon, color: AgriColors.primary, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: darkMode
                    ? Colors.white.withValues(alpha: 0.52)
                    : AgriColors.textLight,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: darkMode ? Colors.white : AgriColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool darkMode;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.darkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: darkMode ? Colors.white70 : AgriColors.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: darkMode ? Colors.white : AgriColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: darkMode
              ? Colors.white.withValues(alpha: 0.48)
              : AgriColors.textLight,
          fontSize: 11,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: darkMode ? Colors.white38 : AgriColors.textLight,
      ),
    );
  }
}
