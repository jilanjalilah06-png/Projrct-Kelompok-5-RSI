import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/admin_controller.dart';

class MonitorOrdersScreen extends StatefulWidget {
  const MonitorOrdersScreen({super.key});
  @override
  State<MonitorOrdersScreen> createState() => _MonitorOrdersScreenState();
}

class _MonitorOrdersScreenState extends State<MonitorOrdersScreen> {
  String _filterStatus = 'Semua Status';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() {
    return context.read<AdminController>().loadOrders(
      status: _statusValue(_filterStatus),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderModel.statusPending:
        return AgriColors.warning;
      case OrderModel.statusConfirmed:
      case OrderModel.statusShipped:
        return AgriColors.primary;
      case OrderModel.statusDelivered:
        return AgriColors.success;
      case OrderModel.statusCancelled:
        return AgriColors.danger;
      default:
        return AgriColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final orders = admin.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monitor Order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textDark,
                  ),
                ),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AgriColors.textDark,
                      ),
                      items:
                          [
                                'Semua Status',
                                'Pending',
                                'Dikonfirmasi',
                                'Dikirim',
                                'Selesai',
                                'Dibatalkan',
                              ]
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _filterStatus = v);
                        _loadOrders();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (admin.loading && orders.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (admin.error != null && orders.isEmpty)
              Expanded(
                child: _StatePanel(message: admin.error!, onRetry: _loadOrders),
              )
            else
              Expanded(
                child: Container(
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(child: _TH('ID Order')),
                              Expanded(flex: 2, child: _TH('Pembeli')),
                              Expanded(flex: 2, child: _TH('Produk')),
                              Expanded(child: _TH('Jumlah')),
                              Expanded(child: _TH('Total')),
                              Expanded(child: _TH('Status')),
                              Expanded(child: _TH('Aksi')),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Rows
                        if (orders.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Belum ada order.',
                              style: TextStyle(color: AgriColors.textLight),
                            ),
                          ),
                        ...orders.asMap().entries.map((e) {
                          final o = e.value;
                          final statusColor = _statusColor(o.status);
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        o.orderNumber,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AgriColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        o.buyerName,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        o.productSummary,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        o.quantitySummary,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _formatRupiah(o.totalPrice),
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          _statusLabel(o.status),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _showDetail(context, o),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AgriColors.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            'Detail',
                                            style: TextStyle(
                                              color: AgriColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (e.key < orders.length - 1)
                                const Divider(height: 1),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Detail Order ${order.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Pembeli', order.buyerName),
            _DetailRow('Produk', order.productSummary),
            _DetailRow('Jumlah', order.quantitySummary),
            _DetailRow('Total', _formatRupiah(order.totalPrice)),
            _DetailRow('Alamat', order.shippingAddress),
            _DetailRow('Status', _statusLabel(order.status)),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: order.status,
              decoration: const InputDecoration(labelText: 'Ubah Status'),
              items: const [
                DropdownMenuItem(
                  value: OrderModel.statusPending,
                  child: Text('Pending'),
                ),
                DropdownMenuItem(
                  value: OrderModel.statusConfirmed,
                  child: Text('Dikonfirmasi'),
                ),
                DropdownMenuItem(
                  value: OrderModel.statusShipped,
                  child: Text('Dikirim'),
                ),
                DropdownMenuItem(
                  value: OrderModel.statusDelivered,
                  child: Text('Selesai'),
                ),
                DropdownMenuItem(
                  value: OrderModel.statusCancelled,
                  child: Text('Dibatalkan'),
                ),
              ],
              onChanged: (value) async {
                if (value == null || value == order.status) return;
                await context.read<AdminController>().updateOrderStatus(
                  order.id,
                  value,
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(color: AgriColors.danger)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

String? _statusValue(String label) {
  switch (label) {
    case 'Pending':
      return OrderModel.statusPending;
    case 'Dikonfirmasi':
      return OrderModel.statusConfirmed;
    case 'Dikirim':
      return OrderModel.statusShipped;
    case 'Selesai':
      return OrderModel.statusDelivered;
    case 'Dibatalkan':
      return OrderModel.statusCancelled;
    default:
      return null;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case OrderModel.statusPending:
      return 'Pending';
    case OrderModel.statusConfirmed:
      return 'Dikonfirmasi';
    case OrderModel.statusShipped:
      return 'Dikirim';
    case OrderModel.statusDelivered:
      return 'Selesai';
    case OrderModel.statusCancelled:
      return 'Dibatalkan';
    default:
      return status;
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

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AgriColors.textLight,
    ),
  );
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
            style: const TextStyle(color: AgriColors.textLight, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    ),
  );
}
