import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';

import '../../../core/constanst/agri_colors.dart';

enum NotificationKind { order, promo, shipping, message, sale }

class NotificationItem {
  final int id;
  final NotificationKind kind;
  final String title;
  final String message;
  final String timeAgo;
  final bool isUnread;

  const NotificationItem({
    required this.id,
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
  static const _muted = Color(0xFF98A2B3);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().loadNotifications();
    });
  }

  NotificationKind _parseKind(String? type) {
    switch (type) {
      case 'order':
        return NotificationKind.order;
      case 'promo':
        return NotificationKind.promo;
      case 'shipping':
        return NotificationKind.shipping;
      case 'message':
        return NotificationKind.message;
      case 'sale':
        return NotificationKind.sale;
      default:
        return NotificationKind.order;
    }
  }

  String _formatTime(String? createdAtStr, bool isEnglish) {
    if (createdAtStr == null) return '';
    try {
      final dateTime = DateTime.parse(createdAtStr).toLocal();
      final difference = DateTime.now().difference(dateTime);

      if (difference.inSeconds < 60) {
        return isEnglish ? 'Just now' : 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return isEnglish 
            ? '${difference.inMinutes}m ago' 
            : '${difference.inMinutes} menit lalu';
      } else if (difference.inHours < 24) {
        return isEnglish 
            ? '${difference.inHours}h ago' 
            : '${difference.inHours} jam lalu';
      } else if (difference.inDays < 30) {
        return isEnglish 
            ? '${difference.inDays}d ago' 
            : '${difference.inDays} hari lalu';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (_) {
      return '';
    }
  }

  List<NotificationItem> _mapNotifications(List<Map<String, dynamic>> rawList, bool isEnglish) {
    return rawList.map((item) {
      final isRead = item['is_read'];
      final bool unread = isRead == 0 || isRead == false || isRead == '0' || isRead == null;
      return NotificationItem(
        id: item['id'] as int? ?? 0,
        kind: _parseKind(item['type'] as String?),
        title: item['title'] as String? ?? '',
        message: item['message'] as String? ?? '',
        timeAgo: _formatTime(item['created_at'] as String?, isEnglish),
        isUnread: unread,
      );
    }).toList();
  }

  void _markAllAsRead() {
    context.read<AuthController>().markAllNotificationsRead();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF2F8F2);

    return Consumer<AuthController>(
      builder: (context, auth, child) {
        final rawNotifications = auth.notifications;
        final notifications = _mapNotifications(rawNotifications, isEnglish);
        final unreadCount = auth.unreadNotificationsCount;

        return Scaffold(
          backgroundColor: bgColor,
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
                        tooltip: isEnglish ? 'Back' : 'Kembali',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          isEnglish ? 'Notifications' : 'Notifikasi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: _markAllAsRead,
                          child: Text(
                            isEnglish ? 'Mark all as read' : 'Tandai semua dibaca',
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

                // Loader / Unread count banner
                if (auth.isLoading && notifications.isEmpty)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(NotificationsPage._green),
                      ),
                    ),
                  )
                else ...[
                  if (unreadCount > 0)
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
                          const Icon(
                            Icons.notifications_active_outlined,
                            color: NotificationsPage._green,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEnglish 
                                ? '$unreadCount unread notifications' 
                                : '$unreadCount notifikasi belum dibaca',
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
                    child: notifications.isEmpty
                        ? const _EmptyNotifications()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                            itemCount: notifications.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _NotificationCard(item: notifications[index]);
                            },
                          ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const _NotificationCard({required this.item});

  void _showDetailBottomSheet(BuildContext context, NotificationItem item, _NotificationMeta meta) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleTextColor = isDark ? Colors.white : const Color(0xFF0B1F3A);
    final bodyTextColor = isDark ? const Color(0xFFD0D0D0) : const Color(0xFF667085);
    final dividerColor = isDark ? Colors.white24 : Colors.grey.shade100;
    final isEnglish = context.read<LanguageController>().isEnglish;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: meta.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(meta.icon, color: meta.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.kind.name.toUpperCase(),
                          style: TextStyle(
                            color: meta.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white60 : Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                item.title,
                style: TextStyle(
                  color: titleTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: dividerColor, height: 1),
              const SizedBox(height: 20),
              Text(
                item.message,
                style: TextStyle(
                  color: bodyTextColor,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NotificationsPage._green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isEnglish ? 'Close' : 'Tutup',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0B1F3A);
    final bodyColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085);
    final meta = _metaFor(item.kind);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showDetailBottomSheet(context, item, meta);
          if (item.isUnread) {
            context.read<AuthController>().markNotificationRead(item.id);
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
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
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        color: bodyColor,
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
        ),
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
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0B1F3A);
    final bodyColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
                color: cardColor,
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
            Text(
              isEnglish ? 'No notifications yet' : 'Belum ada notifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isEnglish
                  ? 'Notifications from buyer and farmer activities will appear here.'
                  : 'Notifikasi dari aktivitas pembeli dan petani akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bodyColor,
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
