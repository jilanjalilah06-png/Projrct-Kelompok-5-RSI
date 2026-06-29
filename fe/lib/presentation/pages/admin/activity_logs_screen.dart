import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({super.key});
  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  String _filterTipe = 'Semua Tipe';
  String _filterPeriode = 'Juni 2026';
  final _searchCtrl = TextEditingController();

  static const _allLogs = [
    {
      'waktu': '05 Jun 2026 10:32',
      'user': 'Budi Santoso',
      'aktivitas': 'Tambah hasil panen (Padi, 120kg)',
      'tipe': 'Panen',
      'status': 'Sukses',
      'periode': 'Juni 2026',
    },
    {
      'waktu': '05 Jun 2026 09:15',
      'user': 'Siti Aminah',
      'aktivitas': 'Buat order #ORD-001',
      'tipe': 'Order',
      'status': 'Sukses',
      'periode': 'Juni 2026',
    },
    {
      'waktu': '05 Jun 2026 08:00',
      'user': 'Admin',
      'aktivitas': 'Update harga referensi Padi ke Rp 5.200',
      'tipe': 'Komoditas',
      'status': 'Sukses',
      'periode': 'Juni 2026',
    },
    {
      'waktu': '04 Jun 2026 23:10',
      'user': 'Joko Widodo',
      'aktivitas': 'Login gagal (3x percobaan)',
      'tipe': 'Login',
      'status': 'Gagal',
      'periode': 'Juni 2026',
    },
    {
      'waktu': '28 Mei 2026 18:30',
      'user': 'Rudi Hartono',
      'aktivitas': 'Konfirmasi pembayaran #ORD-002',
      'tipe': 'Order',
      'status': 'Sukses',
      'periode': 'Mei 2026',
    },
    {
      'waktu': '21 Mei 2026 15:05',
      'user': 'Admin',
      'aktivitas': 'Nonaktifkan user Joko Widodo',
      'tipe': 'User',
      'status': 'Sukses',
      'periode': 'Mei 2026',
    },
    {
      'waktu': '12 April 2026 11:20',
      'user': 'Nina Susanti',
      'aktivitas': 'Login Portal Pembeli',
      'tipe': 'Login',
      'status': 'Sukses',
      'periode': 'April 2026',
    },
    {
      'waktu': '08 April 2026 09:00',
      'user': 'Budi Santoso',
      'aktivitas': 'Tambah hasil panen (Jagung, 80kg)',
      'tipe': 'Panen',
      'status': 'Sukses',
      'periode': 'April 2026',
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reloadLogsForPeriod(String period) {
    setState(() => _filterPeriode = period);
  }

  Color _tipeColor(String tipe) {
    switch (tipe) {
      case 'Panen':
        return AgriColors.primary;
      case 'Order':
        return AgriColors.primaryLight;
      case 'Komoditas':
        return AgriColors.warning;
      case 'Login':
        return AgriColors.textLight;
      case 'User':
        return const Color(0xFF9B59B6);
      default:
        return AgriColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allLogs.where((log) {
      final user = log['user']!;
      final aktivitas = log['aktivitas']!;
      final matchTipe =
          _filterTipe == 'Semua Tipe' || log['tipe'] == _filterTipe;
      final matchPeriode = log['periode'] == _filterPeriode;
      final matchSearch =
          _searchCtrl.text.isEmpty ||
          user.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
          aktivitas.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      return matchTipe && matchPeriode && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log Aktivitas Sistem',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 360,
                  height: 38,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari user / aktivitas...',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 16,
                        color: AgriColors.textLight,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                _FilterDropdown(
                  value: _filterTipe,
                  options: const [
                    'Semua Tipe',
                    'Panen',
                    'Order',
                    'Komoditas',
                    'Login',
                    'User',
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _filterTipe = v);
                  },
                ),
                _FilterDropdown(
                  value: _filterPeriode,
                  options: const ['April 2026', 'Mei 2026', 'Juni 2026'],
                  onChanged: (v) {
                    if (v == null) return;
                    _reloadLogsForPeriod(v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
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
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(const Color(0xFFF9FAFB)),
                      columns: const [
                        DataColumn(label: Text('Waktu')),
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Aktivitas')),
                        DataColumn(label: Text('Tipe')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: filtered.map((log) {
                        final tipeColor = _tipeColor(log['tipe']!);
                        final isSuccess = log['status'] == 'Sukses';
                        final statusColor =
                            isSuccess ? AgriColors.success : AgriColors.danger;
                        return DataRow(
                          cells: [
                            DataCell(Text(log['waktu']!)),
                            DataCell(Text(log['user']!)),
                            DataCell(SizedBox(
                              width: 320,
                              child: Text(log['aktivitas']!),
                            )),
                            DataCell(_Pill(
                              label: log['tipe']!,
                              color: tipeColor,
                            )),
                            DataCell(_Pill(
                              label: log['status']!,
                              color: statusColor,
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Menampilkan ${filtered.length} dari ${_allLogs.length} log',
              style: const TextStyle(
                fontSize: 12,
                color: AgriColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(fontSize: 13, color: AgriColors.textDark),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
