import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/admin_controller.dart';

class ManageCommoditiesScreen extends StatefulWidget {
  const ManageCommoditiesScreen({super.key});

  @override
  State<ManageCommoditiesScreen> createState() =>
      _ManageCommoditiesScreenState();
}

class _ManageCommoditiesScreenState extends State<ManageCommoditiesScreen> {
  // Green themed colors
  static const Color _bg = Color(0xFFF8FAF8);
  static const Color _textDark = Color(0xFF1D2939);
  static const Color _textMuted = Color(0xFF667085);
  static const Color _greenAccent = Color(0xFF2D6A4F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final commodities = admin.products.map(_productToCommodity).toList();
    final premiumCount = commodities
        .where((item) => item['grade'] == 'Premium')
        .length;
    final totalStock = commodities.fold<int>(
      0,
      (sum, item) => sum + (item['stock'] as int),
    );
    final averagePrice = commodities.isEmpty
        ? 0
        : (commodities.fold<int>(
                    0,
                    (sum, item) => sum + (item['price'] as int),
                  ) /
                  commodities.length)
              .round();

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            const Text(
              'DATA KOMODITAS',
              style: TextStyle(
                color: _greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Master Komoditas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Tambah Komoditas',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── 4 Summary stat cards ──────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isTight = constraints.maxWidth < 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: isTight
                          ? (constraints.maxWidth - 16) / 2
                          : (constraints.maxWidth - 48) / 4,
                      child: _MiniStatCard(
                        label: 'Total Komoditas',
                        value: commodities.length.toString(),
                        icon: Icons.eco,
                        color: _greenAccent,
                      ),
                    ),
                    SizedBox(
                      width: isTight
                          ? (constraints.maxWidth - 16) / 2
                          : (constraints.maxWidth - 48) / 4,
                      child: _MiniStatCard(
                        label: 'Produk Premium',
                        value: premiumCount.toString(),
                        icon: Icons.star,
                        color: const Color(0xFFBF9B30),
                      ),
                    ),
                    SizedBox(
                      width: isTight
                          ? (constraints.maxWidth - 16) / 2
                          : (constraints.maxWidth - 48) / 4,
                      child: _MiniStatCard(
                        label: 'Total Stok',
                        value: '$totalStock Kg',
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFF5C6BC0),
                      ),
                    ),
                    SizedBox(
                      width: isTight
                          ? (constraints.maxWidth - 16) / 2
                          : (constraints.maxWidth - 48) / 4,
                      child: _MiniStatCard(
                        label: 'Rata-rata Harga',
                        value: _formatRupiah(averagePrice),
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF12B76A),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Commodity cards grid ──────────────────────
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: commodities.length,
              itemBuilder: (context, i) {
                return _CommodityCard(commodity: commodities[i]);
              },
            ),

            const SizedBox(height: 24),

            // ── Harga Referensi Table ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecor(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Harga Komoditas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF9FAFB),
                      ),
                      columns: const [
                        DataColumn(label: _TH('KOMODITAS')),
                        DataColumn(label: _TH('GRADE')),
                        DataColumn(label: _TH('HARGA/KG')),
                        DataColumn(label: _TH('STOK')),
                        DataColumn(label: _TH('PETANI')),
                        DataColumn(label: _TH('TREN')),
                      ],
                      rows: commodities.map((c) {
                        final isPremium = c['grade'] == 'Premium';
                        final isRising = c['trend'] as bool;
                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    c['icon'] as IconData,
                                    size: 16,
                                    color: _greenAccent,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    c['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(_GradeBadge(isPremium: isPremium)),
                            DataCell(
                              Text(
                                _formatRupiah(c['price'] as int),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '${c['stock']} ${c['unit']}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            DataCell(
                              Text(
                                c['seller'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isRising
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    size: 16,
                                    color: isRising
                                        ? const Color(0xFF12B76A)
                                        : const Color(0xFFF04438),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isRising ? 'Naik' : 'Turun',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isRising
                                          ? const Color(0xFF12B76A)
                                          : const Color(0xFFF04438),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _productToCommodity(ProductModel product) {
    final category = product.category?['name']?.toString() ?? '';
    final seller =
        product.seller?['shop_name']?.toString() ??
        product.seller?['name']?.toString() ??
        'Petani AgriConnect';
    final lowerName = product.name.toLowerCase();
    final isPremium =
        lowerName.contains('premium') ||
        lowerName.contains('grade a') ||
        lowerName.contains('organik') ||
        lowerName.contains('super');

    return {
      'name': product.name,
      'grade': isPremium ? 'Premium' : 'Standar',
      'stock': product.stock,
      'price': product.price.round(),
      'unit': product.unit,
      'icon': category == 'Jagung' ? Icons.eco : Icons.grain,
      'seller': seller,
      'trend': product.id % 4 != 0,
    };
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tambah Komoditas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _greenAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              await context.read<AdminController>().createCategory(
                name: name,
                description: descController.text.trim(),
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Card ────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
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
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF667085),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Commodity Card ────────────────────────────────

class _CommodityCard extends StatelessWidget {
  final Map<String, dynamic> commodity;

  const _CommodityCard({required this.commodity});

  @override
  Widget build(BuildContext context) {
    final isPremium = commodity['grade'] == 'Premium';
    final name = commodity['name'] as String;
    final price = commodity['price'] as int;
    final stock = commodity['stock'] as int;
    final unit = commodity['unit'] as String;
    final seller = commodity['seller'] as String;
    final icon = commodity['icon'] as IconData;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? const Color(0xFFBF9B30).withValues(alpha: 0.3)
              : const Color(0xFFE4E7EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: const Color(0xFFD7FBE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF2D6A4F), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                    Text(
                      seller,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ),
              _GradeBadge(isPremium: isPremium),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(label: 'Stok', value: '$stock $unit'),
              const SizedBox(width: 12),
              _InfoChip(label: 'Harga', value: '${_formatRupiah(price)}/$unit'),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  label: 'Edit',
                  color: const Color(0xFF2D6A4F),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  label: 'Hapus',
                  color: const Color(0xFFF04438),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF98A2B3)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D2939),
          ),
        ),
      ],
    );
  }
}

class _GradeBadge extends StatelessWidget {
  final bool isPremium;
  const _GradeBadge({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium ? const Color(0xFFFFF1B8) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPremium ? '⭐ Premium' : 'Standar',
        style: TextStyle(
          color: isPremium ? const Color(0xFFD46B08) : const Color(0xFF667085),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
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

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF667085),
      letterSpacing: 0.5,
    ),
  );
}

String _formatRupiah(int value) {
  final number = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < number.length; i++) {
    final position = number.length - i;
    buffer.write(number[i]);
    if (position > 1 && position % 3 == 1) buffer.write('.');
  }
  return 'Rp $buffer';
}

BoxDecoration _cardDecor() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: const Color(0xFFE4E7EC)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);
