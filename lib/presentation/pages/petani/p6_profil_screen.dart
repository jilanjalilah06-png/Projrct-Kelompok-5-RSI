import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/user_model.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../widgets/profile_photo_picker.dart';
import '../shared/edit_profile_page.dart';
import '../pembeli/profile/pengaturan_page.dart';
import '../pembeli/profile/hubungi_kami_page.dart';
import 'p6a_verifikasi_screen.dart';

class P6ProfilScreen extends StatefulWidget {
  const P6ProfilScreen({super.key});

  @override
  State<P6ProfilScreen> createState() => _P6ProfilScreenState();
}

class _P6ProfilScreenState extends State<P6ProfilScreen> {
  bool _notifJadwal = true;
  bool _notifOrder = true;
  Uint8List? _profilePhotoBytes;

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF001A3D);
  static const _muted = Color(0xFF98A2B3);
  static const _danger = Color(0xFFFF3147);

  String _t(String key, bool isEnglish) {
    final translations = {
      'email': {'id': 'Email', 'en': 'Email'},
      'no_hp': {'id': 'No. HP', 'en': 'Phone No.'},
      'lokasi': {'id': 'Lokasi', 'en': 'Location'},
      'pengingat': {'id': 'Pengingat jadwal panen', 'en': 'Harvest schedule reminder'},
      'order_masuk': {'id': 'Order masuk', 'en': 'Incoming orders'},
      'info_harga': {'id': 'Info harga komoditas', 'en': 'Commodity price info'},
      'akun_terverifikasi': {'id': 'Akun terverifikasi', 'en': 'Verified account'},
      'verifikasi_akun': {'id': 'Verifikasi akun', 'en': 'Verify account'},
      'terverifikasi_sub': {'id': 'Identitas dan lahan telah diverifikasi', 'en': 'Identity and land have been verified'},
      'verifikasi_sub': {'id': 'Lengkapi data verifikasi petani', 'en': 'Complete farmer verification details'},
      'ganti_password': {'id': 'Ganti Password', 'en': 'Change Password'},
      'keamanan_sub': {'id': 'Perbarui keamanan akun', 'en': 'Update account security'},
      'pengaturan': {'id': 'Pengaturan', 'en': 'Settings'},
      'pengaturan_sub': {'id': 'Bahasa, tema, dan lainnya', 'en': 'Language, theme, and others'},
      'hubungi_kami': {'id': 'Hubungi Kami', 'en': 'Contact Us'},
      'hubungi_kami_sub': {'id': 'CS 24/7 siap membantu', 'en': '24/7 Support ready to help'},
      'keluar': {'id': 'Keluar', 'en': 'Logout'},
      'password_lama': {'id': 'Password lama', 'en': 'Old password'},
      'password_baru': {'id': 'Password baru', 'en': 'New password'},
      'simpan_password': {'id': 'Simpan Password', 'en': 'Save Password'},
      'password_berhasil': {'id': 'Password berhasil diperbarui.', 'en': 'Password successfully updated.'},
    };
    return translations[key]?[isEnglish ? 'en' : 'id'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final langCtrl = context.watch<LanguageController>();
    final isEnglish = langCtrl.isEnglish;
    final user = auth.currentUser;
    final isVerified = user?.isVerified ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenBgColor = isDark ? const Color(0xFF121212) : _background;
    final logoutBtnBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final logoutBtnBorder = isDark ? Colors.white10 : const Color(0xFFFFDADD);

    return Scaffold(
      backgroundColor: screenBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onEdit: () => _openEditProfilePage(context, user)),
            Expanded(
              child: RefreshIndicator(
                color: _green,
                onRefresh: () async {
                  // Nothing to fetch here
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                        label: _t('email', isEnglish),
                        value: user?.email ?? 'budi@mail.com',
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: _t('no_hp', isEnglish),
                        value: user?.phone ?? '0856-5820-2442',
                      ),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: _t('lokasi', isEnglish),
                        value: user?.address ?? 'Bandung',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    children: [
                      _SwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: _t('pengingat', isEnglish),
                        value: _notifJadwal,
                        onChanged: (value) {
                          setState(() => _notifJadwal = value);
                        },
                      ),
                      _SwitchTile(
                        icon: Icons.shopping_bag_outlined,
                        title: _t('order_masuk', isEnglish),
                        value: _notifOrder,
                        onChanged: (value) {
                          setState(() => _notifOrder = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    children: [
                      _MenuTile(
                        icon: Icons.verified_user_outlined,
                        title: isVerified ? _t('akun_terverifikasi', isEnglish) : _t('verifikasi_akun', isEnglish),
                        subtitle: isVerified
                            ? _t('terverifikasi_sub', isEnglish)
                            : _t('verifikasi_sub', isEnglish),
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
                        title: _t('ganti_password', isEnglish),
                        subtitle: _t('keamanan_sub', isEnglish),
                        onTap: () => _showPasswordSheet(context, isEnglish),
                      ),
                      _MenuTile(
                        icon: Icons.phone_outlined,
                        title: _t('hubungi_kami', isEnglish),
                        subtitle: _t('hubungi_kami_sub', isEnglish),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HubungiKamiPage(),
                          ),
                        ),
                      ),
                      _MenuTile(
                        icon: Icons.settings_outlined,
                        title: _t('pengaturan', isEnglish),
                        subtitle: _t('pengaturan_sub', isEnglish),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PengaturanPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => auth.executeLogout(),
                      icon: const Icon(Icons.logout, size: 20),
                      label: Text(_t('keluar', isEnglish)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _danger,
                        backgroundColor: logoutBtnBg,
                        side: BorderSide(color: logoutBtnBorder),
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
            ),
          ],
        ),
      ),
    );
  }

  void _openEditProfilePage(BuildContext context, UserModel? user) {
    final isEnglish = context.read<LanguageController>().isEnglish;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(
          title: isEnglish ? 'Edit Farmer Profile' : 'Edit Profil Petani',
          roleLabel: isEnglish ? 'Farmer Profile' : 'Profil Petani',
          user: user,
          profilePhotoBytes: _profilePhotoBytes,
          onPhotoChanged: (bytes) => setState(() => _profilePhotoBytes = bytes),
        ),
      ),
    );
  }

  void _showPasswordSheet(BuildContext context, bool isEnglish) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    
    bool sheetLoading = false;
    String? sheetError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            MediaQuery.of(dialogCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('ganti_password', isEnglish),
                style: TextStyle(
                  color: isDark ? Colors.white : _title,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _PasswordField(
                label: _t('password_lama', isEnglish),
                controller: oldCtrl,
              ),
              const SizedBox(height: 12),
              _PasswordField(
                label: _t('password_baru', isEnglish),
                controller: newCtrl,
              ),
              const SizedBox(height: 12),
              _PasswordField(
                label: isEnglish ? 'Confirm New Password' : 'Konfirmasi Password Baru',
                controller: confirmCtrl,
              ),
              if (sheetError != null) ...[
                const SizedBox(height: 8),
                Text(
                  sheetError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: sheetLoading
                      ? null
                      : () async {
                          final oldPw = oldCtrl.text.trim();
                          final newPw = newCtrl.text.trim();
                          final confirmPw = confirmCtrl.text.trim();

                          if (oldPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
                            setSheetState(() => sheetError = isEnglish ? 'All fields must be filled' : 'Semua kolom harus diisi');
                            return;
                          }
                          if (newPw.length < 6) {
                            setSheetState(() => sheetError = isEnglish ? 'New password must be at least 6 characters' : 'Kata sandi baru minimal 6 karakter');
                            return;
                          }
                          if (newPw != confirmPw) {
                            setSheetState(() => sheetError = isEnglish ? 'Passwords do not match' : 'Konfirmasi kata sandi tidak cocok');
                            return;
                          }

                          setSheetState(() {
                            sheetLoading = true;
                            sheetError = null;
                          });

                          try {
                            final auth = context.read<AuthController>();
                            final success = await auth.changePassword(
                              oldPassword: oldPw,
                              newPassword: newPw,
                            );
                            if (!success) {
                              throw Exception(auth.lastError ?? (isEnglish ? 'Failed to update password' : 'Gagal memperbarui kata sandi'));
                            }
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_t('password_berhasil', isEnglish)),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: _green,
                                ),
                              );
                            }
                          } catch (e) {
                            setSheetState(() => sheetError = e.toString().replaceFirst('Exception: ', ''));
                          } finally {
                            setSheetState(() => sheetLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: sheetLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _t('simpan_password', isEnglish),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
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
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 60,
      color: isDark ? const Color(0xFF1E1E1E) : _P6ProfilScreenState._green,
      padding: const EdgeInsets.only(left: 20, right: 8),
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
          Expanded(
            child: Text(
              isEnglish ? 'Farmer Profile' : 'Profil Petani',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: isEnglish ? 'Edit Profile' : 'Edit profil',
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
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _P6ProfilScreenState._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _P6ProfilScreenState._muted;

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
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.role ?? (isEnglish ? 'Farmer' : 'Petani'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: mutedColor,
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
              label: isVerified 
                  ? (isEnglish ? 'Verified' : 'Terverifikasi') 
                  : (isEnglish ? 'Verify' : 'Verifikasi'),
              highlighted: true,
              onTap: onVerify,
            ),
            _ChipButton(
              icon: Icons.edit_outlined,
              label: isEnglish ? 'Edit' : 'Edit',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        icon,
        size: 17,
        color: highlighted ? Colors.white : _P6ProfilScreenState._green,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: highlighted ? Colors.white : (isDark ? Colors.white : _P6ProfilScreenState._title),
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
      backgroundColor:
          highlighted ? _P6ProfilScreenState._green : (isDark ? const Color(0xFF1B3D2B) : const Color(0xFFD7FBE5)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.10),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _P6ProfilScreenState._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _P6ProfilScreenState._muted;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Row(
        children: [
          Icon(icon, color: _P6ProfilScreenState._green, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: TextStyle(
              color: mutedColor,
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
              style: TextStyle(
                color: titleColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _P6ProfilScreenState._title;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: _P6ProfilScreenState._green,
      activeTrackColor: isDark ? const Color(0xFF1B3D2B) : const Color(0xFFD7FBE5),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : _P6ProfilScreenState._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _P6ProfilScreenState._muted;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: _P6ProfilScreenState._green, size: 23),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: mutedColor,
          fontSize: 12,
        ),
      ),
      trailing: onTap == null
          ? null
          : Icon(Icons.chevron_right, color: mutedColor),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;

  const _PasswordField({required this.label, this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085);
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: const Icon(Icons.lock_outline),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
