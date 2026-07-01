import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import 'admin_dashboard_screen.dart';
import 'manage_users_screen.dart';
import 'manage_commodities_screen.dart';
import 'admin_pemasaran_screen.dart';
import 'admin_harga_log_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});
  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Dark green sidebar colors matching the design
  static const Color _sidebarBg = Color(0xFF1B3A2D);
  static const Color _sidebarText = Color(0xFFB7E4C7);
  static const Color _sidebarAccent = Color(0xFF74C69D);
  static const Color _sidebarDivider = Color(0xFF2D6A4F);

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
    _NavItem(icon: Icons.storefront_outlined, label: 'Pemasaran'),
    _NavItem(icon: Icons.people_alt_outlined, label: 'Kelola User'),
    _NavItem(icon: Icons.eco_outlined, label: 'Komoditas'),
    _NavItem(icon: Icons.bar_chart_outlined, label: 'Harga & Log'),
  ];

  List<Widget> get _pages => const [
    AdminDashboardScreen(),
    AdminPemasaranScreen(),
    ManageUsersScreen(),
    ManageCommoditiesScreen(),
    AdminHargaLogScreen(),
  ];

  String get _currentTitle => _navItems[_selectedIndex].label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Row(
        children: [
          // ── Sidebar (Desktop) ──────────────────────────
          _buildSidebar(),

          // ── Main content ─────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: _sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _sidebarAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco, color: _sidebarAccent, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AgriAdmin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Manajemen Pertanian',
                        style: TextStyle(
                          color: _sidebarAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _sidebarDivider, height: 1),
          const SizedBox(height: 12),

          // Menu label
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'MENU UTAMA',
              style: TextStyle(
                color: _sidebarText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
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

          // Admin profile at bottom
          const Divider(color: _sidebarDivider, height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _sidebarAccent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'admin@agri.com',
                        style: TextStyle(
                          color: _sidebarText,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Logout button
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
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header with close button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 12, 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _sidebarAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco, color: _sidebarAccent, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AgriAdmin',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Manajemen Pertanian',
                        style: TextStyle(
                          color: _sidebarAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: _sidebarDivider, height: 1),
          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'MENU UTAMA',
              style: TextStyle(
                color: _sidebarText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),

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
                  onTap: () {
                    setState(() => _selectedIndex = i);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          const Divider(color: _sidebarDivider, height: 1),
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
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Hamburger menu button
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF344054)),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AGRIADMIN',
                style: TextStyle(
                  color: Color(0xFF1B3A2D),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                _currentTitle,
                style: const TextStyle(
                  color: Color(0xFF1D2939),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Search bar
          Container(
            width: 200,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TextField(
              style: TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Cari...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFF98A2B3)),
                prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF98A2B3)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF344054)),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3B30),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          // User avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1B3A2D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
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

class _SidebarTile extends StatefulWidget {
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
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hovering = false;

  static const Color _sidebarActiveBg = Color(0xFF2D6A4F);
  static const Color _sidebarText = Color(0xFFB7E4C7);

  @override
  Widget build(BuildContext context) {
    final color = widget.isLogout
        ? const Color(0xFFFF6B6B)
        : widget.selected
        ? Colors.white
        : _sidebarText;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: widget.selected
                ? _sidebarActiveBg
                : _hovering
                ? _sidebarActiveBg.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: Icon(widget.icon, color: color, size: 20),
            title: Text(
              widget.label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: widget.selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: widget.selected
                ? const Icon(Icons.chevron_right, color: Colors.white, size: 18)
                : null,
          ),
        ),
      ),
    );
  }
}
