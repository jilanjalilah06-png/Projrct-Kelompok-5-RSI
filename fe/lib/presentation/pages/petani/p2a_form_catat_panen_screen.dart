import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

// ─────────────────────────────────────────────
//  P2a – Form Catat Panen (Sub-screen)
//  Tidak ada bottom navigation bar
// ─────────────────────────────────────────────
class P2aFormCatatPanenScreen extends StatefulWidget {
  const P2aFormCatatPanenScreen({super.key});
  @override
  State<P2aFormCatatPanenScreen> createState() =>
      _P2aFormCatatPanenScreenState();
}

class _P2aFormCatatPanenScreenState extends State<P2aFormCatatPanenScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedKomoditas;
  final _tanggalController = TextEditingController();
  final _beratController = TextEditingController();
  String _selectedGrade = 'A';
  final _catatanController = TextEditingController();

  final List<String> _komoditasList = ['Beras', 'Jagung'];

  @override
  void dispose() {
    _tanggalController.dispose();
    _beratController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AgriColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Catat Panen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                children: [
                  _sectionLabel('Komoditas'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedKomoditas,
                    hint: const Text(
                      '▼  Pilih komoditas',
                      style: TextStyle(color: AgriColors.textLight),
                    ),
                    decoration: _inputDecoration(),
                    items: _komoditasList
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedKomoditas = v),
                    validator: (v) => v == null ? 'Wajib dipilih' : null,
                  ),
                  const SizedBox(height: 14),
                  _sectionLabel('Tanggal Panen'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _tanggalController,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: _inputDecoration(
                      hint: 'DD/MM/YYYY',
                      suffix: const Icon(
                        Icons.calendar_today,
                        color: AgriColors.primary,
                        size: 18,
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),
                  _sectionLabel('Berat (kg)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _beratController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '0.00'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 14),
                  _sectionLabel('Kualitas Grade'),
                  const SizedBox(height: 8),
                  Row(
                    children: ['A', 'B', 'C'].map((g) {
                      final sel = _selectedGrade == g;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGrade = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: 48,
                          height: 40,
                          decoration: BoxDecoration(
                            color: sel ? AgriColors.primary : Colors.white,
                            border: Border.all(
                              color: sel
                                  ? AgriColors.primary
                                  : AgriColors.textLight.withValues(alpha: 0.4),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              g,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: sel ? Colors.white : AgriColors.textDark,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  _sectionLabel('Catatan tambahan...'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: _inputDecoration(hint: 'Catatan tambahan...'),
                  ),
                  const SizedBox(height: 14),
                  // Upload foto placeholder
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AgriColors.primary.withValues(alpha: 0.4),
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: AgriColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Upload Foto Panen',
                            style: TextStyle(
                              color: AgriColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Panen berhasil dicatat!'),
                          backgroundColor: AgriColors.primary,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AgriColors.textLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AgriColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AgriColors.textDark,
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AgriColors.textLight, fontSize: 14),
      suffixIcon: suffix,
      filled: true,
      fillColor: AgriColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AgriColors.textLight.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: AgriColors.textLight.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AgriColors.primary, width: 1.5),
      ),
    );
  }
}
