import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  String _selectedFilter = 'Semua';

  static const List<Map<String, dynamic>> _dummyTransactions = [
    {
      'id': 'TRX-001',
      'type': 'Pembelian',
      'product': 'Padi Organik',
      'amount': 'Rp 52.000',
      'date': '3 Jun 2026',
      'status': 'Selesai',
      'icon': Icons.shopping_bag_outlined,
      'iconColor': Color(0xFF2A9D8F),
    },
    {
      'id': 'TRX-002',
      'type': 'Top Up',
      'product': 'Saldo Dompet Digital',
      'amount': '+Rp 100.000',
      'date': '2 Jun 2026',
      'status': 'Berhasil',
      'icon': Icons.add_circle_outline,
      'iconColor': Color(0xFF1565C0),
    },
    {
      'id': 'TRX-003',
      'type': 'Pembelian',
      'product': 'Jagung Manis Segar',
      'amount': 'Rp 24.000',
      'date': '1 Jun 2026',
      'status': 'Selesai',
      'icon': Icons.shopping_bag_outlined,
      'iconColor': Color(0xFF2A9D8F),
    },
    {
      'id': 'TRX-004',
      'type': 'Refund',
      'product': 'Pembatalan Pesanan',
      'amount': '+Rp 18.000',
      'date': '31 Mei 2026',
      'status': 'Selesai',
      'icon': Icons.undo,
      'iconColor': Color(0xFFE9C46A),
    },
    {
      'id': 'TRX-005',
      'type': 'Pembelian',
      'product': 'Tomat Segar Premium',
      'amount': 'Rp 42.000',
      'date': '28 Mei 2026',
      'status': 'Selesai',
      'icon': Icons.shopping_bag_outlined,
      'iconColor': Color(0xFF2A9D8F),
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    if (_selectedFilter == 'Semua') {
      return _dummyTransactions;
    }
    return _dummyTransactions
        .where((t) => t['type'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 720;

    return Scaffold(
      backgroundColor: AgriColors.background,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Transaksi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Kelola semua transaksi dan pembayaran Anda',
              style: TextStyle(color: AgriColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Pembelian', 'Top Up', 'Refund'].map((
                  filter,
                ) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AgriColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AgriColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : AgriColors.accent,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Transaction List
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _filteredTransactions[index];
                  return _buildTransactionCard(transaction);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (transaction['iconColor'] as Color).withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  transaction['icon'] as IconData,
                  color: transaction['iconColor'] as Color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['product'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AgriColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction['date'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgriColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AgriColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction['status'] as String,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AgriColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              transaction['amount'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: (transaction['amount'] as String).startsWith('+')
                    ? AgriColors.success
                    : AgriColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
