import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../controllers/auth_controller.dart';
import 'admin_dashboard_screen.dart';
import 'manage_users_screen.dart';
import 'manage_commodities_screen.dart';
import 'reference_prices_screen.dart';
import 'monitor_orders_screen.dart';
import 'aggregate_reports_screen.dart';
import 'activity_logs_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});
  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.people_outline, label: 'Kelola User'),
    _NavItem(icon: Icons.eco_outlined, label: 'Komoditas'),
    _NavItem(icon: Icons.price_change_outlined, label: 'Harga Ref.'),
    _NavItem(icon: Icons.shopping_cart_outlined, label: 'Order'),
    _NavItem(icon: Icons.bar_chart_outlined, label: 'Laporan'),
    _NavItem(icon: Icons.history_outlined, label: 'Log'),
  ];

  final List<Widget> _pages = const [
    AdminDashboardScreen(),
    ManageUsersScreen(),
    ManageCommoditiesScreen(),
    ReferencePricesScreen(),
    MonitorOrdersScreen(),
    AggregateReportsScreen(),
    ActivityLogsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────
          Container(
            width: 200,
            color: AgriColors.primaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.eco, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'AgriConnect',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'ADMIN PANEL',
                        style: TextStyle(
                          color: Color(0xFF74C69D),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF2D6A4F), height: 1),
                const SizedBox(height: 8),

                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _navItems.length,
                    itemBuilder: (context, i) {
                      final item = _navItems[i];
                      final selected = _selectedIndex == i;
                      return _SidebarTile(
                        icon: item.icon,
                        label: item.label,
                        selected: selected,
                        onTap: () => setState(() => _selectedIndex = i),
                      );
                    },
                  ),
                ),

                // Logout
                const Divider(color: Color(0xFF2D6A4F), height: 1),
                _SidebarTile(
                  icon: Icons.logout,
                  label: 'Log Out',
                  selected: false,
                  isLogout: true,
                  onTap: () => Provider.of<AuthController>(
                    context,
                    listen: false,
                  ).executeLogout(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Main content ─────────────────────────────────
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isLogout;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isLogout
        ? const Color(0xFFFF6B6B)
        : selected
        ? Colors.white
        : const Color(0xFFB7E4C7);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2D6A4F) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
