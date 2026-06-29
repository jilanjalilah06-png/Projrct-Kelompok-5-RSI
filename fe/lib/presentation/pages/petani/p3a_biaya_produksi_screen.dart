import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

// ─────────────────────────────────────────────
//  P3a – Biaya Produksi (Sub-screen)
//  Tidak ada bottom navigation bar
// ─────────────────────────────────────────────
class P3aBiayaProduksiScreen extends StatefulWidget {
  final String jadwalName;
  const P3aBiayaProduksiScreen({super.key, required this.jadwalName});
  @override
  State<P3aBiayaProduksiScreen> createState() => _P3aBiayaProduksiScreenState();
}

class _P3aBiayaProduksiScreenState extends State<P3aBiayaProduksiScreen> {
  final _bibitCtrl = TextEditingController(text: '150000');
  final _pupukCtrl = TextEditingController(text: '200000');
  final _pestisidaCtrl = TextEditingController(text: '80000');
  final _tkCtrl = TextEditingController(text: '450000');

  int get _total {
    int parse(String v) => int.tryParse(v.replaceAll('.', '')) ?? 0;
    return parse(_bibitCtrl.text) +
        parse(_pupukCtrl.text) +
        parse(_pestisidaCtrl.text) +
        parse(_tkCtrl.text);
  }

  @override
  void dispose() {
    _bibitCtrl.dispose();
    _pupukCtrl.dispose();
    _pestisidaCtrl.dispose();
    _tkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Biaya Produksi',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header jadwal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AgriColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: AgriColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jadwal: ${widget.jadwalName}',
                    style: const TextStyle(
                      color: AgriColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBiayaCard(
              icon: Icons.spa,
              color: const Color(0xFF52B788),
              title: 'Bibit',
              subtitle: 'Benih Padi 9kg',
              controller: _bibitCtrl,
            ),
            const SizedBox(height: 10),
            _buildBiayaCard(
              icon: Icons.science,
              color: const Color(0xFF4CC9F0),
              title: 'Pupuk',
              subtitle: 'Pupuk Urea 50kg',
              controller: _pupukCtrl,
            ),
            const SizedBox(height: 10),
            _buildBiayaCard(
              icon: Icons.bug_report,
              color: const Color(0xFFE9A824),
              title: 'Pestisida',
              subtitle: 'Insektisida 1L',
              controller: _pestisidaCtrl,
            ),
            const SizedBox(height: 10),
            _buildBiayaCard(
              icon: Icons.people,
              color: const Color(0xFF9B5DE5),
              title: 'Tenaga Kerja',
              subtitle: '3 orang × 2 hari',
              controller: _tkCtrl,
            ),
            const SizedBox(height: 16),
            // Total biaya card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AgriColors.primaryDark, AgriColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Biaya',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatRupiah(_total)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Biaya produksi tersimpan!'),
                      backgroundColor: AgriColors.primary,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgriColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  '+ Tambah Biaya',
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
      ),
    );
  }

  Widget _buildBiayaCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AgriColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AgriColors.primary,
              ),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(
                  color: AgriColors.textLight,
                  fontSize: 12,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AgriColors.textLight.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AgriColors.textLight.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AgriColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
