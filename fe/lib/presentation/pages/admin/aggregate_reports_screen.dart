import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class AggregateReportsScreen extends StatefulWidget {
  const AggregateReportsScreen({super.key});
  @override
  State<AggregateReportsScreen> createState() => _AggregateReportsScreenState();
}

class _AggregateReportsScreenState extends State<AggregateReportsScreen> {
  String _periode = 'Juni 2026';
  bool _isFetching = false;

  final _periodeOptions = ['April 2026', 'Mei 2026', 'Juni 2026'];

  // Dummy bar data per periode
  final Map<String, List<double>> _transaksiData = {
    'April 2026': [0.40, 0.55, 0.48, 0.62, 0.58, 0.70],
    'Mei 2026': [0.45, 0.60, 0.52, 0.68, 0.72, 0.65],
    'Juni 2026': [0.48, 0.62, 0.55, 0.72, 0.90, 0.65],
  };
  final Map<String, List<double>> _panenData = {
    'April 2026': [0.30, 0.45, 0.38, 0.50, 0.42, 0.55],
    'Mei 2026': [0.35, 0.50, 0.42, 0.58, 0.55, 0.48],
    'Juni 2026': [0.38, 0.52, 0.45, 0.60, 0.58, 0.50],
  };

  Future<void> _fetchReportDataForPeriod(String period) async {
    setState(() => _isFetching = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() => _isFetching = false);
  }

  @override
  Widget build(BuildContext context) {
    final tx = _transaksiData[_periode]!;
    final pn = _panenData[_periode]!;
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const SizedBox(
                  width: 300,
                  child: Text(
                    'Laporan Agregat Platform',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AgriColors.textDark,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Periode dropdown
                    Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _periode,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AgriColors.textDark,
                          ),
                          items: _periodeOptions
                              .map(
                                (p) =>
                                    DropdownMenuItem(value: p, child: Text(p)),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _periode = v);
                            _fetchReportDataForPeriod(v);
                          },
                        ),
                      ),
                    ),
                    // Export PDF button
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AgriColors.danger,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ekspor PDF sedang diproses...'),
                              ),
                            ),
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Export PDF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── 4 Stat Cards ─────────────────────────────
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth < 900
                    ? (constraints.maxWidth - 16) / 2
                    : (constraints.maxWidth - 48) / 4;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: width,
                      child: _ReportCard(
                        title: 'Total Panen',
                        value: _isFetching ? '...' : '2.4 ton',
                        sub: _periode,
                        color: AgriColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _ReportCard(
                        title: 'Total Order',
                        value: _isFetching ? '...' : '512',
                        sub: _periode,
                        color: AgriColors.primaryLight,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _ReportCard(
                        title: 'Transaksi Selesai',
                        value: _isFetching ? '...' : '489',
                        sub: '95.3%',
                        color: AgriColors.success,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _ReportCard(
                        title: 'Nilai Transaksi',
                        value: _isFetching ? '...' : 'Rp 48jt',
                        sub: _periode,
                        color: AgriColors.warning,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Chart ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tren Transaksi & Panen 6 Bulan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AgriColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Legend
                  Row(
                    children: [
                      _LegendDot(
                        color: AgriColors.primaryDark,
                        label: 'Transaksi',
                      ),
                      const SizedBox(width: 16),
                      _LegendDot(
                        color: AgriColors.primaryLight,
                        label: 'Panen',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _LineChartWidget(
                      labels: labels,
                      transaksi: tx,
                      panen: pn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title, value, sub;
  final Color color;
  const _ReportCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AgriColors.textLight),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 11, color: AgriColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AgriColors.textLight),
        ),
      ],
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<String> labels;
  final List<double> transaksi;
  final List<double> panen;
  const _LineChartWidget({
    required this.labels,
    required this.transaksi,
    required this.panen,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinePainter(transaksi: transaksi, panen: panen),
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
                    color: AgriColors.textLight,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<double> transaksi;
  final List<double> panen;
  const _LinePainter({required this.transaksi, required this.panen});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height - 20;
    final step = size.width / (transaksi.length - 1);

    void drawLine(List<double> data, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final path = Path();
      for (int i = 0; i < data.length; i++) {
        final x = i * step;
        final y = h - (data[i] * h);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
        final labelPainter = TextPainter(
          text: TextSpan(
            text: (data[i] * 100).round().toString(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        labelPainter.paint(
          canvas,
          Offset(x - labelPainter.width / 2, y - 18),
        );
      }
      canvas.drawPath(path, paint);
    }

    drawLine(transaksi, AgriColors.primaryDark);
    drawLine(panen, AgriColors.primaryLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
