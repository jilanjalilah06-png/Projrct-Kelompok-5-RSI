import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';
import 'p2a_form_catat_panen_screen.dart';

// ─────────────────────────────────────────────
//  P2 – Daftar Panen
// ─────────────────────────────────────────────
class P2DaftarPanenScreen extends StatelessWidget {
  const P2DaftarPanenScreen({super.key});

  static const List<Map<String, String>> _data = [
    {
      'komoditas': 'Padi Organik',
      'date': '15 Mar 2026',
      'berat': '120 kg',
      'grade': 'Grade A',
      'status': 'Selesai',
    },
    {
      'komoditas': 'Jagung Manis',
      'date': '10 Apr 2026',
      'berat': '80 kg',
      'grade': 'Grade B',
      'status': 'Dijual',
    },
    {
      'komoditas': 'Bayam Merah',
      'date': '1 Mei 2026',
      'berat': '35 kg',
      'grade': 'Grade A',
      'status': 'Selesai',
    },
    {
      'komoditas': 'Tomat Cherry',
      'date': '20 Mei 2026',
      'berat': '50 kg',
      'grade': 'Grade A',
      'status': 'Proses',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Catatan Panen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _data.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _HarvestCard(item: _data[i]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const P2aFormCatatPanenScreen()),
        ),
        backgroundColor: AgriColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '+ Catat Panen Baru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _HarvestCard extends StatelessWidget {
  final Map<String, String> item;
  const _HarvestCard({required this.item});

  Color get _statusColor {
    switch (item['status']) {
      case 'Selesai':
        return AgriColors.primaryLight;
      case 'Dijual':
        return const Color(0xFF4CC9F0);
      case 'Proses':
        return const Color(0xFFE9C46A);
      default:
        return AgriColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              color: AgriColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grass, color: AgriColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['komoditas']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['date']} · ${item['berat']} · ${item['grade']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgriColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item['status']!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _statusColor == const Color(0xFFE9C46A)
                    ? const Color(0xFF9A6E00)
                    : _statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
