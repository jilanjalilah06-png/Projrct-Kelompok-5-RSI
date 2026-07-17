import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/agri_bottom_nav_bar.dart';
import '../shared/virtual_assistant_page.dart';
import 'p1_beranda_screen.dart';
import 'p3_jadwal_tanam_screen.dart';
import 'p4_stok_jual_screen.dart';
import 'p6_profil_screen.dart';
import '../../controllers/language_controller.dart';

class PetaniMainLayout extends StatefulWidget {
  const PetaniMainLayout({super.key});
  @override
  State<PetaniMainLayout> createState() => _PetaniMainLayoutState();
}

class _PetaniMainLayoutState extends State<PetaniMainLayout> {
  int _currentIndex = 0;
  final List<String> _scheduleNotifications = [];

  void _openTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _addScheduleNotification(String message) {
    setState(() {
      _scheduleNotifications.insert(0, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;

    final List<Widget> pages = [
      P1BerandaScreen(
        onOpenTab: _openTab,
        scheduleNotifications: _scheduleNotifications,
      ),
      P3JadwalTanamScreen(onScheduleDone: _addScheduleNotification),
      const P4StokJualScreen(),
      const VirtualAssistantPage(showBackButton: false, roleContext: 'Petani'),
      const P6ProfilScreen(),
    ];

    final List<AgriBottomNavItem> navItems = [
      AgriBottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: isEnglish ? 'Home' : 'Beranda',
      ),
      AgriBottomNavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: isEnglish ? 'Schedule' : 'Jadwal',
      ),
      AgriBottomNavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: isEnglish ? 'Products' : 'Produk',
      ),
      const AgriBottomNavItem(
        icon: Icons.smart_toy_outlined,
        activeIcon: Icons.smart_toy,
        label: 'AI',
      ),
      AgriBottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: isEnglish ? 'Profile' : 'Profil',
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AgriBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: navItems,
      ),
    );
  }
}
