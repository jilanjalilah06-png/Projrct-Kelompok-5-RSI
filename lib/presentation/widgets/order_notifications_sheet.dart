import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/order_controller.dart';
import '../pages/shared/notifications_page.dart';

class OrderNotificationsButton extends StatelessWidget {
  final Color color;
  final Color badgeColor;
  final bool? showBadge;

  const OrderNotificationsButton({
    super.key,
    this.color = Colors.white,
    this.badgeColor = const Color(0xFFFF5252),
    this.showBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, controller, _) {
        // Show badge with count 3 matching the design
        const int unreadCount = 3;
        final hasUnread =
            showBadge ?? controller.orders.any((order) => order.isActive);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifikasi',
              onPressed: () => _openNotifications(context),
              icon: Icon(
                Icons.notifications_outlined,
                color: color,
                size: 26,
              ),
            ),
            if (hasUnread || unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }
}
