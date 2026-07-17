import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class AggregateReportsScreen extends StatefulWidget {
  const AggregateReportsScreen({super.key});

  @override
  State<AggregateReportsScreen> createState() => _AggregateReportsScreenState();
}

class _AggregateReportsScreenState extends State<AggregateReportsScreen> {
  final _searchCtrl = TextEditingController();

  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
      context.read<AdminController>().loadOrders();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final totalRevenue = admin.dashboard?.totalRevenue ?? 0.0;
    final komisiAdminVal = totalRevenue * 0.1;

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final totalPenjualanStr = formatter.format(totalRevenue);
    final komisiAdminStr = formatter.format(komisiAdminVal);

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LAPORAN',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pantau Penjualan',
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

            // 2 Stat Cards Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                final cardWidth = isNarrow 
                    ? constraints.maxWidth 
                    : (constraints.maxWidth - 16) / 2;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Card 1
                    SizedBox(
                      width: cardWidth,
                      child: _buildStatCard(
                        title: 'TOTAL PENJUALAN KOTOR',
                        value: totalPenjualanStr,
                        subtitle: 'Dari seluruh transaksi penjualan platform',
                        borderColor: const Color(0xFF2C6A4F),
                      ),
                    ),
                    // Card 2
                    SizedBox(
                      width: cardWidth,
                      child: _buildStatCard(
                        title: 'TOTAL KOMISI ADMIN',
                        value: komisiAdminStr,
                        subtitle: 'Komisi 10% dari total penjualan',
                        borderColor: const Color(0xFFB57018),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Section 1: Penjualan per Produk
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  LayoutBuilder(
                    builder: (context, headerConstraints) {
                      final double localWidth = MediaQuery.of(context).size.width;
                      final bool isMobileHeader = localWidth < 600;
                      
                      final titleAndSubtitle = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Penjualan per Produk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Periode Juli 2026 — dana ditahan admin lalu dicairkan ke petani setelah dipotong komisi',
                            style: TextStyle(fontSize: 13, color: _textMuted),
                          ),
                        ],
                      );

                      final downloadButton = ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C6A4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Laporan CSV sedang diunduh...')),
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: const Text(
                          'Unduh Laporan',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      );

                      if (isMobileHeader) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleAndSubtitle,
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: downloadButton,
                            ),
                          ],
                        );
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: titleAndSubtitle),
                          const SizedBox(width: 16),
                          downloadButton,
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 20),

                  LayoutBuilder(
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
                              DataColumn(label: Text('VOLUME TERJUAL', style: _headerStyle)),
                              DataColumn(label: Text('TOTAL PENJUALAN KOTOR', style: _headerStyle)),
                              DataColumn(label: Text('KOMISI ADMIN', style: _headerStyle)),
                              DataColumn(label: Text('DITERIMA PETANI', style: _headerStyle)),
                            ],
                            rows: () {
                              final Map<int, Map<String, dynamic>> productAggregates = {};
                              
                              for (final order in admin.orders) {
                                if (order.status.toLowerCase() == 'completed' || 
                                    order.status.toLowerCase() == 'selesai' || 
                                    order.status.toLowerCase() == 'paid') {
                                  final itemsList = order.items ?? [];
                                  for (final item in itemsList) {
                                    final prodId = item.productId;
                                    final prodName = item.product?['name']?.toString() ?? 'Produk #$prodId';
                                    final sellerName = item.product?['seller']?['name']?.toString() ?? 
                                                       item.product?['seller_name']?.toString() ?? 'Petani';
                                    final qty = item.quantity;
                                    final unit = item.product?['unit']?.toString() ?? 'kg';
                                    final itemTotal = item.totalPrice;
                                    
                                    if (productAggregates.containsKey(prodId)) {
                                      final existing = productAggregates[prodId]!;
                                      existing['quantity'] = (existing['quantity'] as int) + qty;
                                      existing['totalPrice'] = (existing['totalPrice'] as double) + itemTotal;
                                    } else {
                                      productAggregates[prodId] = {
                                        'name': prodName,
                                        'seller': sellerName,
                                        'quantity': qty,
                                        'unit': unit,
                                        'totalPrice': itemTotal,
                                      };
                                    }
                                  }
                                }
                              }

                              final List<DataRow> productRows = [];
                              if (productAggregates.isEmpty) {
                                productRows.add(
                                  DataRow(
                                    cells: [
                                      DataCell(Text(
                                        'Belum ada data penjualan',
                                        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                      )),
                                      const DataCell(Text('-')),
                                      const DataCell(Text('-')),
                                      const DataCell(Text('-')),
                                      const DataCell(Text('-')),
                                      const DataCell(Text('-')),
                                    ],
                                  ),
                                );
                              } else {
                                productAggregates.forEach((id, data) {
                                  final gross = data['totalPrice'] as double;
                                  final commission = gross * 0.1;
                                  final net = gross * 0.9;
                                  
                                  productRows.add(
                                    _buildProdukRow(
                                      data['name'] as String,
                                      data['seller'] as String,
                                      '${data['quantity']} ${data['unit']}',
                                      formatter.format(gross),
                                      formatter.format(commission),
                                      formatter.format(net),
                                      constraints,
                                    ),
                                  );
                                });
                              }
                              return productRows;
                            }(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Tren Komoditas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  const Text(
                    'Tren Komoditas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Perbandingan volume terjual per jenis komoditas — Juli 2026',
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                  const SizedBox(height: 20),

                  LayoutBuilder(
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
                              DataColumn(label: Text('KOMODITAS', style: _headerStyle)),
                              DataColumn(label: Text('TOTAL VOLUME', style: _headerStyle)),
                              DataColumn(label: Text('JUMLAH PRODUK', style: _headerStyle)),
                              DataColumn(label: Text('TREN', style: _headerStyle)),
                            ],
                            rows: () {
                              final Map<String, Map<String, dynamic>> categoryAggregates = {};
                              
                              for (final order in admin.orders) {
                                if (order.status.toLowerCase() == 'completed' || 
                                    order.status.toLowerCase() == 'selesai' || 
                                    order.status.toLowerCase() == 'paid') {
                                  final itemsList = order.items ?? [];
                                  for (final item in itemsList) {
                                    final catName = item.product?['category']?['name']?.toString() ?? 
                                                    (item.product?['name']?.toString().toLowerCase().contains('jagung') == true ? 'Jagung' : 'Beras');
                                    final qty = item.quantity;
                                    final prodId = item.productId;
                                    final unit = item.product?['unit']?.toString() ?? 'kg';
                                    
                                    if (categoryAggregates.containsKey(catName)) {
                                      final existing = categoryAggregates[catName]!;
                                      existing['quantity'] = (existing['quantity'] as int) + qty;
                                      (existing['productIds'] as Set<int>).add(prodId);
                                    } else {
                                      categoryAggregates[catName] = {
                                        'quantity': qty,
                                        'unit': unit,
                                        'productIds': {prodId},
                                      };
                                    }
                                  }
                                }
                              }

                              final List<DataRow> trendRows = [];
                              if (categoryAggregates.isEmpty) {
                                trendRows.add(
                                  DataRow(
                                    cells: [
                                      DataCell(Text(
                                        'Belum ada data tren',
                                        style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                      )),
                                      const DataCell(Text('-')),
                                      const DataCell(Text('-')),
                                      const DataCell(Text('-')),
                                    ],
                                  ),
                                );
                              } else {
                                categoryAggregates.forEach((catName, data) {
                                  final totalVol = '${data['quantity']} ${data['unit']}';
                                  final totalProds = '${(data['productIds'] as Set).length} produk';
                                  
                                  trendRows.add(
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Container(
                                            width: constraints.maxWidth > 600 ? constraints.maxWidth - 480 : null,
                                            child: Text(catName, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        DataCell(Text(totalVol, style: const TextStyle(fontSize: 13, color: _textDark))),
                                        DataCell(Text(totalProds, style: const TextStyle(fontSize: 13, color: _textMuted))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2C6A4F).withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              '▲ Naik',
                                              style: TextStyle(
                                                color: Color(0xFF2C6A4F),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                              }
                              return trendRows;
                            }(),
                    ),
                          ),
                        );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color borderColor,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF90A398),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _textDark,
              fontFamily: 'Georgia',
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildProdukRow(String product, String farmer, String volume, String sales, String commission, String net, BoxConstraints constraints) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            width: constraints.maxWidth > 800 ? constraints.maxWidth - 750 : null,
            child: Text(product, style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 13)),
          ),
        ),
        DataCell(Text(farmer, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13))),
        DataCell(Text(volume, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(Text(sales, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(Text(commission, style: const TextStyle(fontSize: 13, color: Color(0xFFD32F2F)))),
        DataCell(Text(net, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold))),
      ],
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);
