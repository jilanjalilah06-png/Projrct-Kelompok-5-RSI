import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';
import 'order_tracking_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedMethod = 'Virtual Account BCA';
  bool _isProcessing = false;

  final List<String> _methods = const [
    'Virtual Account BCA',
    'QRIS',
    'GoPay',
    'Dana',
    'Kartu Debit/Kredit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRow('Beras Premium Cianjur x2', 'Rp 28.000'),
            _buildRow('Cabai Merah Keriting x1', 'Rp 38.000'),
            const Divider(height: 32),
            _buildRow('Total Pembayaran', 'Rp 66.000', isBold: true),
            const SizedBox(height: 32),
            const Text(
              'Metode Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AgriColors.primary.withValues(alpha: 0.35),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: _methods.map((method) {
                  return RadioListTile<String>(
                    value: method,
                    groupValue: _selectedMethod,
                    onChanged: (value) {
                      if (value != null)
                        setState(() => _selectedMethod = value);
                    },
                    activeColor: AgriColors.primary,
                    title: Text(method),
                    secondary: const Icon(
                      Icons.payment,
                      color: AgriColors.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AgriColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Mode demo: tombol bayar mensimulasikan payment gateway dan langsung membuat pesanan berhasil.',
                style: TextStyle(color: AgriColors.textDark, height: 1.35),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgriColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isProcessing
                    ? null
                    : () => _processPayment(context),
                child: Text(
                  _isProcessing ? 'Memproses...' : 'Bayar Sekarang',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AgriColors.primary : AgriColors.textDark,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!context.mounted) return;
    setState(() => _isProcessing = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Pembayaran Berhasil'),
        content: Text(
          'Pembayaran via $_selectedMethod sudah tercatat. Pesanan masuk ke halaman pelacakan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OrderTrackingPage()),
              );
            },
            child: const Text('Lacak Pesanan'),
          ),
        ],
      ),
    );
  }
}
