import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order_model.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../../core/constanst/api_constants.dart';

class AdminPesananDetailScreen extends StatelessWidget {
  final OrderModel order;

  const AdminPesananDetailScreen({super.key, required this.order});

  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6B7280);

  String _formatRupiah(double value) {
    final number = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      final position = number.length - i;
      buffer.write(number[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Menunggu Pembayaran';
      case 'paid': return 'Diproses';
      case 'processing': return 'Diproses';
      case 'shipped': return 'Dikirim';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Dibatalkan';
      case 'ditolak': return 'Ditolak';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2ECE0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ${order.orderNumber}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textDark, fontFamily: 'Georgia'),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Pembeli', order.buyerName),
                  const Divider(height: 32),
                  _buildDetailRow('Produk', order.productSummary),
                  const Divider(height: 32),
                  _buildDetailRow('Jumlah', order.quantitySummary),
                  const Divider(height: 32),
                  _buildDetailRow('Total Harga', 'Rp ${_formatRupiah(order.totalPrice)}'),
                  const Divider(height: 32),
                  _buildDetailRow('Alamat Pengiriman', order.shippingAddress),
                  const Divider(height: 32),
                  _buildDetailRow('Status Pesanan', _statusLabel(order.status)),
                  if (order.deliveryProof != null && order.deliveryProof!.isNotEmpty) ...[
                    const Divider(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bukti Foto Penerimaan',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${ApiConstants.storageUrl}/${order.deliveryProof}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (order.buyerRating != null) ...[
                    const Divider(height: 32),
                    Row(
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            'Rating Pembeli',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textMuted),
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) => Icon(
                            index < order.buyerRating! ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          )),
                        ),
                      ],
                    ),
                  ],
                  if (order.buyerReview != null && order.buyerReview!.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildDetailRow('Ulasan Pembeli', order.buyerReview!),
                  ],
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildDetailRow('Catatan Tambahan', order.notes!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: _textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
