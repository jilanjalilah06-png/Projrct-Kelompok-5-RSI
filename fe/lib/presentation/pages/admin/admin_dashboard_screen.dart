import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback? onViewLogs;
  const AdminDashboardScreen({super.key, this.onViewLogs});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _searchCtrl = TextEditingController();

  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final data = admin.dashboard;

    final totalPetani = data?.totalPetani ?? 0;
    final totalPembeli = data?.totalPembeli ?? 0;
    final totalOrders = data?.totalOrders ?? 0;
    final totalRevenue = (data?.totalRevenue ?? 0).toDouble();

    final komisiVal = totalRevenue * 0.06;
    final commissionValue = totalRevenue == 0 ? 'Rp 0' : 'Rp ${_formatMillions(komisiVal)}';
    final sisaPetani = totalRevenue * 0.94;
    final commissionSubtitle = totalRevenue == 0 ? 'Rp 0 menunggu ditransfer' : 'Rp ${_formatMillions(sisaPetani)} menunggu ditransfer';
    final bestSellerValue = totalRevenue == 0 ? '-' : '-';
    final bestSellerSubtitle = totalRevenue == 0 ? 'Belum ada komoditas terjual' : 'Belum ada komoditas terjual';

    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(
        color: const Color(0xFF079447),
        onRefresh: () async {
          await context.read<AdminController>().loadDashboard();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 24),

            // 6 Stats Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 480;
                final isNarrow = constraints.maxWidth < 950;
                final cardWidth = isMobile
                    ? constraints.maxWidth
                    : (isNarrow 
                        ? (constraints.maxWidth - 16) / 2 
                        : (constraints.maxWidth - 48) / 4);

                return Column(
                  children: [
                    // Row 1: 4 Cards
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _buildStatCard(
                            title: 'TOTAL PETANI AKTIF',
                            value: totalPetani.toString(),
                            subtitle: '▲ 6 bulan ini',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _buildStatCard(
                            title: 'TOTAL PEMBELI',
                            value: _formatNumber(totalPembeli),
                            subtitle: '▲ 58 minggu ini',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _buildStatCard(
                            title: 'TRANSAKSI BULAN INI',
                            value: 'Rp ${_formatMillions(totalRevenue)}',
                            subtitle: '▲ 12% dari Juni',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _buildStatCard(
                            title: 'PESANAN DIPROSES',
                            value: totalOrders.toString(),
                            subtitle: 'Menunggu diteruskan petani',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 2: 2 Cards (wider)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 16) / 2,
                          child: _buildStatCard(
                            title: 'KOMISI ADMIN',
                            value: commissionValue,
                            subtitle: commissionSubtitle,
                          ),
                        ),
                        SizedBox(
                          width: isNarrow ? constraints.maxWidth : (constraints.maxWidth - 16) / 2,
                          child: _buildStatCard(
                            title: 'KOMODITAS TERLARIS',
                            value: bestSellerValue,
                            subtitle: bestSellerSubtitle,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Aktivitas Terbaru Table Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aktivitas Terbaru',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Kejadian di seluruh platform',
                            style: TextStyle(
                              fontSize: 13,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black26),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: widget.onViewLogs,
                        child: const Text(
                          'Lihat semua',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Data Table
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final activities = data?.recentActivity ?? [];
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            horizontalMargin: 8,
                            columnSpacing: 24,
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
                            columns: const [
                              DataColumn(label: Text('WAKTU', style: _headerStyle)),
                              DataColumn(label: Text('KEJADIAN', style: _headerStyle)),
                              DataColumn(label: Text('PENGGUNA', style: _headerStyle)),
                              DataColumn(label: Text('STATUS', style: _headerStyle)),
                            ],
                            rows: activities.isEmpty
                                ? [
                                    DataRow(
                                      cells: [
                                        const DataCell(Text('-')),
                                        DataCell(Text(
                                          'Belum ada aktivitas terbaru',
                                          style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                        )),
                                        const DataCell(Text('-')),
                                        const DataCell(Text('-')),
                                      ],
                                    ),
                                  ]
                                : activities.map((activity) {
                                    final time = activity['time'] ?? '-';
                                    final action = activity['action'] ?? '-';
                                    final user = activity['user'] ?? '-';
                                    final status = activity['status'] ?? 'Info';
                                    
                                    Color statusColor = const Color(0xFF6E7E75);
                                    if (status == 'Selesai' || status == 'Sukses') {
                                      statusColor = const Color(0xFF2C6A4F);
                                    } else if (status == 'Verifikasi' || status == 'Pending') {
                                      statusColor = const Color(0xFFB57018);
                                    } else if (status == 'Gagal') {
                                      statusColor = const Color(0xFFD32F2F);
                                    }

                                    return _buildActivityRow(
                                      time,
                                      action,
                                      user,
                                      status,
                                      statusColor,
                                      eventWidth: constraints.maxWidth > 500 ? constraints.maxWidth - 360 : null,
                                    );
                                  }).toList(),
                          ),
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF132A1D), width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF90A398),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: _textDark,
              fontFamily: 'Georgia',
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildActivityRow(
    String time,
    String event,
    String user,
    String status,
    Color statusColor,
    {double? eventWidth}
  ) {
    return DataRow(
      cells: [
        DataCell(Text(time, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(
          Container(
            width: eventWidth,
            child: Text(event, style: const TextStyle(fontSize: 13, color: _textDark)),
          ),
        ),
        DataCell(Text(user, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int val) {
    final str = val.toString();
    if (str.length > 3) {
      return '${str.substring(0, str.length - 3)}.${str.substring(str.length - 3)}';
    }
    return str;
  }

  String _formatMillions(double val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1).replaceAll('.', ',')}jt';
    }
    return val.toStringAsFixed(0);
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);
