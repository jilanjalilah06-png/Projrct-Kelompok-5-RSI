import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constanst/agri_colors.dart';
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
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Center(
            child: Column(
              children: [
                ProfilePhotoPicker(
                  radius: 48,
                  uploadContext: widget.roleLabel,
                  initialBytes: _photoBytes,
                  initialImagePath: widget.user?.avatar,
                  onPreviewChanged: (bytes) {
                    setState(() => _photoBytes = bytes);
                    widget.onPhotoChanged?.call(bytes);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  widget.roleLabel,
                  style: const TextStyle(
                    color: AgriColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _field(
            controller: _nameController,
            label: 'Nama Lengkap',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _phoneController,
            label: 'Nomor Telepon',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _field(
            controller: _addressController,
            label: 'Alamat',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AgriColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AgriColors.primary, width: 1.4),
        ),
      ),
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
