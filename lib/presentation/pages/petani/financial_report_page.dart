import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/seller_controller.dart';
import '../../controllers/language_controller.dart';
import '../../../data/models/seller_model.dart';

class FinancialReportPage extends StatefulWidget {
  const FinancialReportPage({super.key});

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF1F2937);
  static const _muted = Color(0xFF98A2B3);

  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  late String _selectedPeriod;
  late List<String> _periodOptions;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _periodOptions = List.generate(6, (index) {
      final dt = DateTime(now.year, now.month - index);
      return _monthYearName(dt.month, dt.year);
    });
    _selectedPeriod = _periodOptions.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sellerController = context.read<SellerController>();
      sellerController.loadStatistics(month: _selectedPeriod);
    });
  }

  String _monthYearName(int month, int year) {
    final idNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${idNames[month - 1]} $year';
  }

  List<double> _trendValues(SellerStatisticsModel? stats) {
    if (stats == null || stats.chartData.isEmpty) {
      final totalRevenue = stats?.totalRevenue ?? 0.0;
      if (totalRevenue <= 0) {
        return const [0, 0, 0, 0, 0, 0];
      }
      final base = totalRevenue / 6;
      return List.generate(6, (index) {
        final multiplier = 0.7 + (index * 0.1);
        return (base * multiplier).clamp(0, double.infinity);
      });
    }
    return stats.chartData;
  }

  String _translatePeriod(String period, bool isEnglish) {
    if (!isEnglish) return period;
    return period
      .replaceAll('Januari', 'January')
      .replaceAll('Februari', 'February')
      .replaceAll('Maret', 'March')
      .replaceAll('April', 'April')
      .replaceAll('Mei', 'May')
      .replaceAll('Juni', 'June')
      .replaceAll('Juli', 'July')
      .replaceAll('Agustus', 'August')
      .replaceAll('September', 'September')
      .replaceAll('Oktober', 'October')
      .replaceAll('November', 'November')
      .replaceAll('Desember', 'December');
  }

  void _openPeriodPicker(bool isEnglish) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnglish ? 'Select Month' : 'Pilih Bulan',
                style: TextStyle(
                  color: isDark ? Colors.white : FinancialReportPage._title,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              for (final period in _periodOptions) ...[
                ListTile(
                  title: Text(
                    _translatePeriod(period, isEnglish),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  trailing: _selectedPeriod == period
                      ? const Icon(Icons.check, color: FinancialReportPage._green)
                      : null,
                  onTap: () {
                    setState(() => _selectedPeriod = period);
                    context.read<SellerController>().loadStatistics(month: period);
                    Navigator.pop(sheetContext);
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sellerController = context.watch<SellerController>();
    final stats = sellerController.statistics;
    final isLoading = sellerController.isLoading;

    final totalRevenue = stats?.totalRevenue ?? 0.0;
    final netRevenue = stats?.netRevenue ?? (totalRevenue * 0.94);
    final totalOrders = stats?.totalOrders ?? 0;
    final totalProducts = stats?.totalProducts ?? 0;
    final activeProducts = stats?.activeProducts ?? 0;
    final trendValues = _trendValues(stats);

    final now = DateTime.now();
    final trendLabels = List.generate(6, (index) {
      final dt = DateTime(now.year, now.month - 5 + index);
      final idNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final enNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return isEnglish ? enNames[dt.month - 1] : idNames[dt.month - 1];
    });

    final screenBg = isDark ? const Color(0xFF121212) : FinancialReportPage._background;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: [
                  _MonthSelector(value: _translatePeriod(_selectedPeriod, isEnglish), onTap: () => _openPeriodPicker(isEnglish)),
                  const SizedBox(height: 24),
                  if (isLoading && stats == null)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    _ProfitSummaryCard(totalRevenue: totalRevenue, netRevenue: netRevenue),
                    const SizedBox(height: 24),
                    _OverviewRow(
                      totalRevenue: totalRevenue,
                      totalOrders: totalOrders,
                      totalProducts: totalProducts,
                      activeProducts: activeProducts,
                    ),
                    const SizedBox(height: 24),
                    _SalesReportCard(
                      title: isEnglish ? 'Sales Summary' : 'Ringkasan Penjualan',
                      sold: isEnglish ? '$totalOrders orders' : '$totalOrders pesanan',
                      growth: activeProducts > 0 
                          ? (isEnglish ? '$activeProducts active' : '$activeProducts aktif') 
                          : (isEnglish ? 'Not active' : 'Belum aktif'),
                      income: 'Rp ${_formatCurrency(totalRevenue)}',
                      capital: isEnglish ? '$totalProducts products' : '$totalProducts produk',
                      profit: 'Rp ${_formatCurrency(netRevenue)}',
                    ),
                    const SizedBox(height: 24),
                    _TrendCard(
                      period: _translatePeriod(_selectedPeriod, isEnglish),
                      labels: trendLabels,
                      values: trendValues,
                      onTap: () => _openPeriodPicker(isEnglish),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1E1E1E) : FinancialReportPage._green;

    return Container(
      height: 58,
      color: headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            customBorder: const CircleBorder(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isEnglish ? 'Financial Report' : 'Laporan Keuangan',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _MonthSelector({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : FinancialReportPage._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : FinancialReportPage._muted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.12),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: mutedColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfitSummaryCard extends StatelessWidget {
  final double totalRevenue;
  final double netRevenue;

  const _ProfitSummaryCard({required this.totalRevenue, required this.netRevenue});

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1B3D2B) : FinancialReportPage._green;

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEnglish ? 'Total Gross Revenue' : 'Total Pendapatan Kotor',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp ${_formatCurrency(totalRevenue)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isEnglish ? 'Total Net Revenue (94%)' : 'Total Pendapatan Bersih (94%)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.90),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rp ${_formatCurrency(netRevenue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.22), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFFB7F7D5), size: 22),
              const SizedBox(width: 6),
              Text(
                isEnglish ? 'Last net revenue' : 'Pendapatan bersih terakhir',
                style: const TextStyle(
                  color: Color(0xFFB7F7D5),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SalesReportCard extends StatelessWidget {
  final String title;
  final String sold;
  final String growth;
  final String income;
  final String capital;
  final String profit;

  const _SalesReportCard({
    required this.title,
    required this.sold,
    required this.growth,
    required this.income,
    required this.capital,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : FinancialReportPage._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : FinancialReportPage._muted;

    final incomeBg = isDark ? const Color(0xFF1B2A4A) : const Color(0xFFEFF6FF);
    final capitalBg = isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFFF6ED);
    final profitBg = isDark ? const Color(0xFF1B3D2B) : const Color(0xFFEAF8EE);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B3D2B) : const Color(0xFFD7FBE5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: Color(0xFF079447),
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      sold,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7FBE5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  growth,
                  style: const TextStyle(
                    color: Color(0xFF079447),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Divider(color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MoneyBox(
                  label: isEnglish ? 'Gross Revenue' : 'Pendapatan Kotor',
                  value: income,
                  valueColor: const Color(0xFF1557FF),
                  backgroundColor: incomeBg,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _MoneyBox(
                  label: isEnglish ? 'Capital' : 'Modal',
                  value: capital,
                  valueColor: const Color(0xFFFF4B0A),
                  backgroundColor: capitalBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MoneyBox(
            label: isEnglish ? 'Net Revenue' : 'Pendapatan Bersih',
            value: profit,
            valueColor: const Color(0xFF079447),
            backgroundColor: profitBg,
          ),
        ],
      ),
    );
  }
}

class _MoneyBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Color backgroundColor;

  const _MoneyBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFFB0B0B0) : FinancialReportPage._muted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 18),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
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
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewRow extends StatelessWidget {
  final double totalRevenue;
  final int totalOrders;
  final int totalProducts;
  final int activeProducts;

  const _OverviewRow({
    required this.totalRevenue,
    required this.totalOrders,
    required this.totalProducts,
    required this.activeProducts,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                label: isEnglish ? 'Total Gross Sales' : 'Total Penjualan Kotor',
                value: 'Rp ${_formatCurrency(totalRevenue)}',
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _InfoCard(
                label: isEnglish ? 'Orders' : 'Pesanan',
                value: '$totalOrders',
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                label: isEnglish ? 'Products' : 'Produk',
                value: '$totalProducts',
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _InfoCard(
                label: isEnglish ? 'Active Products' : 'Produk Aktif',
                value: '$activeProducts',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : FinancialReportPage._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : FinancialReportPage._muted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: mutedColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String period;
  final List<String> labels;
  final List<double> values;
  final VoidCallback onTap;

  const _TrendCard({
    required this.period,
    required this.labels,
    required this.values,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : FinancialReportPage._title;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isEnglish ? 'Sales Trend' : 'Tren Penjualan',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.edit, color: FinancialReportPage._muted),
                tooltip: isEnglish ? 'Select month' : 'Pilih bulan',
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 118, child: _ReportLineChart(values: values)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final label in labels) _TrendMonth(label),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportLineChart extends StatelessWidget {
  final List<double> values;

  const _ReportLineChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      painter: _ReportLineChartPainter(values: values, isDark: isDark),
      child: const SizedBox.expand(),
    );
  }
}

class _ReportLineChartPainter extends CustomPainter {
  final List<double> values;
  final bool isDark;

  _ReportLineChartPainter({required this.values, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final fillPath = Path();
    final widthStep = values.length > 1 ? size.width / (values.length - 1) : 0.0;
    final maxValue = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    final minValue = values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    Offset pointFor(int index) {
      final double normalized = range > 0 ? (values[index] - minValue) / range : 0.5;
      return Offset(index * widthStep, size.height - (normalized * 68) - 20);
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
      ..color = isDark ? const Color(0xFF00A63E) : FinancialReportPage._green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrendMonth extends StatelessWidget {
  final String label;

  const _TrendMonth(this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : FinancialReportPage._muted;

    return Text(
      label,
      style: TextStyle(
        color: mutedColor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String _formatCurrency(double value) {
  final rounded = value.round();
  return rounded.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}
