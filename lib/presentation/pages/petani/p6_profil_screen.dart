import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  Uint8List? _profilePhotoBytes;

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF001A3D);
  static const _muted = Color(0xFF98A2B3);
  static const _danger = Color(0xFFFF3147);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final isVerified = user?.isVerified ?? true;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onEdit: () => _openEditProfilePage(context, user)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  _ProfileCard(
                    user: user,
                    isVerified: isVerified,
                    profilePhotoBytes: _profilePhotoBytes,
                    onPhotoChanged: (bytes) {
                      setState(() => _profilePhotoBytes = bytes);
                    },
                    onVerify: isVerified
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const P6aVerifikasiScreen(),
                            ),
                          ),
                    onEdit: () => _openEditProfilePage(context, user),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    children: [
                      _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? 'budi@mail.com',
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'No. HP',
                        value: user?.phone ?? '0856-5820-2442',
                      ),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Lokasi',
                        value: user?.address ?? 'Bandung',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    children: [
                      _SwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Pengingat jadwal panen',
                        value: _notifJadwal,
                        onChanged: (value) {
                          setState(() => _notifJadwal = value);
                        },
                      ),
                      _SwitchTile(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Order masuk',
                        value: _notifOrder,
                        onChanged: (value) {
                          setState(() => _notifOrder = value);
                        },
                      ),
                      _SwitchTile(
                        icon: Icons.show_chart,
                        title: 'Info harga komoditas',
                        value: _notifHarga,
                        onChanged: (value) {
                          setState(() => _notifHarga = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    children: [
                      _MenuTile(
                        icon: Icons.verified_user_outlined,
                        title: isVerified ? 'Akun terverifikasi' : 'Verifikasi akun',
                        subtitle: isVerified
                            ? 'Identitas dan lahan telah diverifikasi'
                            : 'Lengkapi data verifikasi petani',
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
                        onTap: () => _showPasswordSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => auth.executeLogout(),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Keluar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _danger,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFFFDADD)),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          22,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ganti Password',
              style: TextStyle(
                color: _title,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            const _PasswordField(label: 'Password lama'),
            const SizedBox(height: 12),
            const _PasswordField(label: 'Password baru'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password berhasil diperbarui.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Simpan Password',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onEdit;

  const _Header({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: _P6ProfilScreenState._green,
      padding: const EdgeInsets.only(left: 20, right: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Profil Petani',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Edit profil',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserModel? user;
  final bool isVerified;
  final Uint8List? profilePhotoBytes;
  final ValueChanged<Uint8List> onPhotoChanged;
  final VoidCallback? onVerify;
  final VoidCallback onEdit;

  const _ProfileCard({
    required this.user,
    required this.isVerified,
    required this.profilePhotoBytes,
    required this.onPhotoChanged,
    required this.onVerify,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      children: [
        ProfilePhotoPicker(
          radius: 48,
          uploadContext: 'profil petani',
          initialBytes: profilePhotoBytes,
          initialImagePath: user?.avatar,
          onPreviewChanged: onPhotoChanged,
        ),
        const SizedBox(height: 14),
        Text(
          user?.name ?? 'Budi Santoso',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _P6ProfilScreenState._title,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.role ?? 'Petani',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _P6ProfilScreenState._muted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            _ChipButton(
              icon: isVerified ? Icons.verified : Icons.pending_outlined,
              label: isVerified ? 'Terverifikasi' : 'Verifikasi',
              highlighted: true,
              onTap: onVerify,
            ),
            _ChipButton(
              icon: Icons.edit_outlined,
              label: 'Edit',
              onTap: onEdit,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback? onTap;

  const _ChipButton({
    required this.icon,
    required this.label,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 17,
        color: highlighted ? Colors.white : _P6ProfilScreenState._green,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: highlighted ? Colors.white : _P6ProfilScreenState._title,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
      backgroundColor:
          highlighted ? _P6ProfilScreenState._green : const Color(0xFFD7FBE5),
      side: BorderSide.none,
      shape: const StadiumBorder(),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const _SectionCard({
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        children: [
          Icon(icon, color: _P6ProfilScreenState._green, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: _P6ProfilScreenState._muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _P6ProfilScreenState._title,
                fontSize: 15,
                fontWeight: FontWeight.w800,
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
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: _P6ProfilScreenState._green,
      activeTrackColor: const Color(0xFFD7FBE5),
      title: Text(
        title,
        style: const TextStyle(
          color: _P6ProfilScreenState._title,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      secondary: Icon(icon, color: _P6ProfilScreenState._green, size: 22),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: _P6ProfilScreenState._green, size: 23),
      title: Text(
        title,
        style: const TextStyle(
          color: _P6ProfilScreenState._title,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: _P6ProfilScreenState._muted,
          fontSize: 12,
        ),
      ),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right, color: _P6ProfilScreenState._muted),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;

  const _PasswordField({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
