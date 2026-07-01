import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class AdminPemasaranScreen extends StatefulWidget {
  const AdminPemasaranScreen({super.key});

  @override
  State<AdminPemasaranScreen> createState() => _AdminPemasaranScreenState();
}

class _AdminPemasaranScreenState extends State<AdminPemasaranScreen> {
  // Green-themed colors
  static const Color _bg = Color(0xFFF8FAF8);
  static const Color _textDark = Color(0xFF1D2939);
  static const Color _textMuted = Color(0xFF667085);
  static const Color _greenAccent = Color(0xFF2D6A4F);
  static const Color _greenDark = Color(0xFF1B3A2D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            const Text(
              'PENJUALAN',
              style: TextStyle(
                color: _greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pemasaran',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 20),

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
                      child: _OrderStatCard(
                        label: 'TOTAL ORDER',
                        value: '345',
                        subtitle: '+12%',
                        icon: Icons.checklist_outlined,
                        iconBgColor: _greenDark,
                      ),
                    ),
                    SizedBox(
                      width: isTight
                          ? (constraints.maxWidth - 16) / 2
                          : (constraints.maxWidth - 48) / 4,
                      child: _OrderStatCard(
                        label: 'ORDER SUKSES',
                        value: '310',
                        subtitle: null,
                        icon: Icons.check_circle_outline,
                        iconBgColor: _greenAccent,
                      ),
                    ),
                    SizedBox(
                      width: isTight
                          ? (constraints.maxWidth - 16) / 2
                          : (constraints.maxWidth - 48) / 4,
                      child: _OrderStatCard(
                        label: 'PENDING',
                        value: '25',
                        subtitle: null,
                        icon: Icons.access_time,
                        iconBgColor: const Color(0xFFBF9B30),
                      ),
                    ),
                    SizedBox(
                      width: isTight
                          ? (constraints.maxWidth - 16) / 2
                          : (constraints.maxWidth - 48) / 4,
                      child: _OrderStatCard(
                        label: 'ORDER GAGAL',
                        value: '10',
                        subtitle: null,
                        icon: Icons.cancel_outlined,
                        iconBgColor: const Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Bar Chart: Tren Order Bulanan ──────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecor(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tren Order Bulanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Jan – Jun 2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: _MonthlyOrderBarChart(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Order Terbaru Table ─────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecor(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Terbaru',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF9FAFB),
                      ),
                      columns: const [
                        DataColumn(label: _TH('ID ORDER')),
                        DataColumn(label: _TH('PEMBELI')),
                        DataColumn(label: _TH('KOMODITAS')),
                        DataColumn(label: _TH('QTY')),
                        DataColumn(label: _TH('TOTAL')),
                        DataColumn(label: _TH('STATUS')),
                      ],
                      rows: [
                        _orderRow('#ORD-001', 'Budi Santoso', 'Padi Standar', '50 kg', 'Rp 600rb', 'Sukses'),
                        _orderRow('#ORD-002', 'Siti Rahayu', 'Jagung Premium', '30 kg', 'Rp 330rb', 'Pending'),
                        _orderRow('#ORD-003', 'Ahmad Fauzi', 'Padi Premium', '20 kg', 'Rp 400rb', 'Sukses'),
                        _orderRow('#ORD-004', 'Dewi Lestari', 'Jagung', '10 kg', 'Rp 48rb', 'Gagal'),
                      ],
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

  DataRow _orderRow(String id, String buyer, String commodity, String qty, String total, String status) {
    return DataRow(cells: [
      DataCell(Text(id, style: const TextStyle(fontSize: 13, color: _textMuted))),
      DataCell(Text(buyer, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      DataCell(Text(commodity, style: const TextStyle(fontSize: 13))),
      DataCell(Text(qty, style: const TextStyle(fontSize: 13))),
      DataCell(Text(total, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
      DataCell(_StatusBadge(status)),
    ]);
  }
}

// ── Order Stat Card ────────────────────────────────

class _OrderStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconBgColor;

  const _OrderStatCard({
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
                  borderRadius: BorderRadius.circular(20),
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

// ── Bar Chart ──────────────────────────────────────

class _MonthlyOrderBarChart extends StatelessWidget {
  final List<int> data = const [25, 40, 35, 55, 50, 78];
  final List<String> labels = const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];

  @override
  Widget build(BuildContext context) {
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(data.length, (i) {
            final barHeight = maxValue == 0
                ? 0.0
                : (constraints.maxHeight - 30) * data[i] / maxValue;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  data[i].toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D2939),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[i],
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            );
          }),
        );
      },
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

// ── Table Header ──────────────────────────────────

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF667085),
      letterSpacing: 0.5,
    ),
  );
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
