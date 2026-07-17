import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import 'reference_prices_screen.dart';

class AdminHargaLogScreen extends StatefulWidget {
  const AdminHargaLogScreen({super.key});

  @override
  State<AdminHargaLogScreen> createState() => _AdminHargaLogScreenState();
}

class _AdminHargaLogScreenState extends State<AdminHargaLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Green themed colors
  static const Color _bg = Color(0xFFF8FAF8);
  static const Color _textDark = Color(0xFF1D2939);
  static const Color _textMuted = Color(0xFF667085);
  static const Color _greenAccent = Color(0xFF2D6A4F);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATA & MONITORING',
                  style: TextStyle(
                    color: _greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Harga & Log Aktivitas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Tab bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: _textMuted,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    indicator: BoxDecoration(
                      color: _greenAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'Harga Referensi'),
                      Tab(text: 'Log Aktivitas'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [ReferencePricesScreen(), _LogAktivitasTab()],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// TAB 1: Harga Referensi
// ═══════════════════════════════════════════════════

class _LogAktivitasTab extends StatefulWidget {
  const _LogAktivitasTab();

  @override
  State<_LogAktivitasTab> createState() => _LogAktivitasTabState();
}

class _LogAktivitasTabState extends State<_LogAktivitasTab> {
  String _filterTipe = 'Semua Tipe';

  static const Color _textDark = Color(0xFF1D2939);
  static const Color _textMuted = Color(0xFF667085);

  static const _allLogs = [
    {
      'user': 'budi123',
      'role': 'Admin',
      'aktivitas': 'Order Baru',
      'status': 'Sukses',
      'tipe': 'Order',
    },
    {
      'user': 'admin',
      'role': 'Admin',
      'aktivitas': 'Tambah Produk',
      'status': 'Sukses',
      'tipe': 'Komoditas',
    },
    {
      'user': 'siti_r',
      'role': 'Vendor',
      'aktivitas': 'Tambah Produk',
      'status': 'Pending',
      'tipe': 'Komoditas',
    },
    {
      'user': 'user01',
      'role': 'Admin',
      'aktivitas': 'Login',
      'status': 'Gagal',
      'tipe': 'Login',
    },
    {
      'user': 'maya_p',
      'role': 'Admin',
      'aktivitas': 'Daftar',
      'status': 'Sukses',
      'tipe': 'User',
    },
    {
      'user': 'rudi_h',
      'role': 'Vendor',
      'aktivitas': 'Update Harga',
      'status': 'Sukses',
      'tipe': 'Komoditas',
    },
    {
      'user': 'admin',
      'role': 'Admin',
      'aktivitas': 'Nonaktifkan User',
      'status': 'Sukses',
      'tipe': 'User',
    },
    {
      'user': 'dewi_l',
      'role': 'Vendor',
      'aktivitas': 'Order Baru',
      'status': 'Pending',
      'tipe': 'Order',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final logs = (admin.dashboard?.recentActivity ?? [])
        .map(
          (item) => {
            'user': item['user']?.toString() ?? '-',
            'role': item['role']?.toString() ?? '-',
            'aktivitas': item['action']?.toString() ?? '-',
            'status': item['status']?.toString() ?? '-',
            'tipe': item['action']?.toString().contains('Order') == true
                ? 'Order'
                : 'Komoditas',
          },
        )
        .toList();
    final sourceLogs = logs.isEmpty ? _allLogs : logs;
    final filtered = sourceLogs.where((log) {
      return _filterTipe == 'Semua Tipe' || log['tipe'] == _filterTipe;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Log Aktivitas Lengkap',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _textDark,
                ),
              ),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD0D5DD)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterTipe,
                    style: const TextStyle(fontSize: 13, color: _textDark),
                    items:
                        const [
                              'Semua Tipe',
                              'Order',
                              'Komoditas',
                              'Login',
                              'User',
                            ]
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filterTipe = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Activity log table
          Container(
            width: double.infinity,
            decoration: _cardDecor(),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(flex: 2, child: _TH('USER')),
                      Expanded(flex: 2, child: _TH('PERAN')),
                      Expanded(flex: 3, child: _TH('AKTIVITAS')),
                      Expanded(flex: 2, child: _TH('STATUS')),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Rows
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Tidak ada log.',
                      style: TextStyle(color: _textMuted),
                    ),
                  ),
                ...filtered.asMap().entries.map((e) {
                  final log = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                log['user']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(flex: 2, child: _RoleBadge(log['role']!)),
                            Expanded(
                              flex: 3,
                              child: Text(
                                log['aktivitas']!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _StatusBadge(log['status']!),
                            ),
                          ],
                        ),
                      ),
                      if (e.key < filtered.length - 1) const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Menampilkan ${filtered.length} dari ${sourceLogs.length} log',
            style: const TextStyle(fontSize: 12, color: _textMuted),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
// Shared Widgets
// ═══════════════════════════════════════════════════

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
      case 'Petani':
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF2D6A4F);
        break;
      case 'Pembeli':
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1557FF);
        break;
      default:
        bgColor = const Color(0xFFF2F4F7);
        textColor = const Color(0xFF344054);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
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
      ),
    );
  }
}

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

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
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
      ),
    );
  }
}

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
