import 'package:flutter/material.dart';

import '../../../core/constanst/agri_colors.dart';

enum NotificationKind { order, promo, shipping, message, sale }

class NotificationItem {
  final NotificationKind kind;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;

  const NotificationItem({
    required this.kind,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isUnread = false,
  });
}

class NotificationsPage extends StatefulWidget {
  final List<NotificationItem> notifications;

  const NotificationsPage({super.key, this.notifications = const []});

  static const _green = Color(0xFF159447);
  static const _greenDark = Color(0xFF0D7A3A);
  static const _background = Color(0xFFF2F8F2);
  static const _title = Color(0xFF0B1F3A);
  static const _body = Color(0xFF667085);
  static const _muted = Color(0xFF98A2B3);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<NotificationItem> _notifications;

  // Default buyer notifications matching the design
  static const List<NotificationItem> _defaultNotifications = [
    NotificationItem(
      kind: NotificationKind.order,
      title: 'Pesanan Diproses',
      message:
          'Pesanan #AGR-2024001 sedang diproses oleh penjual.',
      timeAgo: '2 menit lalu',
      isUnread: true,
    ),
    NotificationItem(
      kind: NotificationKind.promo,
      title: 'Promo Spesial!',
      message:
          'Dapatkan diskon 20% untuk pembelian beras hari ini. Jangan sampai kehabisan!',
      timeAgo: '1 jam lalu',
      isUnread: true,
    ),
    NotificationItem(
      kind: NotificationKind.shipping,
      title: 'Pesanan Dikirim',
      message:
          'Pesanan #AGR-2024000 sedang dalam perjalanan ke alamat Anda.',
      timeAgo: 'Kemarin',
      isUnread: true,
    ),
    NotificationItem(
      kind: NotificationKind.message,
      title: 'Pesan dari Pak Budi',
      message:
          '"Stok beras pandan masih tersedia. Silakan lanjutkan pembelian."',
      timeAgo: '2 hari lalu',
      isUnread: false,
    ),
    NotificationItem(
      kind: NotificationKind.sale,
      title: 'Flash Sale Dimulai!',
      message:
          'Flash sale jagung manis mulai sekarang. Stok terbatas, segera beli!',
      timeAgo: '3 hari lalu',
      isUnread: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _notifications = widget.notifications.isEmpty
        ? List.from(_defaultNotifications)
        : List.from(widget.notifications);
  }

  int get _unreadCount =>
      _notifications.where((n) => n.isUnread).length;

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications
          .map(
            (n) => NotificationItem(
              kind: n.kind,
              title: n.title,
              message: n.message,
              timeAgo: n.timeAgo,
              isUnread: false,
            ),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotificationsPage._background,
      body: SafeArea(
        child: Column(
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NotificationsPage._greenDark,
                    NotificationsPage._green,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Notifikasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: Text(
                      'Tandai semua dibaca',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Unread count banner
            if (_unreadCount > 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: NotificationsPage._green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: NotificationsPage._green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: NotificationsPage._green,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$_unreadCount notifikasi belum dibaca',
                      style: const TextStyle(
                        color: NotificationsPage._green,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            // Notification list
            Expanded(
              child: _notifications.isEmpty
                  ? const _EmptyNotifications()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _NotificationCard(
                          item: _notifications[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(item.kind);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: item.isUnread
            ? Border.all(
                color: NotificationsPage._green.withValues(alpha: 0.25),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: meta.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(meta.icon, color: meta.color, size: 22),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: NotificationsPage._title,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(
                    color: NotificationsPage._body,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.timeAgo,
                  style: const TextStyle(
                    color: NotificationsPage._muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Unread dot
          if (item.isUnread)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: NotificationsPage._green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  _NotificationMeta _metaFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.order:
        return const _NotificationMeta(
          icon: Icons.inventory_2_outlined,
          color: Color(0xFF079447),
          background: Color(0xFFD7FBE5),
        );
      case NotificationKind.promo:
        return const _NotificationMeta(
          icon: Icons.local_offer_outlined,
          color: Color(0xFFFF9800),
          background: Color(0xFFFFF3E0),
        );
      case NotificationKind.shipping:
        return const _NotificationMeta(
          icon: Icons.local_shipping_outlined,
          color: Color(0xFF1D63FF),
          background: Color(0xFFDCEBFF),
        );
      case NotificationKind.message:
        return const _NotificationMeta(
          icon: Icons.chat_bubble_outline,
          color: Color(0xFFFF7800),
          background: Color(0xFFFFEBCF),
        );
      case NotificationKind.sale:
        return const _NotificationMeta(
          icon: Icons.flash_on_outlined,
          color: Color(0xFFFF3147),
          background: Color(0xFFFFDDDF),
        );
    }
  }
}

class _NotificationMeta {
  final IconData icon;
  final Color color;
  final Color background;

  const _NotificationMeta({
    required this.icon,
    required this.color,
    required this.background,
  });
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AgriColors.textLight,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NotificationsPage._title,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Notifikasi dari aktivitas pembeli dan petani akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NotificationsPage._body,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
