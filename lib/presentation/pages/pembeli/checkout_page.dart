import 'package:flutter/material.dart';
import 'order_tracking_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const CheckoutPage({super.key, this.items = const []});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Green theme colors
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenAccent = Color(0xFF4CAF50);
  static const Color _greenLight = Color(0xFFE8F5E9);
  static const Color _bgColor = Color(0xFFF5F5F5);

  String _selectedPayment = 'Transfer Bank';
  bool _isProcessing = false;

  // Dummy user info
  final String _userName = 'Keysha';
  final String _userPhone = '0821703791';
  final String _userAddress = 'Jl. Merdeka No. 12, Jakarta';

  // Fallback items if none passed
  List<Map<String, dynamic>> get _checkoutItems {
    if (widget.items.isNotEmpty) return widget.items;
    return [
      {
        'name': 'Padi Regular',
        'price': 12000,
        'unit': 'kg',
        'qty': 1,
        'emoji': '🌾',
      },
      {
        'name': 'Jagung Premium',
        'price': 17000,
        'unit': 'kg',
        'qty': 5,
        'emoji': '🌽',
      },
    ];
  }

  int get _subtotal {
    int total = 0;
    for (final item in _checkoutItems) {
      total += (item['price'] as int) * (item['qty'] as int);
    }
    return total;
  }

  int get _ongkir => 15000;
  int get _total => _subtotal + _ongkir;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoKontak(),
                  const SizedBox(height: 12),
                  _buildAlamatPengiriman(),
                  const SizedBox(height: 12),
                  _buildRingkasanPesanan(),
                  const SizedBox(height: 12),
                  _buildPilihPembayaran(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomButton(context),
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Halaman Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Info Kontak section
  Widget _buildInfoKontak() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone, size: 20, color: _green),
              const SizedBox(width: 8),
              const Text(
                'Info Kontak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Row(
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 16,
                  color: const Color(0xFFD0D5DD),
                ),
                const SizedBox(width: 8),
                Text(
                  _userPhone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Alamat Pengiriman section
  Widget _buildAlamatPengiriman() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: _green),
              const SizedBox(width: 8),
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Text(
              _userAddress,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ringkasan Pesanan section
  Widget _buildRingkasanPesanan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 16),
          // Product list
          ..._checkoutItems.map((item) => _buildOrderItem(item)),
          const SizedBox(height: 12),
          // Divider
          const Divider(color: Color(0xFFE4E7EC)),
          const SizedBox(height: 8),
          // Subtotal
          _buildPriceRow('Subtotal', _subtotal, isGrey: true),
          const SizedBox(height: 6),
          // Ongkir
          _buildPriceRow('Ongkir', _ongkir, isGrey: true),
          const SizedBox(height: 8),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
              Text(
                'Rp ${_formatPrice(_total)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final int price = item['price'] as int;
    final int qty = item['qty'] as int;
    final int subtotal = price * qty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item['emoji'] as String,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Product name and price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${_formatPrice(price)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _green,
                  ),
                ),
              ],
            ),
          ),
          // Quantity
          Text(
            'x$qty',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(width: 12),
          // Subtotal
          Text(
            'Rp ${_formatPrice(subtotal)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int price, {bool isGrey = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isGrey ? const Color(0xFF667085) : const Color(0xFF1D2939),
          ),
        ),
        Text(
          'Rp ${_formatPrice(price)}',
          style: TextStyle(
            fontSize: 13,
            color: isGrey ? const Color(0xFF667085) : const Color(0xFF1D2939),
          ),
        ),
      ],
    );
  }

  /// Pilih Pembayaran section
  Widget _buildPilihPembayaran() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 14),
          _buildPaymentOption(
            label: 'Transfer Bank',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 10),
          _buildPaymentOption(
            label: 'COD (Bayar di Tempat)',
            icon: Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedPayment == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? _greenLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _green : const Color(0xFFE4E7EC),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _green : Colors.white,
                border: Border.all(
                  color: isSelected ? _green : const Color(0xFFD0D5DD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? _green : const Color(0xFF344054),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom checkout button
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: _green.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              onPressed: _isProcessing ? null : () => _processPayment(context),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Bayar Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!context.mounted) return;
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _greenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: _green,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2939),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pembayaran via $_selectedPayment sudah tercatat.\nPesanan Anda sedang diproses.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderTrackingPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Lacak Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
