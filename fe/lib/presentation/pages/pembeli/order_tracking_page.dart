import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  static const List<Map<String, dynamic>> _dummyOrders = [
    {
      'orderNumber': '#ORD-001',
      'product': 'Padi Organik',
      'quantity': '10 kg',
      'price': 'Rp 55.000',
      'date': '3 Jun 2026',
      'status': 'Selesai',
      'statusColor': Color(0xFF2A9D8F),
    },
    {
      'orderNumber': '#ORD-002',
      'product': 'Jagung Manis',
      'quantity': '5 kg',
      'price': 'Rp 24.000',
      'date': '1 Jun 2026',
      'status': 'Dikonfirmasi',
      'statusColor': Color(0xFF1565C0),
    },
    {
      'orderNumber': '#ORD-003',
      'product': 'Tomat Segar',
      'quantity': '2 kg',
      'price': 'Rp 18.000',
      'date': '28 Mei 2026',
      'status': 'Bayar Sekarang',
      'statusColor': Color(0xFFE9C46A),
    },
  ];

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
              'Pesanan Saya',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Riwayat pesanan dan status pengiriman',
              style: TextStyle(color: AgriColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _dummyOrders.length,
                itemBuilder: (context, index) {
                  final order = _dummyOrders[index];
                  return _buildOrderCard(context, order, isMobile);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
    bool isMobile,
  ) {
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
        child: Column(
          children: [
            // Header - Order Number and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order['orderNumber'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (order['statusColor'] as Color).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order['status'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: order['statusColor'] as Color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Product and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['product'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AgriColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['quantity']} • ${order['date']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AgriColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  order['price'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AgriColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: isMobile
                  ? Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => _showOrderDetail(context, order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgriColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Lihat Detail'),
                        ),
                        const SizedBox(width: 0, height: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AgriColors.primary),
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Hubungi Penjual',
                            style: TextStyle(color: AgriColors.primary),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showOrderDetail(context, order),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AgriColors.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Lihat Detail'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AgriColors.primary),
                              minimumSize: const Size(double.infinity, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Hubungi Penjual',
                              style: TextStyle(color: AgriColors.primary),
                            ),
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

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Detail Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AgriColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Nomor Pesanan', order['orderNumber'] as String),
              _buildDetailRow('Produk', order['product'] as String),
              _buildDetailRow('Jumlah', order['quantity'] as String),
              _buildDetailRow('Total Harga', order['price'] as String),
              _buildDetailRow('Tanggal Pesan', order['date'] as String),
              _buildDetailRow('Status', order['status'] as String),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AgriColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AgriColors.textLight),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AgriColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
