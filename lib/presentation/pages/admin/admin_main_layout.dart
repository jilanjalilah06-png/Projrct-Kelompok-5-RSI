import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';

import 'admin_dashboard_screen.dart';
import 'admin_petani_screen.dart';
import 'admin_pembeli_screen.dart';
import 'admin_produk_screen.dart';
import 'admin_harga_referensi_screen.dart';
import 'monitor_orders_screen.dart';
import 'admin_komisi_pencairan_screen.dart';
import 'aggregate_reports_screen.dart';
import 'activity_logs_screen.dart';

class AdminMainLayout extends StatefulWidget {
  const AdminMainLayout({super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // Dark green theme for the drawer/sidebar matching the screenshots
  static const Color _sidebarBg = Color(0xFF0F2618);
  static const Color _activeBg = Color(0xFF2C5E3B);
  static const Color _inactiveText = Color(0xFF94A89A);
  static const Color _dividerColor = Color(0xFF1E3A27);

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AdminDashboardScreen(
        onViewLogs: () {
          setState(() {
            _selectedIndex = 8;
            _searchController.clear();
          });
          context.read<AdminController>().setSearchQuery('');
          _reloadDataForIndex(8);
        },
      ),
      const AdminPetaniScreen(),
      const AdminPembeliScreen(),
      const AdminProdukScreen(),
      const AdminHargaReferensiScreen(),
      const MonitorOrdersScreen(),
      const AdminKomisiPencairanScreen(),
      const AggregateReportsScreen(),
      const ActivityLogsScreen(),
    ];
  }

  String get _currentTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Petani';
      case 2:
        return 'Pembeli';
      case 3:
        return 'Produk';
      case 4:
        return 'Harga Referensi';
      case 5:
        return 'Pesanan';
      case 6:
        return 'Komisi & Pencairan';
      case 7:
        return 'Pantau Penjualan';
      case 8:
        return 'Log Aktivitas';
      default:
        return 'AgriConnect';
    }
  }

  void _performSearch(String query) {
    final controller = context.read<AdminController>();
    controller.setSearchQuery(query);
    switch (_selectedIndex) {
      case 1:
        controller.loadUsers(role: 'petani', search: query);
        break;
      case 2:
        controller.loadUsers(role: 'pembeli', search: query);
        break;
      case 3:
        controller.loadProducts(search: query);
        break;
      case 4:
        controller.loadReferencePrices(search: query);
        break;
      case 5:
        controller.loadOrders(search: query);
        break;
    }
  }

  void _reloadDataForIndex(int index) {
    final controller = context.read<AdminController>();
    switch (index) {
      case 1:
        controller.loadUsers(role: 'petani');
        break;
      case 2:
        controller.loadUsers(role: 'pembeli');
        break;
      case 3:
        controller.loadCategories();
        break;
      case 4:
        controller.loadReferencePrices();
        break;
      case 5:
        controller.loadOrders();
        break;
      case 8:
        controller.loadActivityLogs();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final showSearch = _selectedIndex >= 1 && _selectedIndex <= 5;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    String hintText = 'Cari...';
    if (_selectedIndex == 1) hintText = 'Cari petani...';
    if (_selectedIndex == 2) hintText = 'Cari pembeli...';
    if (_selectedIndex == 3) hintText = 'Cari produk...';
    if (_selectedIndex == 4) hintText = 'Cari harga referensi...';
    if (_selectedIndex == 5) hintText = 'Cari pesanan...';

    Widget searchWidget = Container(
      constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 320),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13),
        onChanged: (value) => _performSearch(value),
        onSubmitted: (value) => _performSearch(value),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF98A2B3)),
          prefixIcon: const Icon(Icons.search, size: 18, color: Colors.blueAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );

    if (isMobile) {
      return Container(
        color: const Color(0xFFF2ECE0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Color(0xFF132A1D), size: 26),
                    tooltip: 'Buka Menu',
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentTitle,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF132A1D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: searchWidget,
              ),
          ],
        ),
      );
    }

    return Container(
      height: 64,
      color: const Color(0xFFF2ECE0), // Sand/cream top bar background
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Menu button to open sidebar drawer
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF132A1D), size: 26),
            tooltip: 'Buka Menu',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentTitle,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: Color(0xFF132A1D),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (showSearch)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: searchWidget,
              ),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    final admin = context.watch<AdminController>();
    final dashboard = admin.dashboard;

    final unverifiedPetani = dashboard?.unverifiedPetaniCount ?? 0;
    final pendingOrders = dashboard?.pendingOrdersCount ?? 0;
    final pendingPayouts = dashboard?.pendingPayoutsCount ?? 0;

    return Drawer(
      backgroundColor: _sidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand header logo
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F5EC).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF8DC63F), // Yellow-greenish leaf
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AgriConnect',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ADMIN CONSOLE',
                        style: TextStyle(
                          color: Color(0xFF8DC63F),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: _dividerColor, height: 1),

            // Navigation Items List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // RINGKASAN Section
                    _buildSectionHeader('RINGKASAN'),
                    _buildDrawerTile(
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      index: 0,
                    ),
                    const SizedBox(height: 12),

                    // PENGGUNA Section
                    _buildSectionHeader('PENGGUNA'),
                    _buildDrawerTile(
                      label: 'Petani',
                      icon: Icons.people_outline,
                      index: 1,
                      badgeText: unverifiedPetani > 0 ? '$unverifiedPetani baru' : null,
                      badgeColor: const Color(0xFFF5E1C8),
                      badgeTextColor: const Color(0xFFB57018),
                    ),
                    _buildDrawerTile(
                      label: 'Pembeli',
                      icon: Icons.person_outline,
                      index: 2,
                    ),
                    const SizedBox(height: 12),

                    // MARKETPLACE Section
                    _buildSectionHeader('MARKETPLACE'),
                    _buildDrawerTile(
                      label: 'Produk',
                      icon: Icons.storefront_outlined,
                      index: 3,
                    ),
                    _buildDrawerTile(
                      label: 'Harga Referensi',
                      icon: Icons.price_change_outlined,
                      index: 4,
                    ),
                    _buildDrawerTile(
                      label: 'Pesanan',
                      icon: Icons.shopping_bag_outlined,
                      index: 5,
                      badgeText: pendingOrders > 0 ? '$pendingOrders' : null,
                      badgeColor: const Color(0xFFF5E1C8),
                      badgeTextColor: const Color(0xFFB57018),
                    ),
                    const SizedBox(height: 12),

                    // KEUANGAN Section
                    _buildSectionHeader('KEUANGAN'),
                    _buildDrawerTile(
                      label: 'Komisi & Pencairan',
                      icon: Icons.account_balance_wallet_outlined,
                      index: 6,
                      badgeText: pendingPayouts > 0 ? '$pendingPayouts' : null,
                      badgeColor: const Color(0xFFD1E2D6),
                      badgeTextColor: const Color(0xFF2C6A4F),
                    ),
                    const SizedBox(height: 12),

                    // LAPORAN Section
                    _buildSectionHeader('LAPORAN'),
                    _buildDrawerTile(
                      label: 'Pantau Penjualan',
                      icon: Icons.bar_chart_outlined,
                      index: 7,
                    ),
                    _buildDrawerTile(
                      label: 'Log Aktivitas',
                      icon: Icons.history_toggle_off_outlined,
                      index: 8,
                    ),
                  ],
                ),
              ),
            ),

            const Divider(color: _dividerColor, height: 1),

            // Profile info at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Consumer<AuthController>(
                builder: (context, auth, child) {
                  final user = auth.currentUser;
                  final userName = user?.name ?? 'Admin User';
                  final userEmail = user?.email ?? 'admin@agriconnect.com';
                  final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF2C5E3B),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              color: _inactiveText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            // Dedicated Logout button at the bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B6B),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Provider.of<AuthController>(context, listen: false).executeLogout();
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF4C6656), // Muted green-grey for section header
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required String label,
    required IconData icon,
    required int index,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
            _searchController.clear();
          });
          context.read<AdminController>().setSearchQuery('');
          _reloadDataForIndex(index);
          Navigator.pop(context); // Close drawer
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? _activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : _inactiveText,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _inactiveText,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (badgeText != null && badgeColor != null && badgeTextColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
