import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constanst/agri_colors.dart';
import '../../core/constanst/api_constants.dart';
import '../controllers/auth_controller.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final double radius;
  final String uploadContext;
  final ValueChanged<XFile>? onSelected;
  final ValueChanged<Uint8List>? onPreviewChanged;
  final Uint8List? initialBytes;
  final String? initialImagePath;
  final Color? avatarBackgroundColor;
  final Color? avatarIconColor;
  final Color? cameraBackgroundColor;
  final Color? cameraIconColor;

  const ProfilePhotoPicker({
    super.key,
    this.radius = 40,
    required this.uploadContext,
    this.onSelected,
    this.onPreviewChanged,
    this.initialBytes,
    this.initialImagePath,
    this.avatarBackgroundColor,
    this.avatarIconColor,
    this.cameraBackgroundColor,
    this.cameraIconColor,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _previewBytes;
  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _previewBytes = widget.initialBytes;
  }

  @override
  void didUpdateWidget(covariant ProfilePhotoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBytes != oldWidget.initialBytes) {
      _previewBytes = widget.initialBytes;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1200,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();
    setState(() {
      _selectedImage = image;
      _previewBytes = bytes;
    });
    widget.onSelected?.call(image);
    widget.onPreviewChanged?.call(bytes);
    await _uploadProfilePhoto(image);
  }

  Future<void> _uploadProfilePhoto(XFile image) async {
    setState(() => _isUploading = true);

    final auth = context.read<AuthController>();
    final ok = await auth.updateProfile(avatar: image);

    if (!mounted) return;
    setState(() => _isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Foto ${widget.uploadContext} berhasil disimpan.'
              : auth.lastError ?? 'Foto profil gagal disimpan.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? null : Colors.red.shade700,
      ),
    );
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari galeri'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil dari kamera'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;
    final imagePath = widget.initialImagePath;
    final ImageProvider? profileImage = _previewBytes != null
        ? MemoryImage(_previewBytes!)
        : imagePath == null || imagePath.isEmpty
        ? null
        : NetworkImage('${ApiConstants.storageUrl}/$imagePath');

    return Semantics(
      button: true,
      label: 'Ganti foto profil',
      child: InkWell(
        onTap: _showSourceSheet,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: diameter + 8,
          height: diameter + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: widget.radius,
                backgroundColor:
                    widget.avatarBackgroundColor ??
                    AgriColors.primary.withValues(alpha: 0.15),
                backgroundImage: profileImage,
                child: profileImage == null
                    ? Icon(
                        Icons.person,
                        size: 42,
                        color: widget.avatarIconColor ?? AgriColors.primary,
                      )
                    : null,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: widget.cameraBackgroundColor ?? AgriColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: _isUploading
                      ? const Padding(
                          padding: EdgeInsets.all(7),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.camera_alt,
                          color: widget.cameraIconColor ?? Colors.white,
                          size: 15,
                        ),
                ),
              ),
              if (_selectedImage != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AgriColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
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
