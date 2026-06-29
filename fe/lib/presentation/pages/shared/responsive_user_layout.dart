import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/agri_bottom_nav_bar.dart';
import '../pembeli/pembeli_dashboard.dart';
import '../pembeli/cart_page.dart';
import '../pembeli/pembeli_profile_page.dart';
import 'virtual_assistant_page.dart';

/// Layout untuk role Pembeli.
/// Role Petani → PetaniMainLayout | Role Admin → AdminMainLayout
class ResponsiveUserLayout extends StatefulWidget {
  const ResponsiveUserLayout({super.key});
  @override
  State<ResponsiveUserLayout> createState() => _ResponsiveUserLayoutState();
}

class _ResponsiveUserLayoutState extends State<ResponsiveUserLayout> {
  int _currentIndex = 0;

  final List<AgriBottomNavItem> _navItems = const [
    AgriBottomNavItem(
      icon: Icons.home_outlined,
      label: 'Dashboard',
      activeIcon: Icons.home,
    ),
    AgriBottomNavItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Keranjang',
      activeIcon: Icons.shopping_cart,
    ),
    AgriBottomNavItem(
      icon: Icons.chat_bubble_outline,
      label: 'Chat',
      activeIcon: Icons.chat_bubble,
    ),
    AgriBottomNavItem(
      icon: Icons.person_outline,
      label: 'Profil',
      activeIcon: Icons.person,
    ),
  ];

  final List<Widget> _pages = const [
    PembeliDashboard(),
    CartPage(),
    VirtualAssistantPage(showBackButton: false, roleContext: 'Pembeli'),
    PembeliProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 720;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AgriColors.primary,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.agriculture,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'AgriConnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () => auth.executeLogout(),
              ),
            ],
          ),
          bottomNavigationBar: isMobile
              ? AgriBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  items: _navItems,
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                Container(
                  width: 200,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: _navItems.length,
                          itemBuilder: (context, index) {
                            final item = _navItems[index];
                            final isSelected = _currentIndex == index;
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AgriColors.primary.withValues(alpha: 0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                selected: isSelected,
                                leading: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  color: isSelected
                                      ? AgriColors.primary
                                      : AgriColors.textLight,
                                ),
                                title: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AgriColors.primary
                                        : AgriColors.textDark,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                                onTap: () =>
                                    setState(() => _currentIndex = index),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => auth.executeLogout(),
                            icon: const Icon(Icons.logout, size: 18),
                            label: const Text('Keluar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: _pages[_currentIndex]),
            ],
          ),
        );
      },
    );
  }
}
