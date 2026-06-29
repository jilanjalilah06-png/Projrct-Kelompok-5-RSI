import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class ManageCommoditiesScreen extends StatefulWidget {
  const ManageCommoditiesScreen({super.key});
  @override
  State<ManageCommoditiesScreen> createState() =>
      _ManageCommoditiesScreenState();
}

class _ManageCommoditiesScreenState extends State<ManageCommoditiesScreen> {
  final List<Map<String, dynamic>> _commodities = [
    {'name': 'Padi', 'icon': '🌾', 'stok': '30 ton', 'harga': 'Rp 5.200/kg'},
    {'name': 'Jagung', 'icon': '🌽', 'stok': '40 kg', 'harga': 'Rp 4.400/kg'},
    {'name': 'Bayam', 'icon': '🥬', 'stok': '25 kg', 'harga': 'Rp 3.500/kg'},
    {'name': 'Tomat', 'icon': '🍅', 'stok': '60 ton', 'harga': 'Rp 6.000/kg'},
    {'name': 'Wortel', 'icon': '🥕', 'stok': '35 ton', 'harga': 'Rp 4.200/kg'},
  ];

  void _showDeleteDialog(String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Komoditas'),
        content: Text('Yakin ingin menghapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AgriColors.danger),
            onPressed: () {
              setState(
                () => _commodities.removeWhere((c) => c['name'] == name),
              );
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCommodities = _commodities
        .where((item) => item['name'] == 'Padi' || item['name'] == 'Jagung')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SizedBox(
                  width: 260,
                  child: Text(
                    'Master Komoditas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.textDark,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AgriColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Tambah Komoditas',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: visibleCommodities.length,
                itemBuilder: (context, i) {
                  final c = visibleCommodities[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              c['icon'],
                              style: const TextStyle(fontSize: 22),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              c['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AgriColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stok: ${c['stok']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AgriColors.textLight,
                          ),
                        ),
                        Text(
                          'Harga ref: ${c['harga']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AgriColors.textLight,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: _CmdButton(
                                label: 'Edit',
                                color: AgriColors.primary,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _CmdButton(
                                label: 'Hapus',
                                color: AgriColors.danger,
                                onTap: () => _showDeleteDialog(c['name']),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CmdButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CmdButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
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
