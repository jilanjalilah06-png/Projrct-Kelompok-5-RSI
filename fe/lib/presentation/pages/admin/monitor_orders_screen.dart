import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class MonitorOrdersScreen extends StatefulWidget {
  const MonitorOrdersScreen({super.key});
  @override
  State<MonitorOrdersScreen> createState() => _MonitorOrdersScreenState();
}

class _MonitorOrdersScreenState extends State<MonitorOrdersScreen> {
  String _filterStatus = 'Semua Status';

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#ORD-001',
      'pembeli': 'Siti Aminah',
      'produk': 'Padi Organik',
      'jumlah': '10 kg',
      'total': 'Rp 52rb',
      'status': 'Pending',
    },
    {
      'id': '#ORD-002',
      'pembeli': 'Andi Prasetiyo',
      'produk': 'Jagung Manis',
      'jumlah': '5 kg',
      'total': 'Rp 24rb',
      'status': 'Dikonfirmasi',
    },
    {
      'id': '#ORD-003',
      'pembeli': 'Dewi Lestari',
      'produk': 'Tomat Segar',
      'jumlah': '3 kg',
      'total': 'Rp 18rb',
      'status': 'Selesai',
    },
    {
      'id': '#ORD-004',
      'pembeli': 'Rizky Pratama',
      'produk': 'Bayam Segar',
      'jumlah': '2 kg',
      'total': 'Rp 7rb',
      'status': 'Pending',
    },
    {
      'id': '#ORD-005',
      'pembeli': 'Nina Susanti',
      'produk': 'Wortel Muda',
      'jumlah': '4 kg',
      'total': 'Rp 17rb',
      'status': 'Selesai',
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AgriColors.warning;
      case 'Dikonfirmasi':
        return AgriColors.primary;
      case 'Selesai':
        return AgriColors.success;
      default:
        return AgriColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterStatus == 'Semua Status'
        ? _orders
        : _orders.where((o) => o['status'] == _filterStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monitor Order',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textDark,
                  ),
                ),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterStatus,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AgriColors.textDark,
                      ),
                      items:
                          ['Semua Status', 'Pending', 'Dikonfirmasi', 'Selesai']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _filterStatus = v!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Table
            Container(
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
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(child: _TH('ID Order')),
                        Expanded(flex: 2, child: _TH('Pembeli')),
                        Expanded(flex: 2, child: _TH('Produk')),
                        Expanded(child: _TH('Jumlah')),
                        Expanded(child: _TH('Total')),
                        Expanded(child: _TH('Status')),
                        Expanded(child: _TH('Aksi')),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Rows
                  ...filtered.asMap().entries.map((e) {
                    final o = e.value;
                    final statusColor = _statusColor(o['status']);
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  o['id'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AgriColors.textDark,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  o['pembeli'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  o['produk'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  o['jumlah'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  o['total'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    o['status'],
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showDetail(context, o),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AgriColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Detail',
                                      style: TextStyle(
                                        color: AgriColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e.key < filtered.length - 1)
                          const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Detail Order ${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('Pembeli', order['pembeli']),
            _DetailRow('Produk', order['produk']),
            _DetailRow('Jumlah', order['jumlah']),
            _DetailRow('Total', order['total']),
            _DetailRow('Status', order['status']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
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
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AgriColors.textLight,
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(color: AgriColors.textLight, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    ),
  );
}
