import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/planting_schedule_controller.dart';
import '../../controllers/language_controller.dart';

class P3bPemetaanLahanScreen extends StatefulWidget {
  const P3bPemetaanLahanScreen({super.key});

  @override
  State<P3bPemetaanLahanScreen> createState() => _P3bPemetaanLahanScreenState();
}

class _P3bPemetaanLahanScreenState extends State<P3bPemetaanLahanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlantingScheduleController>().loadLands();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _sizeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _openMap(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map app.')),
        );
      }
    }
  }

  void _showAddLandSheet(BuildContext context, bool isEnglish) {
    _nameCtrl.clear();
    _latCtrl.clear();
    _lngCtrl.clear();
    _sizeCtrl.clear();
    _descCtrl.clear();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final labelColor = isDark ? Colors.white : const Color(0xFF001A3D);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                22,
                24,
                22,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEnglish ? 'Register New Land' : 'Daftarkan Lahan Baru',
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetCtx),
                          icon: const Icon(Icons.close, color: Colors.grey, size: 26),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameCtrl,
                      label: isEnglish ? 'Land Name' : 'Nama Lahan',
                      hint: 'e.g. Sawah Timur A',
                      validator: (v) => v == null || v.isEmpty ? (isEnglish ? 'Name required' : 'Nama wajib diisi') : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _latCtrl,
                            label: 'Latitude',
                            hint: 'e.g. -7.123456',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final double? val = double.tryParse(v);
                              if (val == null || val < -90 || val > 90) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _lngCtrl,
                            label: 'Longitude',
                            hint: 'e.g. 110.123456',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final double? val = double.tryParse(v);
                              if (val == null || val < -180 || val > 180) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _sizeCtrl,
                      label: isEnglish ? 'Area Size' : 'Luas Lahan',
                      hint: 'e.g. 1.5 Hektar',
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _descCtrl,
                      label: isEnglish ? 'Description' : 'Deskripsi',
                      hint: isEnglish ? 'Additional info' : 'Info tambahan lahan',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final scheduleController = context.read<PlantingScheduleController>();
                            final success = await scheduleController.createLand(
                              name: _nameCtrl.text,
                              latitude: double.parse(_latCtrl.text),
                              longitude: double.parse(_lngCtrl.text),
                              areaSize: _sizeCtrl.text.isEmpty ? null : _sizeCtrl.text,
                              description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
                            );

                            if (success && mounted) {
                              Navigator.pop(sheetCtx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEnglish ? 'Land registered successfully.' : 'Lahan berhasil didaftarkan.'),
                                  backgroundColor: const Color(0xFF2D832F),
                                ),
                              );
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(scheduleController.lastError ?? 'Failed to register land')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D832F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEnglish ? 'Register Land' : 'Daftar Lahan',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7);
    final inputColor = isDark ? Colors.white : const Color(0xFF001A3D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: inputColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(color: inputColor, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: fieldBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<PlantingScheduleController>();

    final screenBg = isDark ? const Color(0xFF121212) : const Color(0xFFEFF8EF);
    final headerBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D832F);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF001A3D);

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Rice Field Mapping' : 'Pemetaan Lahan Sawah',
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: headerBg,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLandSheet(context, isEnglish),
        backgroundColor: const Color(0xFF2D832F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt),
        label: Text(isEnglish ? 'Register Land' : 'Daftar Lahan'),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.lands.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        isEnglish ? 'No lands registered yet.' : 'Belum ada lahan terdaftar.',
                        style: TextStyle(
                          color: isDark ? Colors.grey : const Color(0xFF667085),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.lands.length,
                  separatorBuilder: (_, ___) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final land = controller.lands[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1B3D2B) : const Color(0xFFE7F4E8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.landscape, color: Color(0xFF2D832F)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      land.name,
                                      style: TextStyle(
                                        color: titleColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (land.areaSize != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${isEnglish ? "Area Size" : "Luas"}: ${land.areaSize}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(isEnglish ? 'Delete Land?' : 'Hapus Lahan?'),
                                      content: Text(
                                        isEnglish
                                            ? 'Are you sure you want to delete ${land.name}?'
                                            : 'Apakah Anda yakin ingin menghapus lahan ${land.name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: Text(isEnglish ? 'Cancel' : 'Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: Text(isEnglish ? 'Delete' : 'Hapus'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && mounted) {
                                    final messenger = ScaffoldMessenger.of(context);
                                    final success = await context.read<PlantingScheduleController>().deleteLand(land.id);
                                    if (success) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(isEnglish ? 'Land deleted.' : 'Lahan berhasil dihapus.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                              ),
                            ],
                          ),
                          if (land.description != null && land.description!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              land.description!,
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : const Color(0xFF667085),
                                fontSize: 14,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.gps_fixed, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Lat: ${land.latitude.toStringAsFixed(6)}, Lng: ${land.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    color: isDark ? Colors.grey : const Color(0xFF475467),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: OutlinedButton.icon(
                              onPressed: () => _openMap(land.latitude, land.longitude),
                              icon: const Icon(Icons.map, size: 18),
                              label: Text(isEnglish ? 'Open Google Maps' : 'Buka Google Maps'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2D832F),
                                side: const BorderSide(color: Color(0xFF2D832F)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
