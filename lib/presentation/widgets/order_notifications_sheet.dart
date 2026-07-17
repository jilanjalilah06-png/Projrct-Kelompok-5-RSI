import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../pages/shared/notifications_page.dart';

class OrderNotificationsButton extends StatefulWidget {
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
  State<OrderNotificationsButton> createState() => _OrderNotificationsButtonState();
}

class _OrderNotificationsButtonState extends State<OrderNotificationsButton> {

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthController>().loadNotifications();
      }
    });
    // Start periodic polling every 10 seconds for real-time notification updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && context.read<AuthController>().isLoggedIn) {
        context.read<AuthController>().loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        final int unreadCount = auth.unreadNotificationsCount;
        final hasUnread = widget.showBadge ?? (unreadCount > 0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifikasi',
              onPressed: () => _openNotifications(context),
              icon: Icon(
                Icons.notifications_outlined,
                color: widget.color,
                size: 26,
              ),
            ),
            if (hasUnread && unreadCount > 0)
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
                    color: widget.badgeColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
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
