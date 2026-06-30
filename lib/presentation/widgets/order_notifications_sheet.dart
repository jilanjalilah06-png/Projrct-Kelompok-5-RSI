import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constanst/agri_colors.dart';
import '../../data/models/order_model.dart';
import '../controllers/order_controller.dart';

class OrderNotificationsButton extends StatelessWidget {
  final Color color;
  final Color badgeColor;

  const OrderNotificationsButton({
    super.key,
    this.color = Colors.white,
    this.badgeColor = const Color(0xFFFFD166),
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, controller, _) {
        final hasUnread = controller.orders.any((order) => order.isActive);

        return IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => _openNotifications(context),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: color, size: 26),
              if (hasUnread)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openNotifications(BuildContext context) async {
    final controller = context.read<OrderController>();
    await controller.loadOrders(limit: 10);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => Consumer<OrderController>(
        builder: (context, controller, _) {
          final orders = controller.orders.take(10).toList();

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                if (controller.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (controller.lastError != null)
                  _EmptyNotification(
                    icon: Icons.wifi_off_outlined,
                    message: controller.lastError!,
                  )
                else if (orders.isEmpty)
                  const _EmptyNotification(
                    icon: Icons.notifications_none_outlined,
                    message: 'Belum ada notifikasi pesanan.',
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _OrderNotificationTile(order: orders[index]);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderNotificationTile extends StatelessWidget {
  final OrderModel order;

  const _OrderNotificationTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusLabel = _statusLabel(order.status);
    final createdText = _formatDate(order.createdAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _statusColor(order.status).withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _statusIcon(order.status),
          color: _statusColor(order.status),
          size: 21,
        ),
      ),
      title: Text(
        'Pesanan ${order.orderNumber}',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      subtitle: Text(
        createdText == null ? statusLabel : '$statusLabel - $createdText',
        style: const TextStyle(color: AgriColors.textLight, fontSize: 12),
      ),
      trailing: Text(
        _formatRupiah(order.totalPrice),
        style: const TextStyle(
          color: AgriColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case OrderModel.statusConfirmed:
        return Icons.verified_outlined;
      case OrderModel.statusShipped:
        return Icons.local_shipping_outlined;
      case OrderModel.statusDelivered:
        return Icons.check_circle_outline;
      case OrderModel.statusCancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderModel.statusDelivered:
        return AgriColors.success;
      case OrderModel.statusCancelled:
        return AgriColors.danger;
      case OrderModel.statusShipped:
        return AgriColors.primary;
      case OrderModel.statusConfirmed:
        return AgriColors.primaryLight;
      default:
        return AgriColors.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case OrderModel.statusConfirmed:
        return 'Pesanan dikonfirmasi';
      case OrderModel.statusShipped:
        return 'Pesanan dalam pengiriman';
      case OrderModel.statusDelivered:
        return 'Pesanan selesai';
      case OrderModel.statusCancelled:
        return 'Pesanan dibatalkan';
      default:
        return 'Pesanan baru menunggu konfirmasi';
    }
  }

  String? _formatDate(DateTime? value) {
    if (value == null) return null;
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _formatRupiah(double value) {
    final raw = value.round().toString();
    final buffer = StringBuffer('Rp ');
    for (var i = 0; i < raw.length; i++) {
      if (i != 0 && (raw.length - i) % 3 == 0) buffer.write('.');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}

class _EmptyNotification extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyNotification({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AgriColors.textLight, size: 34),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AgriColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
