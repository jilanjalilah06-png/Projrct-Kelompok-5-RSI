import 'package:flutter/material.dart';
import '../../widgets/agri_bottom_nav_bar.dart';
import '../shared/virtual_assistant_page.dart';
import 'p1_beranda_screen.dart';
import 'p3_jadwal_tanam_screen.dart';
import 'p6_profil_screen.dart';

class PetaniMainLayout extends StatefulWidget {
  const PetaniMainLayout({super.key});
  @override
  State<PetaniMainLayout> createState() => _PetaniMainLayoutState();
}

class _PetaniMainLayoutState extends State<PetaniMainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    P1BerandaScreen(onOpenTab: _openTab),
    const P3JadwalTanamScreen(),
    const VirtualAssistantPage(showBackButton: false, roleContext: 'Petani'),
    const P6ProfilScreen(),
  ];

  final List<AgriBottomNavItem> _navItems = const [
    AgriBottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Penjualan',
    ),
    AgriBottomNavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Jadwal',
    ),
    AgriBottomNavItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
    ),
    AgriBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  void _openTab(int index) {
    setState(() => _currentIndex = index);
  }

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
