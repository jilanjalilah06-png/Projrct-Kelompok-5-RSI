import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/language_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constanst/api_constants.dart';
import 'pembeli_marketplace.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenAccent = Color(0xFF4CAF50);
  static const Color _greenLight = Color(0xFFE8F5E9);
  static const Color _bgColor = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().loadOrders(limit: 50);
    });
  }

  String _formatPrice(int price) {
    final raw = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
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
            child: Consumer<OrderController>(
              builder: (context, controller, _) {
                if (controller.isLoading && controller.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.orders.isEmpty) return _buildEmptyState(context);

                return RefreshIndicator(
                  onRefresh: () => controller.loadOrders(limit: 50),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: controller.orders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, controller.orders[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
                  if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'My Orders' : 'Pesanan Saya',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnglish ? 'Order history and tracking status' : 'Riwayat pesanan dan status pengiriman',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B3D2B) : _greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 42, color: _green),
          ),
          const SizedBox(height: 16),
          Text(
            isEnglish ? 'No orders yet' : 'Belum ada pesanan',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : const Color(0xFF667085),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEnglish ? 'Orders from the database will appear here' : 'Pesanan dari database akan muncul di sini',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : const Color(0xFF98A2B3)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PembeliMarketplace()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isEnglish ? 'Check Marketplace' : 'Cek Pasar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final statusLabel = _statusLabel(order.status, isEnglish);
    final statusColor = _statusColor(order.status);
    final firstItem = order.items?.isNotEmpty == true ? order.items!.first : null;
    final product = firstItem?.product;
    final seller = product?['seller']?['shop_name']?.toString() ??
        product?['seller']?['name']?.toString() ??
        'Petani AgriConnect';
    final category = product?['category']?['name']?.toString() ?? '';

    return InkWell(
      onTap: () => _showOrderDetail(context, order, seller),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white38 : const Color(0xFF667085),
                  ),
                ),
                _StatusBadge(label: statusLabel, color: statusColor),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B3D2B) : _greenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category == 'Jagung' ? Icons.eco : Icons.grain,
                    color: _green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1D2939),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$seller - ${order.quantitySummary}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : const Color(0xFF98A2B3),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${_formatPrice(order.totalPrice.round())}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _green,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : const Color(0xFF98A2B3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showOrderDetail(context, order, seller),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: Text(isEnglish ? 'Details' : 'Detail'),
                  ),
                ),
                if (order.isPending) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _payWithMidtrans(context, order),
                      icon: const Icon(Icons.payment, size: 16),
                      label: const Text('Midtrans'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (order.status == OrderModel.statusShipped || order.status == 'dikirim' || order.status == 'dalam perjalanan') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _completeOrder(context, order),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Pesanan Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context, OrderModel order, String seller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final isEnglish = context.watch<LanguageController>().isEnglish;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isEnglish ? 'Order Details' : 'Detail Pesanan',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(isEnglish ? 'Order No.' : 'No. Pesanan', order.orderNumber),
              _buildDetailRow(isEnglish ? 'Date' : 'Tanggal', _formatDate(order.createdAt)),
              _buildDetailRow(isEnglish ? 'Seller' : 'Penjual', seller),
              _buildDetailRow(isEnglish ? 'Product' : 'Produk', order.productSummary),
              _buildDetailRow(isEnglish ? 'Quantity' : 'Jumlah', order.quantitySummary),
              _buildDetailRow(isEnglish ? 'Payment Method' : 'Pembayaran', order.paymentType ?? 'Midtrans'),
              _buildDetailRow(isEnglish ? 'Payment Status' : 'Status Bayar', order.paymentStatus ?? 'pending'),
              _buildDetailRow(isEnglish ? 'Order Status' : 'Status Order', _statusLabel(order.status, isEnglish)),
              if (order.deliveryProof != null && order.deliveryProof!.isNotEmpty) ...[
                const Divider(height: 20),
                Text(
                  isEnglish ? 'Proof of Delivery' : 'Bukti Foto Penerimaan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${ApiConstants.storageUrl}/${order.deliveryProof}',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: isDark ? Colors.white12 : Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
              if (order.buyerRating != null) ...[
                const Divider(height: 20),
                Row(
                  children: [
                    Text(
                      isEnglish ? 'Your Rating: ' : 'Rating Anda: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        index < order.buyerRating! ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      )),
                    ),
                  ],
                ),
              ],
              if (order.buyerReview != null && order.buyerReview!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  isEnglish ? 'Your Review:' : 'Ulasan Anda:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.buyerReview!,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEnglish ? 'Total Payment' : 'Total Pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    'Rp ${_formatPrice(order.totalPrice.round())}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (order.status == OrderModel.statusShipped || order.status == 'dikirim' || order.status == 'dalam perjalanan') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _completeOrder(context, order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEnglish ? 'Complete Order' : 'Pesanan Selesai'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: const BorderSide(color: _green),
                  ),
                  child: Text(isEnglish ? 'Close' : 'Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _completeOrder(BuildContext context, OrderModel order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _CompleteOrderDialog(order: order),
    );
  }

  Future<void> _payWithMidtrans(BuildContext context, OrderModel order) async {
    var redirectUrl = order.redirectUrl;
    final controller = context.read<OrderController>();
    final bool needsRefresh = redirectUrl == null ||
        redirectUrl.isEmpty ||
        redirectUrl.contains('demo-snap-token');

    if (needsRefresh) {
      final success = await controller.createPayment(order.id);
      if (!context.mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.lastError ?? 'Gagal membuat pembayaran Midtrans.'),
          ),
        );
        return;
      }

      redirectUrl = controller.currentOrder?.redirectUrl;
    }

    if (redirectUrl == null || redirectUrl.isEmpty) {
      await launchUrl(
        Uri.parse('https://simulator.sandbox.midtrans.com/v2/qris/index'),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    await launchUrl(
      Uri.parse(redirectUrl),
      mode: LaunchMode.externalApplication,
    );

    // After launching payment page, poll the order status and navigate when updated
    _pollForPayment(order.id, controller);
  }

  Future<void> _pollForPayment(int orderId, OrderController controller) async {
    const int maxAttempts = 40;
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      try {
        await controller.loadOrderById(orderId);
      } catch (_) {}
      final updated = controller.currentOrder;
      if (updated == null) continue;
      final paymentOk = (updated.paymentStatus != null && updated.paymentStatus != 'pending') || !updated.isPending;
      if (paymentOk) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OrderTrackingPage()),
          );
        });
        return;
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: 13, 
              color: isDark ? Colors.white60 : const Color(0xFF667085),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF344054),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status, [bool isEnglish = false]) {
    switch (status) {
      case OrderModel.statusDelivered:
        return isEnglish ? 'Completed' : 'Selesai';
      case OrderModel.statusConfirmed:
        return isEnglish ? 'Pending Confirmation' : 'Menunggu Konfirmasi';
      case OrderModel.statusShipped:
      case 'dikirim':
        return isEnglish ? 'Shipped' : 'Dikirim';
      case 'dalam perjalanan':
        return isEnglish ? 'In Transit' : 'Dalam Perjalanan';
      case 'packing':
        return isEnglish ? 'Packing' : 'Sedang Dikemas';
      case 'accept':
        return isEnglish ? 'Accepted' : 'Diterima';
      case 'cancel':
      case OrderModel.statusCancelled:
        return isEnglish ? 'Cancelled' : 'Dibatalkan';
      default:
        return isEnglish ? 'Processing' : 'Diproses';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case OrderModel.statusDelivered:
        return _green;
      case OrderModel.statusConfirmed:
      case OrderModel.statusShipped:
      case 'dikirim':
      case 'dalam perjalanan':
      case 'packing':
      case 'accept':
        return const Color(0xFF2196F3);
      case 'cancel':
      case OrderModel.statusCancelled:
        return const Color(0xFFD92D20);
      default:
        return const Color(0xFFE67E22);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _CompleteOrderDialog extends StatefulWidget {
  final OrderModel order;
  const _CompleteOrderDialog({required this.order});

  @override
  State<_CompleteOrderDialog> createState() => _CompleteOrderDialogState();
}

class _CompleteOrderDialogState extends State<_CompleteOrderDialog> {
  XFile? _imageFile;
  Uint8List? _imageBytes;
  int _rating = 5;
  final _reviewController = TextEditingController();
  bool _submitting = false;
  static const Color _green = Color(0xFF159447);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final img = await picker.pickImage(source: source, imageQuality: 70);
    if (img != null) {
      final bytes = await img.readAsBytes();
      setState(() {
        _imageFile = img;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan upload foto bukti paket terlebih dahulu.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final bytes = await _imageFile!.readAsBytes();
      final controller = context.read<OrderController>();
      final success = await controller.updateOrderStatus(
        widget.order.id,
        OrderModel.statusDelivered,
        deliveryProof: bytes.toList(),
        buyerReview: _reviewController.text.trim(),
        buyerRating: _rating,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close dialog

      if (success) {
        // Reload list order agar data ulasan/foto yang baru saja disubmit langsung muncul di detail
        controller.loadOrders(limit: 50);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil diselesaikan dengan ulasan.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.lastError ?? 'Gagal menyelesaikan pesanan.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEnglish ? 'Complete Order' : 'Selesaikan Pesanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1D2939),
              ),
            ),
            const SizedBox(height: 16),
            
            // Photo Upload area
            Text(
              isEnglish ? 'Upload Photo Proof' : 'Upload Foto Bukti Penerimaan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF475467),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _submitting ? null : _pickImage,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? Colors.white10 : Colors.grey.shade50,
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 32, color: _green),
                          const SizedBox(height: 6),
                          Text(
                            isEnglish ? 'Tap to take/select photo' : 'Ketuk untuk mengambil/pilih foto',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Star Rating
            Text(
              isEnglish ? 'Rate the Product' : 'Berikan Rating',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF475467),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starVal = index + 1;
                return IconButton(
                  onPressed: _submitting
                      ? null
                      : () {
                          setState(() {
                            _rating = starVal;
                          });
                        },
                  icon: Icon(
                    _rating >= starVal ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Review textfield
            Text(
              isEnglish ? 'Write Review' : 'Tulis Ulasan (Opsional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF475467),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              enabled: !_submitting,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isEnglish ? 'Type your review here...' : 'Tulis ulasan Anda di sini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => Navigator.pop(context),
                    child: Text(isEnglish ? 'Cancel' : 'Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(isEnglish ? 'Submit' : 'Kirim'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
