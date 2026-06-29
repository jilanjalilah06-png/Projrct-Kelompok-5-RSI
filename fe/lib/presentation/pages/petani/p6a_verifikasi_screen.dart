import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../controllers/auth_controller.dart';

// ─────────────────────────────────────────────
//  P6a – Verifikasi Petani (Sub-screen)
//  Tidak ada bottom navigation bar
// ─────────────────────────────────────────────
class P6aVerifikasiScreen extends StatefulWidget {
  const P6aVerifikasiScreen({super.key});
  @override
  State<P6aVerifikasiScreen> createState() => _P6aVerifikasiScreenState();
}

class _P6aVerifikasiScreenState extends State<P6aVerifikasiScreen> {
  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _luasCtrl = TextEditingController();
  String? _komoditas;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // Mengambil nama dari akun yang sedang login
    final auth = Provider.of<AuthController>(context, listen: false);
    if (auth.currentUser != null) {
      _namaCtrl.text = auth.currentUser!.name;
    }
  }

  final List<String> _komoditasList = [
    'Padi',
    'Jagung',
    'Bayam',
    'Tomat',
    'Cabai',
    'Singkong',
  ];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _luasCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Verifikasi Petani',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: _submitted ? _buildSuccessView() : _buildFormView(),
    );
  }

  // ── Form View ──────────────────────────────
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE9C46A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Color(0xFF856404), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menunggu Verifikasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF856404),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Data Anda sedang ditinjau oleh petugas pendamping lapangan.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Form card
          _buildCard(
            title: 'Data yang Diperlukan',
            children: [
              _buildFieldLabel('Nama Sesuai KTP'),
              const SizedBox(height: 6),
              _buildTextField(_namaCtrl, hint: ''),
              const SizedBox(height: 14),
              _buildFieldLabel('No. NIK'),
              const SizedBox(height: 6),
              _buildTextField(
                _nikCtrl,
                hint: '32xxxxxxxxxxxxxxxxx',
                type: TextInputType.number,
                maxLength: 16,
              ),
              const SizedBox(height: 14),
              _buildFieldLabel('Luas Lahan (Hektar)'),
              const SizedBox(height: 6),
              _buildTextField(
                _luasCtrl,
                hint: '1.5',
                type: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 14),
              _buildFieldLabel('Komoditas Utama'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _komoditas,
                hint: const Text(
                  '▼  Padi, Jagung...',
                  style: TextStyle(color: AgriColors.textLight, fontSize: 14),
                ),
                decoration: _inputDecoration(),
                items: _komoditasList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _komoditas = v),
              ),
              const SizedBox(height: 14),

              // Upload KTP / Surat Lahan
              _buildUploadBox(
                icon: Icons.upload_file,
                label: '⬆  Upload Foto KTP / Surat Lahan',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AgriColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Kirim untuk Verifikasi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_namaCtrl.text.isEmpty ||
        _nikCtrl.text.isEmpty ||
        _luasCtrl.text.isEmpty ||
        _komoditas == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi semua data terlebih dahulu.'),
          backgroundColor: AgriColors.danger,
        ),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  // ── Success View ───────────────────────────
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AgriColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AgriColors.primary,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data Terkirim!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Permohonan verifikasi Anda sedang diproses.\nBiasanya membutuhkan 1–3 hari kerja.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AgriColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgriColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kembali ke Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────
  Widget _buildCard({required String title, required List<Widget> children}) {
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
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AgriColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AgriColors.textDark,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl, {
    String? hint,
    TextInputType? type,
    int? maxLength,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLength: maxLength,
      decoration: _inputDecoration(hint: hint),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AgriColors.textLight, fontSize: 14),
      filled: true,
      fillColor: AgriColors.background,
      counterText: '',
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

  Widget _buildUploadBox({required IconData icon, required String label}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            color: AgriColors.primary.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
          color: AgriColors.primary.withValues(alpha: 0.04),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AgriColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AgriColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
