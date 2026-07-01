import 'package:flutter/material.dart';

class FinancialReportPage extends StatelessWidget {
  const FinancialReportPage({super.key});

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF1F2937);
  static const _muted = Color(0xFF98A2B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                children: const [
                  _MonthSelector(),
                  SizedBox(height: 24),
                  _ProfitSummaryCard(),
                  SizedBox(height: 24),
                  _SalesReportCard(
                    title: 'Penjualan Beras',
                    sold: '4.550 Kg terjual',
                    growth: '+17%',
                    income: 'Rp 94.500.000',
                    capital: 'Rp 78.580.000',
                    profit: 'Rp 15.920.000',
                  ),
                  SizedBox(height: 18),
                  _SalesReportCard(
                    title: 'Penjualan Jagung',
                    sold: '2.780 Kg terjual',
                    growth: '+4%',
                    income: 'Rp 47.260.000',
                    capital: 'Rp 45.340.000',
                    profit: 'Rp 1.920.000',
                  ),
                  SizedBox(height: 24),
                  _TrendCard(),
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
    return Container(
      height: 58,
      color: FinancialReportPage._green,
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
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Laporan Keuangan',
            style: TextStyle(
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
  const _MonthSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Juli 2026',
              style: TextStyle(
                color: FinancialReportPage._title,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: FinancialReportPage._muted),
        ],
      ),
    );
  }
}

class _ProfitSummaryCard extends StatelessWidget {
  const _ProfitSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 28),
      decoration: BoxDecoration(
        color: FinancialReportPage._green,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Untung Bersih',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Rp 15.920.000',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.22), height: 1),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.trending_up, color: Color(0xFFB7F7D5), size: 22),
              SizedBox(width: 6),
              Text(
                'Keuntungan bulan Juli',
                style: TextStyle(
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
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
                  color: const Color(0xFFD7FBE5),
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
                      style: const TextStyle(
                        color: FinancialReportPage._title,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      sold,
                      style: const TextStyle(
                        color: FinancialReportPage._muted,
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
          Divider(color: Colors.black.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MoneyBox(
                  label: 'Pendapatan',
                  value: income,
                  valueColor: Color(0xFF1557FF),
                  backgroundColor: Color(0xFFEFF6FF),
                ),
              ),
              SizedBox(width: 18),
              Expanded(
                child: _MoneyBox(
                  label: 'Modal',
                  value: capital,
                  valueColor: Color(0xFFFF4B0A),
                  backgroundColor: Color(0xFFFFF6ED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MoneyBox(
            label: 'Keuntungan',
            value: profit,
            valueColor: Color(0xFF079447),
            backgroundColor: Color(0xFFEAF8EE),
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
            style: const TextStyle(
              color: FinancialReportPage._muted,
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

class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tren Penjualan',
            style: TextStyle(
              color: FinancialReportPage._title,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(height: 118, child: _ReportLineChart()),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TrendMonth('Feb'),
              _TrendMonth('Mar'),
              _TrendMonth('Apr'),
              _TrendMonth('Mei'),
              _TrendMonth('Jun'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportLineChart extends StatelessWidget {
  const _ReportLineChart();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ReportLineChartPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ReportLineChartPainter extends CustomPainter {
  final List<double> values = const [42, 54, 37, 68, 51, 78];

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final fillPath = Path();
    final widthStep = size.width / (values.length - 1);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);

    Offset pointFor(int index) {
      final normalized = (values[index] - minValue) / (maxValue - minValue);
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
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x222D832F), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = FinancialReportPage._green
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
    return Text(
      label,
      style: const TextStyle(
        color: FinancialReportPage._muted,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
