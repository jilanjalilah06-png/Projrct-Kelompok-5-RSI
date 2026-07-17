import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/admin_controller.dart';
import 'admin_produk_detail_screen.dart';
import '../../../core/constanst/api_constants.dart';

class AdminProdukScreen extends StatefulWidget {
  const AdminProdukScreen({super.key});

  @override
  State<AdminProdukScreen> createState() => _AdminProdukScreenState();
}

class _AdminProdukScreenState extends State<AdminProdukScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final products = admin.products;

    // Filter products based on tabs and search
    final searchQuery = _searchCtrl.text.toLowerCase();
    var filtered = products.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(searchQuery) ||
          (p.seller?['name']?.toString() ?? '').toLowerCase().contains(searchQuery);
      return matchesSearch;
    }).toList();

    // Group counts for display
    final totalCount = filtered.length;
    final pendingCount = filtered.where((p) => p.status == 'tinjau').length;
    final rejectedCount = filtered.where((p) => p.status == 'ditolak').length;

    List<ProductModel> displayProducts;
    if (_tabController.index == 0) {
      displayProducts = filtered;
    } else if (_tabController.index == 1) {
      displayProducts = filtered.where((p) => p.status == 'tinjau').toList();
    } else {
      displayProducts = filtered.where((p) => p.status == 'ditolak').toList();
    }

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        color: const Color(0xFF079447),
        onRefresh: () async {
          await context.read<AdminController>().loadCategories();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MARKETPLACE',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Produk',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Card Container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab Bar matching the screenshot design
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFECE6DA))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: _textDark,
                      labelColor: _textDark,
                      unselectedLabelColor: _textMuted,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                      tabs: [
                        Tab(text: 'Semua ($totalCount)'),
                        Tab(text: 'Tinjau ($pendingCount)'),
                        Tab(text: 'Ditolak ($rejectedCount)'),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Produk di Marketplace',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dikelola oleh seluruh petani mitra',
                          style: TextStyle(
                            fontSize: 13,
                            color: _textMuted,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Table
                        admin.loading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                      child: DataTable(
                                        horizontalMargin: 8,
                                        columnSpacing: 24,
                                        headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
                                        columns: const [
                                          DataColumn(label: Text('PRODUK', style: _headerStyle)),
                                          DataColumn(label: Text('PETANI', style: _headerStyle)),
                                          DataColumn(label: Text('STOK', style: _headerStyle)),
                                          DataColumn(label: Text('HARGA/KG', style: _headerStyle)),
                                          DataColumn(label: Text('STATUS', style: _headerStyle)),
                                          DataColumn(label: Text('ACTION', style: _headerStyle)),
                                        ],
                                        rows: _buildProductRows(displayProducts, constraints),
                                      ),
                                    ),
                                  );
                                }
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  List<DataRow> _buildProductRows(List<dynamic> productsList, BoxConstraints constraints) {
    // If no products returned, display seeded/mock products matching screenshot
    final List<Map<String, dynamic>> items = [];

    // First populate from the database products
    for (var p in productsList) {
      final sellerName = p.seller?['name']?.toString() ?? 'Pak Yono';
      final isPremium = p.name.toLowerCase().contains('premium') || p.id % 2 == 0;
      
      String statusDisplay = 'Tinjau';
      if (p.status == 'public') {
        statusDisplay = 'Public';
      } else if (p.status == 'ditolak') {
        statusDisplay = 'Ditolak';
      }

      items.add({
        'id': p.id,
        'name': p.name,
        'grade': isPremium ? 'Premium' : 'Standar',
        'seller': sellerName,
        'stock': '${p.stock} kg',
        'price': 'Rp ${_formatRupiahValue(p.price.round())}',
        'status': statusDisplay,
        'isActionTinjau': p.status == 'tinjau' || p.status == 'ditolak',
        'model': p,
      });
    }

    // No mock products - show empty state when DB has no products

    return items.map((item) {
      final name = item['name'] as String;
      final grade = item['grade'] as String;
      final seller = item['seller'] as String;
      final stock = item['stock'] as String;
      final price = item['price'] as String;
      final status = item['status'] as String;
      final isActionTinjau = item['isActionTinjau'] as bool;
      final model = item['model'] as ProductModel;

      Color statusColor = const Color(0xFF2C6A4F);
      Color bgColor = statusColor.withValues(alpha: 0.1);
      
      if (status == 'Tinjau') {
        bgColor = const Color(0xFFFFF3CD);
        statusColor = const Color(0xFF856404);
      } else if (status == 'Ditolak') {
        statusColor = const Color(0xFFD32F2F);
        bgColor = statusColor.withValues(alpha: 0.1);
      }

      return DataRow(
        cells: [
          // PRODUK
          DataCell(
            Container(
              width: constraints.maxWidth > 800 ? constraints.maxWidth - 680 : null,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   ClipRRect(
                     borderRadius: BorderRadius.circular(6),
                     child: model.image != null && model.image!.isNotEmpty
                         ? Image.network(
                             '${ApiConstants.storageUrl}/${model.image}',
                             width: 28,
                             height: 28,
                             fit: BoxFit.cover,
                             errorBuilder: (_, __, ___) => Container(
                               width: 28,
                               height: 28,
                               color: Colors.amber.shade50,
                               child: const Icon(Icons.eco, color: Colors.amber, size: 16),
                             ),
                           )
                         : Container(
                             width: 28,
                             height: 28,
                             color: Colors.amber.shade50,
                             child: const Icon(Icons.eco, color: Colors.amber, size: 16),
                           ),
                   ),
                   const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          grade,
                          style: const TextStyle(color: _textMuted, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // PETANI
          DataCell(Text(seller, style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold))),
          // STOK
          DataCell(Text(stock, style: const TextStyle(fontSize: 13, color: _textDark))),
          // HARGA/KG
          DataCell(Text(price, style: const TextStyle(fontSize: 13, color: _textDark))),
          // STATUS
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // ACTION
          DataCell(
            isActionTinjau
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProdukDetailScreen(product: model),
                        ),
                      );
                    },
                    child: const Text(
                      'Tinjau',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black26),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminProdukDetailScreen(product: model),
                        ),
                      );
                    },
                    child: const Text(
                      'Kelola',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      );
    }).toList();
  }

  String _formatRupiahValue(int value) {
    final number = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      final position = number.length - i;
      buffer.write(number[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);
