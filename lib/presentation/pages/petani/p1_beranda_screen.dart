import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/seller_controller.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/planting_schedule_controller.dart';
import '../../widgets/agri_brand_logo.dart';
import '../../widgets/order_notifications_sheet.dart';
import 'commodity_prices_page.dart';
import 'financial_report_page.dart';

class P1BerandaScreen extends StatefulWidget {
  final ValueChanged<int>? onOpenTab;
  final List<String> scheduleNotifications;

  const P1BerandaScreen({
    super.key,
    this.onOpenTab,
    this.scheduleNotifications = const [],
  });

  @override
  State<P1BerandaScreen> createState() => _P1BerandaScreenState();

  static const _green = Color(0xFF2D832F);
  static const _softGreen = Color(0xFFEFF8EF);
  static const _title = Color(0xFF1F2937);
  static const _muted = Color(0xFF98A2B3);
  static const _orange = Color(0xFFEA580C);
}

class _P1BerandaScreenState extends State<P1BerandaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSellerDashboard());
  }

  Future<void> _loadSellerDashboard() async {
    final auth = context.read<AuthController>();
    final sellerController = context.read<SellerController>();
    final productController = context.read<ProductController>();
    final sellerId = auth.currentUser?.id;

    await Future.wait([
      sellerController.loadAllData(),
      if (sellerId != null) productController.loadSellerProducts(sellerId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final sellerController = context.watch<SellerController>();
    final productController = context.watch<ProductController>();
    final langCtrl = context.watch<LanguageController>();
    final isEnglish = langCtrl.isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sellerName = auth.currentUser?.name ?? (isEnglish ? 'Farmer' : 'Petani');
    final stats = sellerController.statistics;
    final products = productController.products;
    final isLoading = sellerController.isLoading || productController.isLoading;
    final totalRevenue = stats?.totalRevenue ?? 0.0;
    final totalOrders = stats?.totalOrders ?? 0;
    final totalProducts = stats?.totalProducts ?? products.length;
    final chartValues = _computeChartValues(totalRevenue);
    final monthLabels = _recentMonthLabels(isEnglish);

    final scheduleController = context.watch<PlantingScheduleController>();
    final schedules = scheduleController.schedules;

    final harvestEstimates = schedules.map((schedule) {
      final harvestPrefix = isEnglish ? 'Harvest: ' : 'Panen: ';
      final daysLeft = schedule.harvestDate.difference(DateTime.now()).inDays;
      return _HarvestEstimate(
        title: '${schedule.plant} — ${schedule.land}',
        date: '$harvestPrefix${_formatDate(schedule.harvestDate, isEnglish)}',
        daysLeft: daysLeft,
      );
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : P1BerandaScreen._softGreen,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: P1BerandaScreen._green,
          onRefresh: () async {
            await context.read<SellerController>().loadStatistics();
            await context.read<ProductController>().loadProducts();
          },
          child: LayoutBuilder(
            builder: (context, outerConstraints) {
              final screenW = outerConstraints.maxWidth;
              final hPad = screenW < 360 ? 14.0 : (screenW < 400 ? 18.0 : 28.0);
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                children: [
                  _DashboardHeader(notifications: widget.scheduleNotifications, userName: sellerName),
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: Column(
                        children: [
                          const _ShortcutRow(),
                          const SizedBox(height: 24),
                          _FinanceCard(
                            totalRevenue: totalRevenue,
                            totalOrders: totalOrders,
                            totalProducts: totalProducts,
                            trendValues: chartValues,
                            monthLabels: monthLabels,
                          ),
                          const SizedBox(height: 24),
                          _HarvestEstimateCard(
                            harvests: harvestEstimates,
                            isLoading: isLoading,
                            onOpenTab: widget.onOpenTab,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}

  String _formatDate(DateTime value, bool isEnglish) {
    final day = value.day.toString().padLeft(2, '0');
    final month = _monthName(value.month, isEnglish);
    final year = value.year;
    return '$day $month $year';
  }

  String _monthName(int month, bool isEnglish) {
    final idNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final enNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return isEnglish ? enNames[month - 1] : idNames[month - 1];
  }

  List<double> _computeChartValues(double totalRevenue) {
    if (totalRevenue <= 0) {
      return const [0, 0, 0, 0, 0, 0];
    }

    final average = totalRevenue / 6;
    return List.generate(6, (index) {
      final multiplier = 0.7 + (index * 0.1);
      return (average * multiplier).clamp(0, double.infinity) as double;
    });
  }

  List<String> _recentMonthLabels(bool isEnglish) {
    final now = DateTime.now();
    return List.generate(6, (index) {
      final month = DateTime(now.year, now.month - 5 + index);
      return _monthName(month.month, isEnglish);
    });
  }
}

class _DashboardHeader extends StatelessWidget {
  final List<String> notifications;
  final String userName;

  const _DashboardHeader({required this.notifications, required this.userName});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = this.userName;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final compact = w < 360;
        final hPad = compact ? 14.0 : (w < 400 ? 18.0 : 28.0);
        final logoFontSize = compact ? 22.0 : 28.0;
        final welcomeFontSize = compact ? 14.0 : 18.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad - 10, 0),
          constraints: const BoxConstraints(minHeight: 110),
          color: isDark ? const Color(0xFF1E1E1E) : P1BerandaScreen._green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AgriBrandLogo(
                        useTextLogo: true,
                        textLogoHeight: compact ? 32 : 40,
                        iconSize: compact ? 38 : 48,
                        iconBackground: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: logoFontSize,
                          fontWeight: FontWeight.w800,
                        ),
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
              Padding(
                padding: EdgeInsets.only(bottom: compact ? 10 : 16),
                child: Text(
                  isEnglish ? 'Welcome, $userName!' : 'Selamat datang, $userName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: welcomeFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow();

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Row(
      children: [
        Expanded(
          child: _ShortcutCard(
            label: isEnglish ? 'View' : 'Lihat',
            title: isEnglish ? 'Reference\nPrice' : 'Harga\nReferensi',
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
            label: isEnglish ? 'Manage' : 'Kelola',
            title: isEnglish ? 'Orders' : 'Pesanan',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : P1BerandaScreen._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : P1BerandaScreen._muted;

    return Material(
      color: cardBg,
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
                      color: isDark ? const Color(0xFF2A2A2A) : iconBackground,
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
                            color: mutedColor,
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
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
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final List<double> trendValues;
  final List<String> monthLabels;

  const _FinanceCard({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.trendValues,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : P1BerandaScreen._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : P1BerandaScreen._muted;

    void openReport() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FinancialReportPage()),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final compact = w < 320;
        final cardPadH = compact ? 14.0 : (w < 380 ? 16.0 : 24.0);
        final cardPadV = compact ? 16.0 : 24.0;
        final titleFs = compact ? 16.0 : (w < 380 ? 18.0 : 21.0);
        final labelFs = compact ? 13.0 : (w < 380 ? 14.0 : 18.0);
        final metricGap = compact ? 10.0 : 18.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: openReport,
            borderRadius: BorderRadius.circular(22),
            child: _DashboardCard(
              padding: EdgeInsets.fromLTRB(cardPadH, cardPadV, cardPadH, cardPadV - 2),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: const Color(0xFF079447),
                        size: compact ? 20 : 24,
                      ),
                      SizedBox(width: compact ? 6 : 10),
                      Expanded(
                        child: Text(
                          isEnglish ? 'Financial Report' : 'Laporan Keuangan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: titleFs,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        isEnglish ? 'Current' : 'Saat Ini',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: labelFs,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _FinanceMetric(
                          label: isEnglish ? 'Total Gross Sales' : 'Total Penjualan Kotor',
                          value: 'Rp ${_formatCurrency(totalRevenue)}',
                          valueColor: const Color(0xFF07883E),
                          background: const Color(0xFFEAF8EE),
                        ),
                      ),
                      SizedBox(width: metricGap),
                      Expanded(
                        child: _FinanceMetric(
                          label: isEnglish ? 'Orders' : 'Pesanan',
                          value: '$totalOrders',
                          valueColor: isDark ? Colors.white : const Color(0xFF001A3D),
                          background: const Color(0xFFF2F4F7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _FinanceMetric(
                          label: isEnglish ? 'Products' : 'Produk',
                          value: '$totalProducts',
                          valueColor: const Color(0xFF079447),
                          background: const Color(0xFFEAF8EE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isEnglish ? '6-Month Sales' : 'Penjualan 6 Bulan',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085),
                        fontSize: compact ? 14.0 : labelFs,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: 92, child: _LineChart(values: trendValues)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final label in monthLabels)
                        Expanded(
                          child: _MonthLabel(label),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: openReport,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00A63E),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 36),
                        textStyle: TextStyle(
                          fontSize: compact ? 14.0 : 17.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isEnglish ? 'View details' : 'Lihat detail'),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 22),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGreenMetric = background == const Color(0xFFEAF8EE);
    final metricBg = isDark
        ? (isGreenMetric ? const Color(0xFF1B3D2B) : const Color(0xFF2A2A2A))
        : background;
    final labelColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 140;
        final labelFs = compact ? 12.0 : 14.0;
        final valueFs = compact ? 20.0 : 24.0;

        return Container(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 18, 14, compact ? 8 : 10, 12),
          decoration: BoxDecoration(
            color: metricBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: labelColor,
                  fontSize: labelFs,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: valueFs,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<double> values;

  const _LineChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _LineChartPainter(values: values, isDark: isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final bool isDark;

  _LineChartPainter({required this.values, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final fillPath = Path();
    final widthStep = values.length > 1 ? size.width / (values.length - 1) : 0.0;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    Offset pointFor(int index) {
      final double normalized = range > 0 ? (values[index] - minValue) / range : 0.5;
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
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark 
            ? [const Color(0x3300A63E), const Color(0x00FFFFFF)]
            : [const Color(0x332D832F), const Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF00A63E) : P1BerandaScreen._green
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : P1BerandaScreen._muted;
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: mutedColor,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HarvestEstimateCard extends StatelessWidget {
  final List<_HarvestEstimate> harvests;
  final bool isLoading;
  final ValueChanged<int>? onOpenTab;

  const _HarvestEstimateCard({
    required this.harvests,
    required this.isLoading,
    required this.onOpenTab,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : P1BerandaScreen._title;

    return _DashboardCard(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.eco_outlined, color: Color(0xFF079447), size: 25),
              const SizedBox(width: 10),
              Text(
                isEnglish ? 'Harvest Estimates' : 'Estimasi Panen',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (harvests.isEmpty)
            _EmptyMessage(
              message: isEnglish 
                  ? 'No harvest estimates at this time.' 
                  : 'Belum ada estimasi panen saat ini.',
            )
          else ...[
            for (var i = 0; i < harvests.length; i++) ...[
              _HarvestRow(
                title: harvests[i].title,
                date: harvests[i].date,
                daysLeft: harvests[i].daysLeft,
                onTap: () => onOpenTab?.call(1),
              ),
              if (i != harvests.length - 1)
                Divider(
                  height: 18,
                  thickness: 1,
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.04),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _HarvestEstimate {
  final String title;
  final String date;
  final int daysLeft;

  _HarvestEstimate({
    required this.title,
    required this.date,
    required this.daysLeft,
  });
}

class _HarvestRow extends StatelessWidget {
  final String title;
  final String date;
  final int daysLeft;
  final VoidCallback onTap;

  const _HarvestRow({
    required this.title,
    required this.date,
    required this.daysLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : P1BerandaScreen._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : P1BerandaScreen._muted;

    String badgeText;
    if (daysLeft > 0) {
      badgeText = 'H-$daysLeft';
    } else if (daysLeft == 0) {
      badgeText = 'Panen';
    } else {
      badgeText = 'H+${daysLeft.abs()}';
    }

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
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFFF1B8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: isDark ? const Color(0xFFFF9A3C) : P1BerandaScreen._orange,
                  fontSize: 15,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.11),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

String _formatCurrency(double value) {
  final integer = value.round();
  return integer.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : P1BerandaScreen._muted;
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        message,
        style: TextStyle(
          color: mutedColor,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
