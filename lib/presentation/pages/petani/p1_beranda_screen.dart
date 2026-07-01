import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../widgets/order_notifications_sheet.dart';
import 'commodity_prices_page.dart';
import 'financial_report_page.dart';

class P1BerandaScreen extends StatelessWidget {
  final ValueChanged<int>? onOpenTab;
  final List<String> scheduleNotifications;

  const P1BerandaScreen({
    super.key,
    this.onOpenTab,
    this.scheduleNotifications = const [],
  });

  static const _green = Color(0xFF2D832F);
  static const _softGreen = Color(0xFFEFF8EF);
  static const _title = Color(0xFF1F2937);
  static const _muted = Color(0xFF98A2B3);
  static const _orange = Color(0xFFEA580C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softGreen,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _DashboardHeader(notifications: scheduleNotifications),
              Transform.translate(
                offset: const Offset(0, -18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const _ShortcutRow(),
                      const SizedBox(height: 24),
                      const _FinanceCard(),
                      const SizedBox(height: 24),
                      _HarvestEstimateCard(onOpenTab: onOpenTab),
                    ],
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

class _DashboardHeader extends StatelessWidget {
  final List<String> notifications;

  const _DashboardHeader({required this.notifications});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final userName = auth.currentUser?.name ?? 'Petani';

    return Container(
      width: double.infinity,
      height: 130,
      padding: const EdgeInsets.fromLTRB(28, 16, 18, 0),
      color: P1BerandaScreen._green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Colors.white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'AgriConnect',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              OrderNotificationsButton(
                badgeColor: const Color(0xFFFF5A66),
                showBadge: notifications.isNotEmpty,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selamat datang, $userName!',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutCard(
            label: 'Lihat',
            title: 'Harga\nReferensi',
            icon: Icons.trending_up,
            iconColor: const Color(0xFF079447),
            iconBackground: const Color(0xFFD8FBE4),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommodityPricesPage()),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _ShortcutCard(
            label: 'Kelola',
            title: 'Pesanan',
            icon: Icons.shopping_cart_outlined,
            iconColor: P1BerandaScreen._orange,
            iconBackground: const Color(0xFFFFEAD5),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KelolaPesananPage()),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final String label;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const _ShortcutCard({
    required this.label,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 170;
            final iconSize = compact ? 46.0 : 60.0;
            final titleSize = compact ? 18.0 : 21.0;
            final labelSize = compact ? 15.0 : 17.0;

            return Container(
              height: 132,
              padding: EdgeInsets.fromLTRB(
                compact ? 14 : 22,
                20,
                compact ? 10 : 16,
                18,
              ),
              child: Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: compact ? 25 : 31,
                    ),
                  ),
                  SizedBox(width: compact ? 9 : 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: P1BerandaScreen._muted,
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: P1BerandaScreen._title,
                            fontSize: titleSize,
                            height: 1.18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FinanceCard extends StatelessWidget {
  const _FinanceCard();

  @override
  Widget build(BuildContext context) {
    void openReport() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FinancialReportPage()),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openReport,
        borderRadius: BorderRadius.circular(22),
        child: _DashboardCard(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Color(0xFF079447),
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Laporan Keuangan',
                      style: TextStyle(
                        color: P1BerandaScreen._title,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'Jun 2026',
                    style: TextStyle(
                      color: P1BerandaScreen._muted,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    child: _FinanceMetric(
                      label: 'Total Penjualan',
                      value: 'Rp 3.420.000',
                      valueColor: Color(0xFF07883E),
                      background: Color(0xFFEAF8EE),
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: _FinanceMetric(
                      label: 'Total Biaya',
                      value: 'Rp 1.850.000',
                      valueColor: Color(0xFFFF2732),
                      background: Color(0xFFFFEFEF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Penjualan 6 Bulan',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 92, child: _LineChart()),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MonthLabel(''),
                  _MonthLabel('Feb'),
                  _MonthLabel('Mar'),
                  _MonthLabel('Apr'),
                  _MonthLabel('Mei'),
                  _MonthLabel('Jun'),
                ],
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: openReport,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00A63E),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lihat detail'),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 22),
                    ],
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

class _FinanceMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color background;

  const _FinanceMetric({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 102,
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: valueColor,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values = const [42, 55, 36, 69, 54, 82];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final fillPath = Path();
    final widthStep = size.width / (values.length - 1);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);

    Offset pointFor(int index) {
      final normalized = (values[index] - minValue) / (maxValue - minValue);
      return Offset(index * widthStep, size.height - (normalized * 52) - 18);
    }

    final first = pointFor(0);
    path.moveTo(first.dx, first.dy);
    fillPath.moveTo(first.dx, size.height);
    fillPath.lineTo(first.dx, first.dy);

    for (var i = 1; i < values.length; i++) {
      final current = pointFor(i);
      final previous = pointFor(i - 1);
      final controlX = previous.dx + (current.dx - previous.dx) / 2;
      path.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
      fillPath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x332D832F), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = P1BerandaScreen._green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthLabel extends StatelessWidget {
  final String label;

  const _MonthLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: P1BerandaScreen._muted,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HarvestEstimateCard extends StatelessWidget {
  final ValueChanged<int>? onOpenTab;

  const _HarvestEstimateCard({required this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    const harvests = [
      ('Padi - Sawah A', 'Panen: 30 Jun 2026'),
      ('Padi - Sawah B', 'Panen: 14 Jul 2026'),
      ('Jagung - Kebun A', 'Panen: 01 Jul 2026'),
      ('Jagung - Kebun B', 'Panen: 10 Jul 2026'),
    ];

    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.eco_outlined, color: Color(0xFF079447), size: 25),
              SizedBox(width: 10),
              Text(
                'Estimasi Panen',
                style: TextStyle(
                  color: P1BerandaScreen._title,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          for (var i = 0; i < harvests.length; i++) ...[
            _HarvestRow(
              title: harvests[i].$1,
              date: harvests[i].$2,
              onTap: () => onOpenTab?.call(1),
            ),
            if (i != harvests.length - 1)
              Divider(
                height: 18,
                thickness: 1,
                color: Colors.black.withValues(alpha: 0.04),
              ),
          ],
        ],
      ),
    );
  }
}

class _HarvestRow extends StatelessWidget {
  final String title;
  final String date;
  final VoidCallback onTap;

  const _HarvestRow({
    required this.title,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: P1BerandaScreen._title,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: P1BerandaScreen._muted,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 58,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1B8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'H-7',
                style: TextStyle(
                  color: P1BerandaScreen._orange,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _DashboardCard({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.11),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
