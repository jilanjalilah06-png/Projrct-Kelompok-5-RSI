import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);

  final List<String> _tabs = ['Semua', 'Petani', 'Pembeli', 'Produk', 'Pesanan', 'Keuangan'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadActivityLogs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _kategoriColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'petani':
        return const Color(0xFFB57018); // brown/yellow
      case 'pesanan':
        return const Color(0xFF6E7E75);
      case 'produk':
        return const Color(0xFF6E7E75); // gray
      case 'sistem':
        return const Color(0xFF2C6A4F); // green
      case 'keuangan':
        return const Color(0xFF6E7E75); // gray
      default:
        return const Color(0xFF6E7E75);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminController>(
      builder: (context, adminCtrl, child) {
        final logs = adminCtrl.activityLogs;

        // Display logs mapping from raw Map<String, dynamic>
        List<Map<String, String>> displayedLogs = logs.map((log) {
          final createdAt = log['created_at'] as String? ?? '';
          String waktu = '';
          try {
            final dt = DateTime.parse(createdAt).toLocal();
            // Format like '02 Jul 2026, 10:42'
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
            final day = dt.day.toString().padLeft(2, '0');
            final month = months[dt.month - 1];
            final year = dt.year;
            final hour = dt.hour.toString().padLeft(2, '0');
            final minute = dt.minute.toString().padLeft(2, '0');
            waktu = '$day $month $year, $hour:$minute';
          } catch (_) {
            waktu = createdAt;
          }

          return {
            'waktu': waktu,
            'kejadian': log['event'] as String? ?? '',
            'user': log['user_name'] as String? ?? '',
            'kategori': log['category'] as String? ?? 'Sistem',
          };
        }).toList();

        // Filter by tab category
        final currentTab = _tabs[_tabController.index];
        if (currentTab != 'Semua') {
          displayedLogs = displayedLogs.where((log) => (log['kategori'] ?? '').toLowerCase() == currentTab.toLowerCase()).toList();
        }

        // Filter by search text
        if (_searchCtrl.text.isNotEmpty) {
          final q = _searchCtrl.text.toLowerCase();
          displayedLogs = displayedLogs.where((log) {
            return (log['kejadian'] ?? '').toLowerCase().contains(q) ||
                (log['user'] ?? '').toLowerCase().contains(q) ||
                (log['kategori'] ?? '').toLowerCase().contains(q);
          }).toList();
        }

        return Scaffold(
          backgroundColor: _bg,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LAPORAN',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Log Aktivitas',
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.bold,
                            color: _textDark,
                          ),
                        ),
                        // Refresh button
                        IconButton(
                          tooltip: 'Segarkan',
                          onPressed: () => adminCtrl.loadActivityLogs(),
                          icon: const Icon(Icons.refresh, color: _textDark),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Card Table Container
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
                      // Tabs
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black38,
                        indicatorColor: Colors.black,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Log Aktivitas Platform',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Catatan otomatis semua kejadian di AgriConnect',
                        style: TextStyle(fontSize: 13, color: _textMuted),
                      ),
                      const SizedBox(height: 20),

                      // Loading or Data Table
                      if (adminCtrl.loading && displayedLogs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(_textDark),
                            ),
                          ),
                        )
                      else if (displayedLogs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'Tidak ada log aktivitas.',
                              style: TextStyle(color: _textMuted, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
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
                                    DataColumn(label: Text('KATEGORI', style: _headerStyle)),
                                  ],
                                  rows: displayedLogs.map((log) {
                                    final cat = log['kategori']!;
                                    final isDitolak = log['kejadian']!.toLowerCase().contains('ditolak') ||
                                        log['kejadian']!.toLowerCase().contains('batal');

                                    // Explicit color overrides matching the screenshot
                                    Color badgeColor = _kategoriColor(cat);
                                    if (isDitolak) {
                                      badgeColor = const Color(0xFFD32F2F); // red for rejected/cancelled events
                                    }

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(log['waktu']!, style: const TextStyle(fontSize: 13, color: _textDark))),
                                        DataCell(
                                          Container(
                                            width: constraints.maxWidth > 500 ? constraints.maxWidth - 360 : null,
                                            child: Text(
                                              log['kejadian']!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.blueAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(Text(log['user']!, style: const TextStyle(fontSize: 13, color: _textDark))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: badgeColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              cat,
                                              style: TextStyle(
                                                color: badgeColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);
