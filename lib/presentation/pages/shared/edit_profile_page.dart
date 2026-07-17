import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/profile_photo_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String title;
  final String roleLabel;
  final UserModel? user;
  final Uint8List? profilePhotoBytes;
  final ValueChanged<Uint8List>? onPhotoChanged;

  const EditProfilePage({
    super.key,
    required this.title,
    required this.roleLabel,
    this.user,
    this.profilePhotoBytes,
    this.onPhotoChanged,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _deepGreen = Color(0xFF195912);
  static const _leafGreen = Color(0xFF2B6D20);
  static const _fieldGreen = Color(0xFF8FBE78);
  static const _softGreen = Color(0xFFEAF4E8);
  static const _cream = Color(0xFFFBF7EF);
  static const _gold = Color(0xFFFFA51A);
  static const _olive = Color(0xFF848B35);
  static const _textGreen = Color(0xFF286627);

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  Uint8List? _photoBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _photoBytes = widget.profilePhotoBytes;
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _addressController = TextEditingController(
      text: widget.user?.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final name = widget.user?.name.trim().isNotEmpty == true
        ? widget.user!.name
        : 'Budi Santoso';
    final role = (widget.user?.role ?? widget.roleLabel)
        .replaceFirst('Profil ', '')
        .toUpperCase();
    final roleTitle = widget.title.replaceFirst('Edit ', '');
    final isVerified = widget.user?.isVerified ?? true;
    final since = widget.user?.createdAt?.year.toString() ?? '2019';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: Stack(
        children: [
          Container(height: 420, color: isDark ? const Color(0xFF1A3D18) : _deepGreen),
          Positioned(
            top: -76,
            right: -48,
            child: _LeafShape(
              width: 148,
              height: 310,
              angle: -0.08,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            top: 34,
            left: -88,
            child: _LeafShape(
              width: 96,
              height: 245,
              angle: -0.22,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Positioned(top: 328, left: 60, child: _Dot(size: 6, opacity: 0.06)),
          Positioned(top: 350, right: 92, child: _Dot(size: 8, opacity: 0.07)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: _TopBar(
                    title: roleTitle,
                    onBack: () => Navigator.maybePop(context),
                  ),
                ),
                const SizedBox(height: 36),
                ProfilePhotoPicker(
                  radius: 68,
                  uploadContext: widget.roleLabel.toLowerCase(),
                  initialBytes: _photoBytes,
                  initialImagePath: widget.user?.avatar,
                  avatarBackgroundColor: _olive,
                  avatarIconColor: Colors.white.withValues(alpha: 0.82),
                  cameraBackgroundColor: _gold,
                  onPreviewChanged: (bytes) {
                    setState(() => _photoBytes = bytes);
                    widget.onPhotoChanged?.call(bytes);
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  role,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.68),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.7,
                  ),
                ),
                const SizedBox(height: 38),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        14,
                        26,
                        14,
                        bottomInset + 24,
                      ),
                      children: [
                        Center(
                          child: _VerifiedBadge(
                            label: isVerified
                                ? '$role TERVERIFIKASI'
                                : '$role BELUM TERVERIFIKASI',
                          ),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            const Expanded(
                              child: _StatCard(
                                value: '3.2 Ha',
                                label: 'Lahan Aktif',
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 68,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              color: isDark ? Colors.white10 : const Color(0xFFE2ECE0),
                            ),
                            const Expanded(
                              child: _StatCard(
                                value: '4x',
                                label: 'Musim Panen',
                                highlighted: true,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 68,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              color: isDark ? Colors.white10 : const Color(0xFFE2ECE0),
                            ),
                            Expanded(
                              child: _StatCard(value: since, label: 'Sejak'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFE7EEE5)),
                        const SizedBox(height: 24),
                        _field(
                          controller: _nameController,
                          label: 'NAMA LENGKAP',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 22),
                        _field(
                          controller: _emailController,
                          label: 'ALAMAT EMAIL',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 22),
                        _field(
                          controller: _phoneController,
                          label: 'NOMOR TELEPON',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 22),
                        _field(
                          controller: _addressController,
                          label: 'ALAMAT',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 78,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _saveProfile,
                            icon: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                : const Icon(Icons.eco_outlined, size: 24),
                            label: const Text('Simpan Perubahan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _leafGreen,
                              disabledBackgroundColor: _leafGreen.withValues(
                                alpha: 0.62,
                              ),
                              foregroundColor: Colors.white,
                              elevation: 10,
                              shadowColor: _leafGreen.withValues(alpha: 0.24),
                              textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Data Anda dilindungi & aman - AgriConnect 2026',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _fieldGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white70 : _textGreen;
    final inputBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final borderSideColor = isDark ? Colors.white10 : const Color(0xFFD6E8D1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.6,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: textColor,
            fontSize: 23,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 18, right: 12),
              child: Icon(icon, color: _fieldGreen, size: 26),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 62),
            filled: true,
            fillColor: inputBg,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 22,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: borderSideColor,
                width: 1.6,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: borderSideColor,
                width: 1.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: _fieldGreen, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);

    final auth = context.read<AuthController>();
    final ok = await auth.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Profil berhasil disimpan.'
              : auth.lastError ?? 'Profil gagal disimpan.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? null : Colors.red.shade700,
      ),
    );

    if (ok) {
      Navigator.pop(context);
    }
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.chevron_left,
          tooltip: 'Kembali',
          onPressed: onBack,
        ),
        const SizedBox(width: 16),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.eco_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'AgriConnect',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 32),
      style: IconButton.styleFrom(
        fixedSize: const Size(54, 54),
        backgroundColor: Colors.white.withValues(alpha: 0.14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final String label;

  const _VerifiedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeBg = isDark ? const Color(0xFF1E351F) : _EditProfilePageState._softGreen;
    final badgeBorder = isDark ? Colors.white10 : const Color(0xFFC9DEC3);
    final textColor = isDark ? const Color(0xFF76D275) : _EditProfilePageState._leafGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: badgeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 18,
            color: textColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool highlighted;

  const _StatCard({
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = highlighted
        ? (isDark ? const Color(0xFF2E241A) : _EditProfilePageState._cream)
        : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F6F1));
    final valueColor = highlighted
        ? (isDark ? const Color(0xFFFFB03A) : _EditProfilePageState._gold)
        : (isDark ? Colors.white : _EditProfilePageState._textGreen);
    final labelColor = isDark ? Colors.white70 : _EditProfilePageState._textGreen;

    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor,
              fontSize: 24,
              fontFamily: 'serif',
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: labelColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafShape extends StatelessWidget {
  final double width;
  final double height;
  final double angle;
  final Color color;

  const _LeafShape({
    required this.width,
    required this.height,
    required this.angle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(width),
            topRight: Radius.circular(width * 0.6),
            bottomLeft: Radius.circular(width * 0.55),
            bottomRight: Radius.circular(width),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final double opacity;

  const _Dot({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
