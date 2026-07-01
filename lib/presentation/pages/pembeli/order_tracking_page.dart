import 'package:flutter/material.dart';
import 'pembeli_marketplace.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key});

  // Green theme colors matching the buyer section
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenAccent = Color(0xFF4CAF50);
  static const Color _greenLight = Color(0xFFE8F5E9);
  static const Color _bgColor = Color(0xFFF5F5F5);

  static const List<Map<String, dynamic>> _dummyOrders = [
    {
      'orderNumber': '#ORD-001',
      'product': 'Padi Organik',
      'quantity': '10 kg',
      'price': 55000,
      'date': '3 Jun 2026',
      'status': 'Selesai',
      'emoji': '🌾',
      'seller': 'Pak Budi',
      'payment': 'Transfer Bank',
    },
    {
      'orderNumber': '#ORD-002',
      'product': 'Jagung Manis',
      'quantity': '5 kg',
      'price': 24000,
      'date': '1 Jun 2026',
      'status': 'Dikonfirmasi',
      'emoji': '🌽',
      'seller': 'Bu Sari',
      'payment': 'COD',
      'resi': 'JNE-9876543210',
    },
    {
      'orderNumber': '#ORD-003',
      'product': 'Tomat Segar',
      'quantity': '2 kg',
      'price': 18000,
      'date': '28 Mei 2026',
      'status': 'Diproses',
      'emoji': '🍅',
      'seller': 'Pak Ahmad',
      'payment': 'Transfer Bank',
    },
  ];

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i > 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _dummyOrders.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: _dummyOrders.length,
                    itemBuilder: (context, index) {
                      final order = _dummyOrders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_greenDark, _green, _greenAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesanan Saya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Riwayat pesanan dan status pengiriman',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('📦', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pesanan Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF98A2B3),
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const PembeliMarketplace(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Text(
                'Cek Pasar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final String status = order['status'] as String;
    final int price = order['price'] as int;

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (status) {
      case 'Selesai':
        statusColor = _green;
        statusBgColor = _greenLight;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'Dikonfirmasi':
        statusColor = const Color(0xFF2196F3);
        statusBgColor = const Color(0xFFE3F2FD);
        statusIcon = Icons.verified_outlined;
        break;
      case 'Diproses':
        statusColor = const Color(0xFFE67E22);
        statusBgColor = const Color(0xFFFFF3E0);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.shade100;
        statusIcon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: () => _showOrderDetail(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number + Status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['orderNumber'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF667085),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Product info row
              Row(
                children: [
                  // Emoji icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _greenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        order['emoji'] as String,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Product name, seller, qty
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['product'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2939),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${order['seller']} • ${order['quantity']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF98A2B3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total price + date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${_formatPrice(price)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _green,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        order['date'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Show tracking number for "Dikonfirmasi" status
              if (order['resi'] != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 16,
                        color: Color(0xFF667085),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No. Resi: ${order['resi']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF344054),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Action buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  if (status == 'Selesai') ...[
                    Expanded(
                      child: _buildActionButton(
                        label: 'Beli Lagi',
                        icon: Icons.refresh,
                        isPrimary: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Hubungi Penjual',
                        icon: Icons.chat_outlined,
                        isPrimary: false,
                        onTap: () {},
                      ),
                    ),
                  ] else if (status == 'Dikonfirmasi') ...[
                    Expanded(
                      child: _buildActionButton(
                        label: 'Lihat Detail',
                        icon: Icons.visibility_outlined,
                        isPrimary: true,
                        onTap: () => _showOrderDetail(context, order),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Hubungi Penjual',
                        icon: Icons.chat_outlined,
                        isPrimary: false,
                        onTap: () {},
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: _buildActionButton(
                        label: 'Lihat Detail',
                        icon: Icons.visibility_outlined,
                        isPrimary: true,
                        onTap: () => _showOrderDetail(context, order),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Hubungi Penjual',
                        icon: Icons.chat_outlined,
                        isPrimary: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? _green : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary ? _green : const Color(0xFFD0D5DD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? Colors.white : const Color(0xFF344054),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : const Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order) {
    final int price = order['price'] as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Detail Pesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
              const SizedBox(height: 20),
              // Product info
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _greenLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        order['emoji'] as String,
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['product'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2939),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${_formatPrice(price)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: _green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFFE4E7EC)),
              const SizedBox(height: 12),
              // Detail rows
              _buildDetailRow('No. Pesanan', order['orderNumber'] as String),
              _buildDetailRow('Tanggal', order['date'] as String),
              _buildDetailRow('Penjual', order['seller'] as String),
              _buildDetailRow('Jumlah', order['quantity'] as String),
              _buildDetailRow('Pembayaran', order['payment'] as String),
              _buildDetailRow('Status', order['status'] as String),
              if (order['resi'] != null)
                _buildDetailRow('No. Resi', order['resi'] as String),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE4E7EC)),
              const SizedBox(height: 8),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  Text(
                    'Rp ${_formatPrice(price)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Close button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF344054),
            ),
          ),
        ],
      ),
    );
  }
}
