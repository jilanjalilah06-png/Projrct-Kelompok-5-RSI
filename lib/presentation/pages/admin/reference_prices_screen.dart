import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constanst/agri_colors.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/admin_controller.dart';

class ReferencePricesScreen extends StatefulWidget {
  const ReferencePricesScreen({super.key});

  @override
  State<ReferencePricesScreen> createState() => _ReferencePricesScreenState();
}

class _ReferencePricesScreenState extends State<ReferencePricesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadReferencePrices();
    });
  }

  Future<void> _loadPrices() {
    return context.read<AdminController>().loadReferencePrices();
  }

  void _showUpdateDialog(ProductModel product) {
    final priceController = TextEditingController(
      text: product.price.round().toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Harga ${product.name}'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Harga per ${product.unit}',
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(
                priceController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
              );
              if (value == null) return;

              await context.read<AdminController>().updateProductPrice(
                product.id,
                value,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final products = admin.products;
    final recentUpdates = [...products]
      ..sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
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
              ],
            ),
            const SizedBox(height: 14),
            if (admin.loading && products.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (admin.error != null && products.isEmpty)
              _StatePanel(message: admin.error!, onRetry: _loadPrices)
            else
              _buildTable(
                headers: const [
                  'Produk',
                  'Harga Referensi',
                  'Stok',
                  'Tgl Update',
                  'Diupdate Oleh',
                  'Aksi',
                ],
                rows: products
                    .map(
                      (product) => [
                        Row(
                          children: [
                            const Icon(
                              Icons.eco,
                              size: 16,
                              color: AgriColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                product.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_formatRupiah(product.price)}/${product.unit}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          '${product.stock} ${product.unit}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          _formatDate(product.updatedAt ?? product.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AgriColors.textLight,
                          ),
                        ),
                        Text(
                          product.seller?['name']?.toString() ?? 'Admin',
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
                            child: _UpdateButton(
                              onTap: () => _showUpdateDialog(product),
                            ),
                          ),
                        ),
                      ],
                    )
                    .toList(),
              ),
            const SizedBox(height: 28),
            const Text(
              'Update Produk Terakhir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            _buildTable(
              headers: const [
                'Produk',
                'Harga Saat Ini',
                'Tanggal',
                'Pemilik Produk',
              ],
              rows: recentUpdates
                  .take(8)
                  .map(
                    (product) => [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${_formatRupiah(product.price)}/${product.unit}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(product.updatedAt ?? product.createdAt),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AgriColors.textLight,
                        ),
                      ),
                      Text(
                        product.seller?['name']?.toString() ?? '-',
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
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(22),
              child: Text(
                'Tidak ada data.',
                style: TextStyle(color: AgriColors.textLight),
              ),
            ),
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

class _StatePanel extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _StatePanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: AgriColors.danger)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
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

String _formatRupiah(double value) {
  final number = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < number.length; i++) {
    final position = number.length - i;
    buffer.write(number[i]);
    if (position > 1 && position % 3 == 1) buffer.write('.');
  }
  return 'Rp $buffer';
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
