import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const _stats = [
    _DashboardStat(
      title: 'Total Petani',
      value: '128',
      sub: '12 baru bulan ini',
      icon: Icons.agriculture,
      color: AgriColors.primary,
    ),
    _DashboardStat(
      title: 'Total Pembeli',
      value: '340',
      sub: '24 baru bulan ini',
      icon: Icons.groups_2_outlined,
      color: Color(0xFF2F80ED),
    ),
    _DashboardStat(
      title: 'Total Order',
      value: '512',
      sub: '38 order bulan ini',
      icon: Icons.shopping_cart_checkout,
      color: AgriColors.warning,
    ),
    _DashboardStat(
      title: 'Nilai Transaksi',
      value: 'Rp 48jt',
      sub: 'Akumulasi bulan ini',
      icon: Icons.payments_outlined,
      color: AgriColors.success,
    ),
  ];

  static const _bars = [
    _ChartBarData(label: 'Jan', transaksi: 24, panen: 18),
    _ChartBarData(label: 'Feb', transaksi: 31, panen: 22),
    _ChartBarData(label: 'Mar', transaksi: 28, panen: 25),
    _ChartBarData(label: 'Apr', transaksi: 39, panen: 32),
    _ChartBarData(label: 'Mei', transaksi: 45, panen: 38),
    _ChartBarData(label: 'Jun', transaksi: 33, panen: 29),
  ];

  static const _activities = [
    ['05 Jun 2026 10:32', 'Budi Santoso', 'Tambah hasil panen Padi 120kg', 'Sukses'],
    ['05 Jun 2026 09:15', 'Siti Aminah', 'Buat order #ORD-001', 'Sukses'],
    ['05 Jun 2026 08:00', 'Admin', 'Update harga referensi Padi', 'Sukses'],
    ['04 Jun 2026 18:30', 'Rudi Hartono', 'Konfirmasi pembayaran #ORD-002', 'Pending'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTight = constraints.maxWidth < 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _stats
                      .map(
                        (stat) => SizedBox(
                          width: isTight
                              ? (constraints.maxWidth - 16) / 2
                              : (constraints.maxWidth - 48) / 4,
                          child: _StatCard(stat: stat),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecor(),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tren Transaksi & Panen 6 Bulan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AgriColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _Legend(color: AgriColors.primaryDark, label: 'Transaksi'),
                      SizedBox(width: 16),
                      _Legend(color: AgriColors.primaryLight, label: 'Panen'),
                    ],
                  ),
                  SizedBox(height: 22),
                  SizedBox(height: 240, child: _DashboardBarChart(data: _bars)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: _cardDecor(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AgriColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        const Color(0xFFF9FAFB),
                      ),
                      columns: const [
                        DataColumn(label: Text('Waktu')),
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Aktivitas')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: _activities
                          .map(
                            (row) => DataRow(
                              cells: [
                                DataCell(Text(row[0])),
                                DataCell(Text(row[1])),
                                DataCell(Text(row[2])),
                                DataCell(_StatusBadge(label: row[3])),
                              ],
                            ),
                          )
                          .toList(),
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

class _DashboardStat {
  final String title, value, sub;
  final IconData icon;
  final Color color;
  const _DashboardStat({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatelessWidget {
  final _DashboardStat stat;
  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(18),
      decoration: _cardDecor(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgriColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: stat.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AgriColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBarData {
  final String label;
  final int transaksi;
  final int panen;
  const _ChartBarData({
    required this.label,
    required this.transaksi,
    required this.panen,
  });
}

class _DashboardBarChart extends StatelessWidget {
  final List<_ChartBarData> data;
  const _DashboardBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxValue = data
        .expand((item) => [item.transaksi, item.panen])
        .reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data
              .map(
                (item) => _MonthBarGroup(
                  data: item,
                  maxValue: maxValue,
                  maxHeight: constraints.maxHeight - 38,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _MonthBarGroup extends StatelessWidget {
  final _ChartBarData data;
  final int maxValue;
  final double maxHeight;

  const _MonthBarGroup({
    required this.data,
    required this.maxValue,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ValueBar(
                  value: data.transaksi,
                  maxValue: maxValue,
                  maxHeight: maxHeight,
                  color: AgriColors.primaryDark,
                ),
                const SizedBox(width: 8),
                _ValueBar(
                  value: data.panen,
                  maxValue: maxValue,
                  maxHeight: maxHeight,
                  color: AgriColors.primaryLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: const TextStyle(fontSize: 11, color: AgriColors.textLight),
          ),
        ],
      ),
    );
  }
}

class _ValueBar extends StatelessWidget {
  final int value;
  final int maxValue;
  final double maxHeight;
  final Color color;

  const _ValueBar({
    required this.value,
    required this.maxValue,
    required this.maxHeight,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final height = maxHeight * value / maxValue;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AgriColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
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

class _StatusBadge extends StatelessWidget {
  final String label;
  const _StatusBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = label == 'Sukses' ? AgriColors.success : AgriColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

BoxDecoration _cardDecor() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);
