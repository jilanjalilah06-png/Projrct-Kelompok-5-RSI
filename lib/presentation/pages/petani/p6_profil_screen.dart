import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constanst/agri_colors.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/profile_photo_picker.dart';
import '../shared/edit_profile_page.dart';
import 'p6a_verifikasi_screen.dart';

class P6ProfilScreen extends StatefulWidget {
  const P6ProfilScreen({super.key});

  @override
  State<P6ProfilScreen> createState() => _P6ProfilScreenState();
}

class _P6ProfilScreenState extends State<P6ProfilScreen> {
  bool _notifJadwal = true;
  bool _notifOrder = true;
  bool _notifHarga = false;
  bool _darkMode = true;
  Uint8List? _profilePhotoBytes;

  static const Color _surface = Color(0xFF17191D);
  static const Color _surfaceSoft = Color(0xFF22252B);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final isVerified = user?.isVerified ?? true;
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
              title: 'Profil Petani',
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
              roleLabel: user?.role ?? 'Petani',
              darkMode: _darkMode,
              profilePhotoBytes: _profilePhotoBytes,
              onPhotoChanged: (bytes) =>
                  setState(() => _profilePhotoBytes = bytes),
            ),
            const SizedBox(height: 12),
            _ActionChips(
              darkMode: _darkMode,
              isVerified: isVerified,
              onVerify: isVerified
                  ? null
                  : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const P6aVerifikasiScreen(),
                      ),
                    ),
              onEdit: () => _openEditProfilePage(context, user),
              onPassword: () => _showPasswordSheet(context),
            ),
            const SizedBox(height: 18),
            _DarkSection(
              darkMode: _darkMode,
              children: [
                _InfoTile(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? 'budi@mail.com',
                  darkMode: _darkMode,
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  label: 'No. HP',
                  value: user?.phone ?? '0812-3456-7890',
                  darkMode: _darkMode,
                ),
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'Lokasi',
                  value: user?.address ?? 'Bandung',
                  darkMode: _darkMode,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DarkSection(
              darkMode: _darkMode,
              children: [
                _SwitchTile(
                  icon: Icons.notifications_active_outlined,
                  title: 'Pengingat jadwal panen',
                  value: _notifJadwal,
                  darkMode: _darkMode,
                  onChanged: (v) => setState(() => _notifJadwal = v),
                ),
                _SwitchTile(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Order masuk (stok)',
                  value: _notifOrder,
                  darkMode: _darkMode,
                  onChanged: (v) => setState(() => _notifOrder = v),
                ),
                _SwitchTile(
                  icon: Icons.show_chart,
                  title: 'Info harga komoditas',
                  value: _notifHarga,
                  darkMode: _darkMode,
                  onChanged: (v) => setState(() => _notifHarga = v),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DarkSection(
              darkMode: _darkMode,
              children: [
                _MenuTile(
                  icon: Icons.verified_user_outlined,
                  title: isVerified ? 'Akun terverifikasi' : 'Verifikasi akun',
                  subtitle: isVerified
                      ? 'Identitas dan lahan telah diverifikasi'
                      : 'Lengkapi data verifikasi petani',
                  darkMode: _darkMode,
                  onTap: isVerified
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const P6aVerifikasiScreen(),
                          ),
                        ),
                ),
                _MenuTile(
                  icon: Icons.lock_outline,
                  title: 'Ganti Password',
                  subtitle: 'Perbarui keamanan akun',
                  darkMode: _darkMode,
                  onTap: () => _showPasswordSheet(context),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => auth.executeLogout(),
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
          title: 'Edit Profil Petani',
          roleLabel: 'Profil Petani',
          user: user,
          profilePhotoBytes: _profilePhotoBytes,
          onPhotoChanged: (bytes) => setState(() => _profilePhotoBytes = bytes),
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
          uploadContext: 'profil petani',
          initialBytes: profilePhotoBytes,
          initialImagePath: user?.avatar,
          onPreviewChanged: onPhotoChanged,
        ),
        const SizedBox(height: 12),
        Text(
          user?.name ?? 'Budi Santoso',
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
  final bool isVerified;
  final VoidCallback? onVerify;
  final VoidCallback onEdit;
  final VoidCallback onPassword;

  const _ActionChips({
    required this.darkMode,
    required this.isVerified,
    required this.onVerify,
    required this.onEdit,
    required this.onPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChipButton(
          icon: isVerified ? Icons.verified : Icons.pending_outlined,
          label: isVerified ? 'Terverifikasi' : 'Verifikasi',
          highlighted: true,
          darkMode: darkMode,
          onTap: onVerify,
        ),
        _ChipButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          darkMode: darkMode,
          onTap: onEdit,
        ),
        _ChipButton(
          icon: Icons.lock_outline,
          label: 'Password',
          darkMode: darkMode,
          onTap: onPassword,
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
          ? _P6ProfilScreenState._surfaceSoft
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
        color: darkMode ? _P6ProfilScreenState._surface : Colors.white,
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

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.darkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final bool darkMode;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.darkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      dense: true,
      activeThumbColor: AgriColors.primary,
      activeTrackColor: AgriColors.primaryLight.withValues(alpha: 0.34),
      inactiveThumbColor: Colors.white70,
      title: Text(
        title,
        style: TextStyle(
          color: darkMode ? Colors.white : AgriColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      secondary: Icon(
        icon,
        color: darkMode ? Colors.white70 : AgriColors.primary,
        size: 19,
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool darkMode;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.darkMode,
    this.onTap,
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
      trailing: onTap == null
          ? null
          : Icon(
              Icons.chevron_right,
              color: darkMode ? Colors.white38 : AgriColors.textLight,
            ),
    );
  }
}
