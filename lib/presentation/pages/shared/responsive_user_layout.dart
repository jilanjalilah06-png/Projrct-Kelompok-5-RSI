import 'package:flutter/material.dart';
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AgriBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _navItems,
      ),
    );
  }
}
