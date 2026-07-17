import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import 'p2a_form_catat_panen_screen.dart';

// ─────────────────────────────────────────────
//  P2 – Daftar Panen
// ─────────────────────────────────────────────
class P2DaftarPanenScreen extends StatefulWidget {
  const P2DaftarPanenScreen({super.key});

  @override
  State<P2DaftarPanenScreen> createState() => _P2DaftarPanenScreenState();
}

class _P2DaftarPanenScreenState extends State<P2DaftarPanenScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final productCtrl = context.read<ProductController>();
      final sellerId = auth.currentUser?.id;
      if (sellerId != null) {
        productCtrl.loadSellerProducts(sellerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productCtrl = context.watch<ProductController>();
    final products = productCtrl.products;

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
      body: productCtrl.isLoading && products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum ada catatan panen.'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const P2aFormCatatPanenScreen()),
                        ),
                        child: const Text('Catat Panen Baru'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _HarvestCard.fromProduct(product: products[i]),
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
  final ProductModel product;
  const _HarvestCard({required this.product});

  factory _HarvestCard.fromProduct({required ProductModel product}) => _HarvestCard(product: product);

  Color get _statusColor {
    final stock = product.stock;
    if (stock == 0) return const Color(0xFFD92D20);
    if (stock < 20) return const Color(0xFFE9C46A);
    return AgriColors.primaryLight;
  }

  String get _createdLabel {
    if (product.createdAt == null) return '-';
    return _formatDate(product.createdAt!);
  }

  @override
  Widget build(BuildContext context) {
    final name = product.name;
    final created = _createdLabel;
    final stock = product.stock.toString();

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
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$created · $stock unit',
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
              _statusColor == const Color(0xFFD92D20) ? 'Habis' : 'Tersedia',
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

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = <String>['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][date.month - 1];
  final year = date.year;
  return '$day $month $year';
}
