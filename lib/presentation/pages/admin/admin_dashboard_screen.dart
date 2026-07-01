import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Green theme colors
  static const Color _green = Color(0xFF1B3A2D);
  static const Color _greenAccent = Color(0xFF2D6A4F);
  static const Color _greenLight = Color(0xFF74C69D);
  static const Color _cardBg = Colors.white;
  static const Color _bg = Color(0xFFF8FAF8);
  static const Color _textDark = Color(0xFF1D2939);
  static const Color _textMuted = Color(0xFF667085);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final data = admin.dashboard;

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            const Text(
              'OVERVIEW',
              style: TextStyle(
                color: _greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ringkasan Statistik',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 20),

            if (admin.loading && data == null)
              const Center(child: CircularProgressIndicator())
            else if (admin.error != null && data == null)
              _ErrorPanel(
                message: admin.error!,
                onRetry: () => context.read<AdminController>().loadDashboard(),
              )
            else ...[
              // ── 4 Stat Cards ─────────────────────────────
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 900;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isTight
                            ? (constraints.maxWidth - 16) / 2
                            : (constraints.maxWidth - 48) / 4,
                        child: _StatCard(
                          label: 'KELOLA USER',
                          value: data?.totalPetani != null
                              ? (data!.totalPetani + data.totalPembeli).toString()
                              : '120',
                          subtitle: '+8% minggu ini',
                          icon: Icons.people_alt_outlined,
                          iconBgColor: const Color(0xFF3B5998),
                        ),
                      ),
                      SizedBox(
                        width: isTight
                            ? (constraints.maxWidth - 16) / 2
                            : (constraints.maxWidth - 48) / 4,
                        child: _StatCard(
                          label: 'TOTAL ORDER',
                          value: data?.totalOrders.toString() ?? '345',
                          subtitle: '+12% minggu ini',
                          icon: Icons.checklist_outlined,
                          iconBgColor: _greenAccent,
                        ),
                      ),
                      SizedBox(
                        width: isTight
                            ? (constraints.maxWidth - 16) / 2
                            : (constraints.maxWidth - 48) / 4,
                        child: _StatCard(
                          label: 'STOK TERSEDIA',
                          value: '10',
                          subtitle: null,
                          icon: Icons.inventory_2_outlined,
                          iconBgColor: const Color(0xFF5C6BC0),
                        ),
                      ),
                      SizedBox(
                        width: isTight
                            ? (constraints.maxWidth - 16) / 2
                            : (constraints.maxWidth - 48) / 4,
                        child: _StatCard(
                          label: 'USER AKTIF',
                          value: '98',
                          subtitle: '+5% minggu ini',
                          icon: Icons.trending_up,
                          iconBgColor: _greenAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // ── Line Chart: Data User Aktif ────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: _cardDecor(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Data User Aktif',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Mingguan — Jun 2025',
                              style: TextStyle(
                                fontSize: 12,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFD0D5DD)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '7 Hari Terakhir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: _UserActivityLineChart(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Aktivitas Terbaru Table ──────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: _cardDecor(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aktivitas Terbaru',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _textDark,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.chevron_right, size: 18, color: _textMuted),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF9FAFB),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'USER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'AKTIVITAS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ROLE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'WAKTU',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'STATUS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          _buildActivityRow('Budi Santoso', 'Order Baru', 'Vendor', '17 Jun 2025', 'Sukses'),
                          _buildActivityRow('Siti Rahayu', 'Tambah Produk', 'Admin', '23 Jun 2025', 'Sukses'),
                          _buildActivityRow('Ahmad Fauzi', 'Login', 'User', '23 Jun 2025', 'Pending'),
                          _buildActivityRow('Dewi Lestari', 'Order Baru', 'Vendor', '22 Jun 2025', 'Gagal'),
                          _buildActivityRow('Rudi Hermawan', 'Daftar', 'User', '21 Jun 2025', 'Sukses'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static DataRow _buildActivityRow(String user, String activity, String role, String time, String status) {
    return DataRow(cells: [
      DataCell(Text(user, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      DataCell(Text(activity, style: const TextStyle(fontSize: 13))),
      DataCell(_RoleBadge(role)),
      DataCell(Text(time, style: const TextStyle(fontSize: 13, color: Color(0xFF667085)))),
      DataCell(_StatusBadge(status)),
    ]);
  }
}

// ── Stat Card ─────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconBgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E7EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF667085),
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 14, color: Color(0xFF2D6A4F)),
                const SizedBox(width: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2D6A4F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Line Chart: User Activity ─────────────────────

class _UserActivityLineChart extends StatelessWidget {
  // Dummy data matching the screenshot
  final List<double> data = const [0.40, 0.55, 0.70, 0.65, 0.55, 0.35, 0.95];
  final List<String> labels = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(data: data),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: labels
            .map(
              (l) => Padding(
                padding: const EdgeInsets.only(top: 185),
                child: Text(
                  l,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF667085),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> data;
  const _LineChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 20;
    final step = size.width / (data.length - 1);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE4E7EC)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = h - (i / 4 * h);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final y = h - (i / 4 * h);
      final label = (i * 25).toString();
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF667085)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-2, y - tp.height / 2));
    }

    // Line
    final paint = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x332D6A4F), Color(0x002D6A4F)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, h));

    final dotPaint = Paint()
      ..color = const Color(0xFF2D6A4F)
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = h - (data[i] * h);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, h);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Close fill path
    fillPath.lineTo((data.length - 1) * step, h);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    for (int i = 0; i < data.length; i++) {
      final x = i * step;
      final y = h - (data[i] * h);
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Role Badge ────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (role) {
      case 'Admin':
        bgColor = const Color(0xFF2D6A4F);
        textColor = Colors.white;
        break;
      case 'Vendor':
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF2D6A4F);
        break;
      default:
        bgColor = const Color(0xFFF2F4F7);
        textColor = const Color(0xFF344054);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge(this.label);

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (label) {
      case 'Sukses':
        color = const Color(0xFF12B76A);
        icon = Icons.check_circle_outline;
        break;
      case 'Pending':
        color = const Color(0xFFF79009);
        icon = Icons.access_time;
        break;
      case 'Gagal':
        color = const Color(0xFFF04438);
        icon = Icons.cancel_outlined;
        break;
      default:
        color = const Color(0xFF667085);
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error Panel ───────────────────────────────────

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecor(),
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: Color(0xFFF04438))),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
            ),
            onPressed: onRetry,
            child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecor() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: const Color(0xFFE4E7EC)),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);
