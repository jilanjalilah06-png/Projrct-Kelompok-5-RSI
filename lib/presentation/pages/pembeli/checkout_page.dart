import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/language_controller.dart';
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

  String _selectedPayment = 'Midtrans Snap';
  bool _isProcessing = false;

  // Fallback items if none passed
  List<Map<String, dynamic>> get _checkoutItems {
    if (widget.items.isNotEmpty) return widget.items;
    return [
      {
        'name': 'Beras Regular',
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

  int get _ongkir => 0;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : _bgColor,
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
    final isEnglish = context.watch<LanguageController>().isEnglish;
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
              Text(
                isEnglish ? 'Checkout' : 'Checkout', 
                style: const TextStyle(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final user = context.watch<AuthController>().currentUser;
    final userName = user?.name ?? (isEnglish ? 'AgriConnect Buyer' : 'Pembeli AgriConnect');
    final userPhone = user?.phone ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              Text(
                isEnglish ? 'Contact Info' : 'Info Kontak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE4E7EC)),
            ),
            child: Row(
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 16,
                  color: isDark ? Colors.white24 : const Color(0xFFD0D5DD),
                ),
                const SizedBox(width: 8),
                Text(
                  userPhone,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF667085),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final user = context.watch<AuthController>().currentUser;
    final userAddress = user?.address ?? (isEnglish ? 'Address not available' : 'Alamat belum tersedia');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
              Text(
                isEnglish ? 'Shipping Address' : 'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1D2939),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showEditAddressDialog(context, userAddress),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isEnglish ? 'Change' : 'Ubah',
                  style: const TextStyle(
                    color: _green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE4E7EC)),
            ),
            child: Text(
              userAddress,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditAddressDialog(BuildContext context, String currentAddress) {
    final isEnglish = context.read<LanguageController>().isEnglish;
    final textController = TextEditingController(text: (currentAddress == 'Alamat belum tersedia' || currentAddress == 'Address not available') ? '' : currentAddress);
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(isEnglish ? 'Change Shipping Address' : 'Ubah Alamat Pengiriman'),
              content: TextField(
                controller: textController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isEnglish ? 'Enter full address...' : 'Masukkan alamat lengkap...',
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: _green, width: 2),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text(isEnglish ? 'Cancel' : 'Batal', style: const TextStyle(color: Color(0xFF667085))),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          final auth = dialogContext.read<AuthController>();
                          final success = await auth.updateProfile(
                            address: textController.text.trim(),
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.lastError ?? (isEnglish ? 'Failed to change address' : 'Gagal mengubah alamat'))),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(isEnglish ? 'Save' : 'Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Ringkasan Pesanan section
  Widget _buildRingkasanPesanan() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          Text(
            isEnglish ? 'Order Summary' : 'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 16),
          // Product list
          ..._checkoutItems.map((item) => _buildOrderItem(item)),
          const SizedBox(height: 12),
          // Divider
          Divider(color: isDark ? Colors.white24 : const Color(0xFFE4E7EC)),
          const SizedBox(height: 8),
          // Subtotal
          _buildPriceRow(isEnglish ? 'Subtotal' : 'Subtotal', _subtotal, isGrey: true),
          const SizedBox(height: 6),
          // Ongkir
          _buildPriceRow(isEnglish ? 'Shipping' : 'Ongkir', _ongkir, isGrey: true),
          const SizedBox(height: 8),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEnglish ? 'Total' : 'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1D2939),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final int price = (item['price'] as num?)?.toInt() ?? 0;
    final int qty = (item['qty'] as num?)?.toInt() ?? 1;
    final int subtotal = price * qty;
    final String emoji = item['emoji']?.toString() ?? '🛒';
    final String name = item['name']?.toString() ?? (isEnglish ? 'Unknown product' : 'Produk tidak diketahui');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B3D2B) : _greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                emoji,
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
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1D2939),
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
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : const Color(0xFF667085),
            ),
          ),
          const SizedBox(width: 12),
          // Subtotal
          Text(
            'Rp ${_formatPrice(subtotal)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1D2939),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, int price, {bool isGrey = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isGrey 
                ? (isDark ? Colors.white60 : const Color(0xFF667085)) 
                : (isDark ? Colors.white : const Color(0xFF1D2939)),
          ),
        ),
        Text(
          'Rp ${_formatPrice(price)}',
          style: TextStyle(
            fontSize: 13,
            color: isGrey 
                ? (isDark ? Colors.white60 : const Color(0xFF667085)) 
                : (isDark ? Colors.white : const Color(0xFF1D2939)),
          ),
        ),
      ],
    );
  }

  /// Pilih Pembayaran section
  Widget _buildPilihPembayaran() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          Text(
            isEnglish ? 'Payment Method' : 'Pilih Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 14),
          _buildPaymentOption(
            label: 'Midtrans Snap',
            icon: Icons.payment,
            description: isEnglish 
                ? 'Virtual Account, e-wallet, QRIS, and card via Midtrans.'
                : 'Virtual Account, e-wallet, QRIS, dan kartu via Midtrans.',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required IconData icon,
    String? description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = _selectedPayment == label;

    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? const Color(0xFF1B3D2B) : _greenLight) 
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _green : (isDark ? Colors.white12 : const Color(0xFFE4E7EC)),
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
                color: isSelected ? _green : (isDark ? const Color(0xFF2A2A2A) : Colors.white),
                border: Border.all(
                  color: isSelected ? _green : (isDark ? Colors.white30 : const Color(0xFFD0D5DD)),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: isSelected ? _green : (isDark ? Colors.white70 : const Color(0xFF667085))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? _green : (isDark ? Colors.white : const Color(0xFF344054)),
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : const Color(0xFF667085),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom checkout button
  Widget _buildBottomButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  : Text(
                      isEnglish ? 'Pay via Midtrans' : 'Bayar via Midtrans',
                      style: const TextStyle(
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
    final auth = context.read<AuthController>();
    final isEnglish = context.read<LanguageController>().isEnglish;
    final orderController = context.read<OrderController>();
    final userAddress = auth.currentUser?.address;
    final apiItems = <Map<String, dynamic>>[];

    for (final item in _checkoutItems) {
      final productId = item['product_id'] ?? item['id'];
      if (productId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEnglish 
                ? 'Product not linked to database. Select product from marketplace.' 
                : 'Produk belum terhubung ke database. Pilih produk dari marketplace.'
            ),
          ),
        );
        return;
      }

      apiItems.add({
        'product_id': productId,
        'quantity': item['qty'],
      });
    }

    setState(() => _isProcessing = true);
    final success = await orderController.createOrder(
      items: apiItems,
      shippingAddress: userAddress?.isNotEmpty == true
          ? userAddress!
          : (isEnglish ? 'AgriConnect Demo Address' : 'Alamat demo AgriConnect'),
      notes: 'Metode pembayaran dipilih: $_selectedPayment',
    );

    if (!context.mounted) return;
    setState(() => _isProcessing = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderController.lastError ?? (isEnglish ? 'Failed to create order.' : 'Gagal membuat pesanan.')),
        ),
      );
      return;
    }

    // Refresh the cart as checked out items have been removed
    context.read<CartController>().loadCart();

    final redirectUrl = orderController.currentOrder?.redirectUrl;
    final hasMidtransUrl = redirectUrl != null && redirectUrl.isNotEmpty;
    if (hasMidtransUrl) {
      final uri = Uri.parse(redirectUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
    } else {
      await launchUrl(
        Uri.parse('https://simulator.sandbox.midtrans.com/v2/qris/index'),
        mode: LaunchMode.externalApplication,
      );
      if (!context.mounted) return;
    }
    // Show dialog and start background polling for payment confirmation.
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B3D2B) : _greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: _green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasMidtransUrl 
                    ? (isEnglish ? 'Order Created' : 'Pesanan Dibuat') 
                    : (isEnglish ? 'Midtrans Not Active' : 'Midtrans Belum Aktif'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1D2939),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasMidtransUrl
                    ? (isEnglish
                        ? 'Please complete payment on the Midtrans page that just opened. Waiting for payment confirmation...'
                        : 'Silakan selesaikan pembayaran di halaman Midtrans yang baru dibuka. Menunggu konfirmasi pembayaran...')
                    : (isEnglish
                        ? 'Order has been created. QRIS sandbox payment will be opened so buyer can complete payment.'
                        : 'Pesanan sudah dibuat. Pembayaran QRIS sandbox akan dibuka agar pembeli bisa menyelesaikan pembayaran.'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF667085),
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
                  Navigator.pop(dialogContext);
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
                child: Text(
                  isEnglish ? 'Track Order' : 'Lacak Pesanan',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );

    // Poll order status in background and navigate when it changes
    final orderId = orderController.currentOrder?.id;
    if (orderId != null) {
      _pollForPayment(orderId, orderController);
    }
  }

  Future<void> _pollForPayment(int orderId, OrderController orderController) async {
    const int maxAttempts = 40; // ~2 minutes with 3s interval
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      try {
        await orderController.loadOrderById(orderId);
      } catch (_) {
        // ignore transient errors
      }

      final order = orderController.currentOrder;
      if (order == null) continue;

      final paymentOk = (order.paymentStatus != null && order.paymentStatus != 'pending') || !order.isPending;
      if (paymentOk) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pop(context); // close dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OrderTrackingPage()),
          );
        });
        return;
      }
    }

    // timeout: do nothing (user can tap Lacak Pesanan)
  }
}
