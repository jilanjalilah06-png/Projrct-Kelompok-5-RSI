import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/order_controller.dart';
import 'order_tracking_page.dart';

class MidtransSimulationPage extends StatefulWidget {
  final OrderModel order;

  const MidtransSimulationPage({super.key, required this.order});

  @override
  State<MidtransSimulationPage> createState() => _MidtransSimulationPageState();
}

class _MidtransSimulationPageState extends State<MidtransSimulationPage> {
  static const _green = Color(0xFF159447);
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _green,
        foregroundColor: Colors.white,
        title: const Text('Simulasi Midtrans'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.payment, color: _green, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sandbox Payment Simulator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _InfoRow(label: 'Order ID', value: widget.order.orderNumber),
                _InfoRow(
                  label: 'Total',
                  value: _formatRupiah(widget.order.totalPrice),
                ),
                _InfoRow(label: 'Status', value: widget.order.paymentStatus ?? 'pending'),
                const SizedBox(height: 16),
                const Text(
                  'Mode ini dipakai ketika key Midtrans asli belum tersedia. Klik tombol di bawah untuk mensimulasikan callback pembayaran sukses.',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _processing ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _processing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.4,
                            ),
                          )
                        : const Text(
                            'Bayar Simulasi',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _processing = true);

    final opened = await launchUrl(
      Uri.parse('https://simulator.sandbox.midtrans.com/v2/qris/index'),
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;
    setState(() => _processing = false);

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka halaman pembayaran QRIS Midtrans.')),
      );
      return;
    }

    final controller = context.read<OrderController>();
    final success = await controller.simulatePayment(widget.order.id);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.lastError ?? 'Simulasi pembayaran gagal.'),
        ),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OrderTrackingPage()),
      (route) => route.isFirst,
    );
  }

  String _formatRupiah(double value) {
    final raw = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF667085))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
