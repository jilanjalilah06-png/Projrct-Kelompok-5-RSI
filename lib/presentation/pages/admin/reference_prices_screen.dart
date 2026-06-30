import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class ReferencePricesScreen extends StatefulWidget {
  const ReferencePricesScreen({super.key});
  @override
  State<ReferencePricesScreen> createState() => _ReferencePricesScreenState();
}

class _ReferencePricesScreenState extends State<ReferencePricesScreen> {
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _prices = [
    {
      'icon': '🌾',
      'name': 'Padi',
      'harga': 'Rp 5.200/kg',
      'tgl': '05 Jun 2026',
      'oleh': 'Admin',
    },
    {
      'icon': '🌽',
      'name': 'Jagung',
      'harga': 'Rp 4.400/kg',
      'tgl': '05 Jun 2026',
      'oleh': 'Admin',
    },
    {
      'icon': '🥬',
      'name': 'Bayam',
      'harga': 'Rp 3.500/kg',
      'tgl': '03 Jun 2026',
      'oleh': 'Admin',
    },
    {
      'icon': '🍅',
      'name': 'Tomat',
      'harga': 'Rp 6.000/kg',
      'tgl': '01 Jun 2026',
      'oleh': 'Admin',
    },
    {
      'icon': '🥕',
      'name': 'Wortel',
      'harga': 'Rp 4.200/kg',
      'tgl': '28 Mei 2026',
      'oleh': 'Admin',
    },
  ];

  final List<Map<String, dynamic>> _history = [
    {
      'icon': '🌾',
      'name': 'Padi',
      'lama': 'Rp 5.000/kg',
      'baru': 'Rp 5.200/kg',
      'tgl': '05 Jun 2026',
      'oleh': 'Admin',
    },
    {
      'icon': '🌽',
      'name': 'Jagung',
      'lama': 'Rp 4.200/kg',
      'baru': 'Rp 4.800/kg',
      'tgl': '05 Jun 2026',
      'oleh': 'Admin',
    },
    {
      'icon': '🍅',
      'name': 'Tomat',
      'lama': 'Rp 5.500/kg',
      'baru': 'Rp 6.000/kg',
      'tgl': '01 Jun 2026',
      'oleh': 'Admin',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _prices
        .where((item) => item['name'] == 'Padi' || item['name'] == 'Jagung')
        .where(
          (p) =>
              _searchCtrl.text.isEmpty ||
              (p['name'] as String).toLowerCase().contains(
                _searchCtrl.text.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Harga Referensi Table ─────────────────────
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SizedBox(
                  width: 280,
                  child: Text(
                    'Harga Referensi Komoditas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.textDark,
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 38,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari komoditas...',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 16,
                        color: AgriColors.textLight,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildTable(
              headers: const [
                'Komoditas',
                'Harga Referensi',
                'Tgl Update',
                'Diupdate Oleh',
                'Aksi',
              ],
              rows: filtered
                  .map(
                    (p) => [
                      Row(
                        children: [
                          Text(p['icon'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            p['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(p['harga'], style: const TextStyle(fontSize: 13)),
                      Text(
                        p['tgl'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.textLight,
                        ),
                      ),
                      Text(
                        p['oleh'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.textLight,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 72,
                            maxWidth: 96,
                          ),
                          child: _UpdateButton(onTap: () {}),
                        ),
                      ),
                    ],
                  )
                  .toList(),
            ),

            const SizedBox(height: 28),

            // ── Riwayat Perubahan Harga ───────────────────
            const Text(
              'Riwayat Perubahan Harga',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            _buildTable(
              headers: const [
                'Komoditas',
                'Harga Lama',
                'Harga Baru',
                'Tanggal',
                'Diupdate Oleh',
              ],
              rows: _history
                  .map(
                    (h) => [
                      Row(
                        children: [
                          Text(h['icon'], style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            h['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        h['lama'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.danger,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        h['baru'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        h['tgl'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.textLight,
                        ),
                      ),
                      Text(
                        h['oleh'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.textLight,
                        ),
                      ),
                    ],
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable({
    required List<String> headers,
    required List<List<Widget>> rows,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: headers
                  .map(
                    (h) => Expanded(
                      child: Text(
                        h,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AgriColors.textLight,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1),
          // Rows
          ...rows.asMap().entries.map(
            (e) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: e.value
                        .map((cell) => Expanded(child: cell))
                        .toList(),
                  ),
                ),
                if (e.key < rows.length - 1) const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _UpdateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AgriColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Update',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
