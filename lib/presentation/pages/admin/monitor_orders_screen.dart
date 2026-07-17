import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/order_model.dart';
import '../../../core/constanst/api_constants.dart';

class MonitorOrdersScreen extends StatefulWidget {
  const MonitorOrdersScreen({super.key});

  @override
  State<MonitorOrdersScreen> createState() => _MonitorOrdersScreenState();
}

class _MonitorOrdersScreenState extends State<MonitorOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);

  final List<String> _tabs = ['Semua', 'Diproses', 'Ditolak', 'Dikirim', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
      case 'pending':
      case 'confirmed':
        return const Color(0xFF6E7E75); // gray
      case 'dikirim':
      case 'shipped':
        return const Color(0xFFB57018); // orange/brown
      case 'ditolak':
      case 'cancelled':
        return const Color(0xFFD32F2F); // red
      case 'selesai':
      case 'delivered':
        return const Color(0xFF2C6A4F); // green
      default:
        return const Color(0xFF6E7E75);
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
      case 'diproses':
        return 'Diproses';
      case 'shipped':
      case 'dikirim':
        return 'Dikirim';
      case 'cancelled':
      case 'ditolak':
        return 'Ditolak';
      case 'delivered':
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final dbOrders = admin.orders;



    // Map DB orders to our layout if they exist
    List<Map<String, dynamic>> displayedOrders = [];
    if (dbOrders.isNotEmpty) {
      displayedOrders = dbOrders.map((o) {
        return {
          'id': o.orderNumber,
          'pembeli': o.buyerName,
          'petani': o.productSummary.split(' oleh ').length > 1 ? o.productSummary.split(' oleh ').last : 'Petani',
          'total': 'Rp ${_formatRupiah(o.totalPrice)}',
          'tanggal': '02 Jul 2026', // realistic fallback
          'status': _statusLabel(o.status),
          'raw': o,
        };
      }).toList();
    } else {
      displayedOrders = [];
    }

    // Filter by tab
    final currentTab = _tabs[_tabController.index];
    if (currentTab != 'Semua') {
      displayedOrders = displayedOrders.where((o) => o['status'] == currentTab).toList();
    }

    // Filter by search
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      displayedOrders = displayedOrders.where((o) {
        return o['id'].toString().toLowerCase().contains(q) ||
            o['pembeli'].toString().toLowerCase().contains(q) ||
            o['petani'].toString().toLowerCase().contains(q);
      }).toList();
    }

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        color: const Color(0xFF079447),
        onRefresh: () async {
          await context.read<AdminController>().loadOrders();
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
                  'Pesanan',
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

            // Card Table Container
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
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black38,
                    indicatorColor: Colors.black,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                    tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    '$currentTab Pesanan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Status ditentukan oleh petani masing-masing — admin memantau dan mengelola pencairan dana',
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Data Table
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
                              DataColumn(label: Text('ID PESANAN', style: _headerStyle)),
                              DataColumn(label: Text('PEMBELI', style: _headerStyle)),
                              DataColumn(label: Text('PETANI', style: _headerStyle)),
                              DataColumn(label: Text('TOTAL', style: _headerStyle)),
                              DataColumn(label: Text('TANGGAL', style: _headerStyle)),
                              DataColumn(label: Text('STATUS', style: _headerStyle)),
                              DataColumn(label: Text('ACTION', style: _headerStyle)),
                            ],
                      rows: displayedOrders.isEmpty
                          ? [
                              DataRow(
                                cells: [
                                  const DataCell(Text('-')),
                                  const DataCell(Text('-')),
                                  DataCell(Text(
                                    'Belum ada pesanan',
                                    style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                  )),
                                  const DataCell(Text('-')),
                                  const DataCell(Text('-')),
                                  const DataCell(Text('-')),
                                  const DataCell(Text('-')),
                                ],
                              ),
                            ]
                          : displayedOrders.map((o) {
                        final status = o['status'].toString();
                        final statusColor = _statusColor(status);

                        return DataRow(
                          cells: [
                            DataCell(
                              Container(
                                width: constraints.maxWidth > 800 ? constraints.maxWidth - 750 : null,
                                child: Text(o['id'].toString(), style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            DataCell(Text(o['pembeli'].toString(), style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                            DataCell(Text(o['petani'].toString(), style: const TextStyle(fontSize: 13, color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                            DataCell(Text(o['total'].toString(), style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold))),
                            DataCell(Text(o['tanggal'].toString(), style: const TextStyle(fontSize: 13, color: _textDark))),
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
                            DataCell(
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black26),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: () {
                                  if (o['raw'] != null) {
                                    _showDetail(context, o['raw'] as OrderModel);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Detail untuk pesanan ${o['id']}')),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Detail',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
      ),
    );
  }

  void _showDetail(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedStatus = order.status;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (stateContext, setState) {
            return AlertDialog(
              title: Text('Detail Order ${order.orderNumber}'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow('Pembeli', order.buyerName),
                      _DetailRow('Produk', order.productSummary),
                      _DetailRow('Jumlah', order.quantitySummary),
                      _DetailRow('Total', 'Rp ${_formatRupiah(order.totalPrice)}'),
                      _DetailRow('Alamat', order.shippingAddress),
                      _DetailRow('Status', _statusLabel(order.status)),
                      if (order.buyerRating != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Rating: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                            Row(
                              children: List.generate(5, (index) => Icon(
                                index < order.buyerRating! ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              )),
                            ),
                          ],
                        ),
                      ],
                      if (order.buyerReview != null && order.buyerReview!.isNotEmpty)
                        _DetailRow('Ulasan', order.buyerReview!),
                      if (order.deliveryProof != null && order.deliveryProof!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Bukti Foto:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${ApiConstants.storageUrl}/${order.deliveryProof}',
                            fit: BoxFit.cover,
                            height: 120,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                    Builder(
                      builder: (builderContext) {
                        final dropdownItems = [
                          const DropdownMenuItem(value: OrderModel.statusPending, child: Text('Pending/Diproses')),
                          const DropdownMenuItem(value: OrderModel.statusConfirmed, child: Text('Dikonfirmasi')),
                          const DropdownMenuItem(value: 'accept', child: Text('Diterima')),
                          const DropdownMenuItem(value: 'packing', child: Text('Dikemas')),
                          const DropdownMenuItem(value: 'dikirim', child: Text('Dikirim (Kurir)')),
                          const DropdownMenuItem(value: 'dalam perjalanan', child: Text('Dalam Perjalanan')),
                          const DropdownMenuItem(value: OrderModel.statusShipped, child: Text('Shipped')),
                          const DropdownMenuItem(value: OrderModel.statusDelivered, child: Text('Selesai')),
                          const DropdownMenuItem(value: OrderModel.statusCancelled, child: Text('Dibatalkan')),
                        ];

                        final hasValue = dropdownItems.any((item) => item.value == selectedStatus);
                        if (!hasValue && selectedStatus != null) {
                          dropdownItems.add(DropdownMenuItem(value: selectedStatus, child: Text(selectedStatus!)));
                        }

                        return DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(labelText: 'Ubah Status'),
                          items: dropdownItems,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedStatus = value;
                              });
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Tutup'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF132A1D),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (selectedStatus == order.status) {
                            Navigator.pop(dialogContext);
                            return;
                          }
                          
                          setState(() {
                            isSaving = true;
                          });
                          
                          try {
                            await context.read<AdminController>().updateOrderStatus(
                              order.id,
                              selectedStatus,
                            );
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Status pesanan berhasil disimpan')),
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal menyimpan status: $e')),
                              );
                            }
                          } finally {
                            if (dialogContext.mounted) {
                              setState(() {
                                isSaving = false;
                              });
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatRupiah(double value) {
    final number = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      final position = number.length - i;
      buffer.write(number[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(color: Color(0xFF6E7E75), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);
