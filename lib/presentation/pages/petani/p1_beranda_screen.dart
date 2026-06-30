import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/order_notifications_sheet.dart';

// ─────────────────────────────────────────────
//  P1 – Beranda (Dashboard Petani)
// ─────────────────────────────────────────────
class P1BerandaScreen extends StatelessWidget {
  final ValueChanged<int>? onOpenTab;

  const P1BerandaScreen({super.key, this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatGrid(context),
                    const SizedBox(height: 16),
                    _buildChartCard(),
                    const SizedBox(height: 16),
                    _buildUpcomingSection(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header hijau ──
  Widget _buildHeader(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final userName = auth.currentUser?.name ?? 'Budi';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AgriColors.primaryDark, AgriColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 28,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.eco, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'AgriConnect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const OrderNotificationsButton(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Selamat datang, $userName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid 4 stat kartu ──
  Widget _buildStatGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          label: 'Panen Terakhir',
          value: '120 kg',
          icon: Icons.grass,
          iconColor: AgriColors.primaryLight,
          onTap: () => _showPanenInfo(context),
        ),
        _StatCard(
          label: 'Jadwal Aktif',
          value: '3',
          icon: Icons.calendar_today,
          iconColor: Color(0xFF52B788),
          onTap: () => onOpenTab?.call(1),
        ),
        _StatCard(
          label: 'Harga Ref.',
          value: 'Rp 5.2rb',
          icon: Icons.show_chart,
          iconColor: Color(0xFF74C69D),
          onTap: () => _showHargaInfo(context),
        ),
        _StatCard(
          label: 'Stok Jual',
          value: '80 kg',
          icon: Icons.inventory_2,
          iconColor: AgriColors.accent,
          onTap: () => _showStokInfo(context),
        ),
      ],
    );
  }

  // ── Grafik Tren Panen (placeholder bar chart) ──
  Widget _buildChartCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grafik Tren Panen 6 Bulan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AgriColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 100, child: _MiniBarChart()),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ChartLabel('Jan'),
              _ChartLabel('Feb'),
              _ChartLabel('Mar'),
              _ChartLabel('Apr'),
              _ChartLabel('Mei'),
              _ChartLabel('Jun'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Jadwal Mendatang ──
  Widget _buildUpcomingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jadwal Mendatang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AgriColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        _ScheduleItem(
          icon: Icons.grass,
          color: AgriColors.primary,
          title: 'Padi — Sawah A',
          date: 'Panen: 15 Jun 2026',
          badge: 'H-7',
          badgeColor: const Color(0xFFE9C46A),
          onTap: () => onOpenTab?.call(1),
        ),
        const SizedBox(height: 10),
        _ScheduleItem(
          icon: Icons.eco,
          color: const Color(0xFFE9A824),
          title: 'Jagung — Ladang B',
          date: 'Panen: 22 Jun 2026',
          badge: 'Aktif',
          badgeColor: AgriColors.primaryLight,
          onTap: () => onOpenTab?.call(1),
        ),
      ],
    );
  }

  void _showPanenInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panen Terakhir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Panen terakhir tercatat 120 kg. Detail panen dapat dikembangkan sebagai halaman laporan terpisah.',
              style: TextStyle(color: AgriColors.textLight, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showStokInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stok Jual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Stok siap jual saat ini 80 kg. Form input hasil tani tetap tersedia di modul stok jual.',
              style: TextStyle(color: AgriColors.textLight, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showHargaInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Harga Referensi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Harga padi hari ini Rp 5.200/kg. Gunakan data ini sebagai acuan sebelum menerbitkan stok jual.',
              style: TextStyle(color: AgriColors.textLight, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.textDark,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AgriColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mini Bar Chart ───────────────────────────
class _MiniBarChart extends StatelessWidget {
  final List<double> values = const [45, 70, 55, 90, 65, 80];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 60) / 6;
        final maxVal = values.reduce((a, b) => a > b ? a : b);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: values.map((v) {
            final h = (v / maxVal) * constraints.maxHeight;
            return Container(
              width: barWidth * 0.65,
              height: h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AgriColors.primaryLight, AgriColors.primary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String text;
  const _ChartLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 10, color: AgriColors.textLight),
    );
  }
}

// ─── Schedule Item ────────────────────────────
class _ScheduleItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String date;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;
  const _ScheduleItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.date,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AgriColors.textDark,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AgriColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeColor == const Color(0xFFE9C46A)
                        ? const Color(0xFF9A6E00)
                        : AgriColors.primary,
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
