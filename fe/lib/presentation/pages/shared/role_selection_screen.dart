import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';
import 'user_login_screen.dart';
import '../admin/admin_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo & Judul ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AgriColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: AgriColors.primary,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AgriConnect',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.primaryDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Platform Pertanian Digital Indonesia',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Label ─────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Masuk sebagai:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Tile: Petani ───────────────────────────────────
                  _RoleTile(
                    icon: Icons.agriculture_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                    title: 'Portal Petani',
                    subtitle: 'Kelola hasil panen, jadwal, dan stok jual',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLoginScreen(role: 'Petani'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Tile: Pembeli ──────────────────────────────────
                  _RoleTile(
                    icon: Icons.shopping_bag_rounded,
                    iconColor: const Color(0xFF1565C0),
                    bgColor: const Color(0xFFE3F2FD),
                    title: 'Portal Pembeli',
                    subtitle: 'Jelajahi & beli produk pertanian segar',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLoginScreen(role: 'Pembeli'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Tile: Admin ────────────────────────────────────
                  _RoleTile(
                    icon: Icons.admin_panel_settings_rounded,
                    iconColor: const Color(0xFF6A1B9A),
                    bgColor: const Color(0xFFF3E5F5),
                    title: 'Console Admin',
                    subtitle: 'Kelola pengguna, harga, dan laporan sistem',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminLoginScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text(
                    '© 2024 AgriConnect Kelompok 5',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Widget helper: satu tile role
// ──────────────────────────────────────────────────────────────
class _RoleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
