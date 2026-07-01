import 'package:flutter/material.dart';
import '../../widgets/agri_bottom_nav_bar.dart';
import '../pembeli/pembeli_dashboard.dart';
import '../pembeli/cart_page.dart';
import '../pembeli/transaction_history_page.dart';
import '../pembeli/pembeli_profile_page.dart';
import 'virtual_assistant_page.dart';

/// Layout untuk role Pembeli.
/// Role Petani → PetaniMainLayout | Role Admin → AdminMainLayout
class ResponsiveUserLayout extends StatefulWidget {
  const ResponsiveUserLayout({super.key});
  @override
  State<ResponsiveUserLayout> createState() => _ResponsiveUserLayoutState();
}

class _ResponsiveUserLayoutState extends State<ResponsiveUserLayout>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _fabAnimController;
  late final Animation<double> _fabScale;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabScale = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.elasticOut,
    );
    // Start the bounce-in animation
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabAnimController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  final List<AgriBottomNavItem> _navItems = const [
    AgriBottomNavItem(
      icon: Icons.home_outlined,
      label: 'Beranda',
      activeIcon: Icons.home,
    ),
    AgriBottomNavItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Keranjang',
      activeIcon: Icons.shopping_cart,
    ),
    AgriBottomNavItem(
      icon: Icons.inventory_2_outlined,
      label: 'Pesanan',
      activeIcon: Icons.inventory_2,
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
    TransactionHistoryPage(),
    PembeliProfilePage(),
  ];

  void _openChatbot() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const VirtualAssistantPage(roleContext: 'Pembeli'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(index: _currentIndex, children: _pages),

          // Floating chatbot button — positioned bottom-right, above Profil icon
          Positioned(
            right: 16,
            bottom: 80,
            child: ScaleTransition(
              scale: _fabScale,
              child: _FloatingChatbotButton(onTap: _openChatbot),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgriBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _navItems,
      ),
    );
  }
}

/// Animated floating chatbot button with a pulse ring effect
class _FloatingChatbotButton extends StatefulWidget {
  final VoidCallback onTap;
  const _FloatingChatbotButton({required this.onTap});

  @override
  State<_FloatingChatbotButton> createState() => _FloatingChatbotButtonState();
}

class _FloatingChatbotButtonState extends State<_FloatingChatbotButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const Color _green = Color(0xFF159447);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_green, Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _green.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: _green.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
