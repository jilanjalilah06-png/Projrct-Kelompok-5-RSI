import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/order_model.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/reference_price_model.dart';
import '../../controllers/language_controller.dart';

class CommodityPricesPage extends StatefulWidget {
  const CommodityPricesPage({super.key});

  @override
  State<CommodityPricesPage> createState() => _CommodityPricesPageState();
}

class _CommodityPricesPageState extends State<CommodityPricesPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadReferencePrices();
    });
  }

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _headerBackground = Color(0xFFDCECDD);
  static const _title = Color(0xFF1F2937);
  static const _muted = Color(0xFF98A2B3);

  @override
  void dispose() {
    super.dispose();
  }

  String _formatPrice(int value) {
    final number = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      final position = number.length - i;
      buffer.write(number[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adminCtrl = context.watch<AdminController>();

    final prices = adminCtrl.referencePrices.map((p) {
            final minStr = _formatPrice(p.minPrice);
            final maxStr = _formatPrice(p.maxPrice);
            return _CommodityPrice(
              name: p.name,
              unit: 'kg',
              price: 'Rp $minStr - Rp $maxStr',
              isRising: p.minPrice >= 10000,
              note: p.note ?? 'Pembaruan harga referensi pasar terbaru oleh Admin.',
            );
          }).toList();

    final filteredPrices = prices;

    final screenBg = isDark ? const Color(0xFF121212) : _background;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              title: isEnglish ? 'Reference Prices' : 'Harga Referensi',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const _TableHeader(),
                  const SizedBox(height: 8),
                  if (adminCtrl.loading && filteredPrices.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (filteredPrices.isEmpty)
                    _EmptyMessage(
                      message: isEnglish ? 'No commodities found.' : 'Komoditas tidak ditemukan.',
                    )
                  else
                    for (final item in filteredPrices) ...[
                      _PriceCard(item: item),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KelolaPesananPage extends StatefulWidget {
  const KelolaPesananPage({super.key});

  @override
  State<KelolaPesananPage> createState() => _KelolaPesananPageState();
}

class _KelolaPesananPageState extends State<KelolaPesananPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().loadOrders(limit: 50);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderController = context.watch<OrderController>();
    final orders = orderController.orders;

    final filteredOrders = orders.where((order) {
      final target = '${order.productSummary} ${order.id}'.toLowerCase();
      return target.contains(_query);
    }).toList();

    final screenBg = isDark ? const Color(0xFF121212) : _CommodityPricesPageState._background;
    final containerBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              title: isEnglish ? 'Manage Orders' : 'Kelola Pesanan',
              onBack: () => Navigator.pop(context),
            ),
            Container(
              color: containerBg,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: _SearchField(
                controller: _searchController,
                hintText: isEnglish ? 'Search product, order ID...' : 'Cari produk, ID pesanan...',
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
              ),
            ),
            Expanded(
              child: orderController.isLoading && filteredOrders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                  ? _EmptyMessage(
                      message: isEnglish ? 'No orders found.' : 'Pesanan tidak ditemukan.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(8, 18, 8, 24),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        final canShip = order.status == OrderModel.statusConfirmed || order.status == 'accept';
                        return _OrderCard(
                          order: order,
                          onDetail: () => _showOrderDetail(context, order, isEnglish),
                          onShip: canShip
                              ? () => _markAsShipped(context, order, isEnglish)
                              : null,
                          onStatusTap: () => _showStatusPicker(context, order, isEnglish),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsShipped(BuildContext context, OrderModel order, bool isEnglish) async {
    final controller = context.read<OrderController>();
    final success = await controller.updateOrderStatus(
      order.id,
      OrderModel.statusShipped,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEnglish ? 'Order successfully shipped.' : 'Pesanan berhasil dikirim.'),
            backgroundColor: const Color(0xFF2D832F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.lastError ?? (isEnglish ? 'Failed to ship order.' : 'Gagal mengirim pesanan.')),
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(BuildContext context, OrderModel order, String newStatus, bool isEnglish) async {
    final controller = context.read<OrderController>();
    final success = await controller.updateOrderStatus(
      order.id,
      newStatus,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEnglish ? 'Status successfully updated.' : 'Status berhasil diperbarui.'),
            backgroundColor: const Color(0xFF2D832F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.lastError ?? (isEnglish ? 'Failed to update status.' : 'Gagal memperbarui status.')),
          ),
        );
      }
    }
  }

  void _showStatusPicker(BuildContext context, OrderModel order, bool isEnglish) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final options = [
          {'value': 'accept', 'label': isEnglish ? 'Accept' : 'Terima'},
          {'value': 'cancel', 'label': isEnglish ? 'Cancel' : 'Batalkan'},
          {'value': 'packing', 'label': isEnglish ? 'Packing' : 'Dikemas'},
          {'value': 'dikirim', 'label': isEnglish ? 'Shipped' : 'Dikirim'},
          {'value': 'dalam perjalanan', 'label': isEnglish ? 'In Transit' : 'Dalam Perjalanan'},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
              const SizedBox(height: 18),
              Text(
                isEnglish ? 'Update Status for Order #${order.id}' : 'Perbarui Status Pesanan #${order.id}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = order.status == opt['value'];
                return ListTile(
                  title: Text(
                    opt['label']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF2D832F)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF2D832F))
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(context, order, opt['value']!, isEnglish);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetail(BuildContext context, OrderModel order, bool isEnglish) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
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
                const SizedBox(height: 18),
                Text(
                  isEnglish ? 'Order Detail ${order.orderNumber}' : 'Detail Order ${order.orderNumber}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                _DetailRow(isEnglish ? 'Buyer' : 'Pembeli', order.buyerName),
                _DetailRow(isEnglish ? 'Product' : 'Produk', order.productSummary),
                _DetailRow(isEnglish ? 'Quantity' : 'Jumlah', order.quantitySummary),
                _DetailRow(isEnglish ? 'Total Price' : 'Total Harga', 'Rp ${formatRupiah(order.totalPrice.round())}'),
                _DetailRow(isEnglish ? 'Shipping Address' : 'Alamat Kirim', order.shippingAddress),
                _DetailRow(isEnglish ? 'Order Status' : 'Status Order', order.status),
                _DetailRow(isEnglish ? 'Payment Status' : 'Status Pembayaran', order.paymentStatus ?? 'pending'),
                if (order.notes != null && order.notes!.isNotEmpty) ...[
                  _DetailRow(isEnglish ? 'Notes' : 'Catatan', order.notes!),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _CommodityPricesPageState._green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        isEnglish ? 'Close' : 'Tutup',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

String formatRupiah(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

class _PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PageHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1E1E1E) : _CommodityPricesPageState._green;

    return Container(
      height: 66,
      color: headerBg,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 2),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputColor = isDark ? Colors.white : _CommodityPricesPageState._title;
    final hintColor = isDark ? const Color(0xFFB0B0B0) : _CommodityPricesPageState._muted;
    final fieldBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(
        color: inputColor,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 20,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF98A2B3),
          size: 28,
        ),
        filled: true,
        fillColor: fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBg = isDark ? const Color(0xFF1B3D2B) : _CommodityPricesPageState._headerBackground;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: headerBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              isEnglish ? 'Commodity' : 'Komoditas',
              style: const TextStyle(
                color: _CommodityPricesPageState._green,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              isEnglish ? 'Unit' : 'Satuan',
              style: const TextStyle(
                color: _CommodityPricesPageState._green,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              isEnglish ? 'Price/Kg' : 'Harga/Kg',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _CommodityPricesPageState._green,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatefulWidget {
  final _CommodityPrice item;

  const _PriceCard({required this.item});

  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trendColor = item.isRising
        ? const Color(0xFF00A63E)
        : const Color(0xFFFF3147);
    final trendIcon = item.isRising ? Icons.trending_up : Icons.trending_down;

    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : _CommodityPricesPageState._title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _CommodityPricesPageState._muted;

    // Parse min/max from price string for detail display
    final priceParts = item.price.split(' - ');
    final minPrice = priceParts.isNotEmpty ? priceParts[0].trim() : '-';
    final maxPrice = priceParts.length > 1 ? priceParts[1].trim() : '-';

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: _expanded
              ? Border.all(color: _CommodityPricesPageState._green.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.08),
              blurRadius: _expanded ? 14 : 9,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B3D2B) : const Color(0xFFD7FBE5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.eco_outlined,
                    color: Color(0xFF079447),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.price,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(trendIcon, color: trendColor, size: 20),
                const SizedBox(width: 4),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 250),
                  turns: _expanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: mutedColor,
                    size: 22,
                  ),
                ),
              ],
            ),

            // Expandable detail section
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Divider(
                    color: isDark ? Colors.white12 : Colors.grey.shade200,
                    height: 1,
                  ),
                  const SizedBox(height: 14),

                  // Detail grid
                  Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.arrow_downward_rounded,
                          iconColor: const Color(0xFF2D832F),
                          label: 'Harga Min',
                          value: '$minPrice/kg',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.arrow_upward_rounded,
                          iconColor: const Color(0xFFE67E22),
                          label: 'Harga Maks',
                          value: '$maxPrice/kg',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _DetailTile(
                          icon: Icons.scale_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          label: 'Satuan',
                          value: '1 ${item.unit}',
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailTile(
                          icon: item.isRising ? Icons.trending_up : Icons.trending_down,
                          iconColor: trendColor,
                          label: 'Tren',
                          value: item.isRising ? 'Naik ▲' : 'Turun ▼',
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),

                  // Note section
                  if (item.note.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1B3D2B).withValues(alpha: 0.5) : const Color(0xFFF0FFF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : const Color(0xFFD7FBE5),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: _CommodityPricesPageState._green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.note,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF4B5563),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isDark;

  const _DetailTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF808080) : const Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onDetail;
  final VoidCallback? onShip;
  final VoidCallback? onStatusTap;

  const _OrderCard({
    required this.order,
    required this.onDetail,
    this.onShip,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Status translation for farmer view:
    String displayStatus;
    if (order.status == 'accept') {
      displayStatus = isEnglish ? 'Accepted' : 'Diterima';
    } else if (order.status == 'cancel') {
      displayStatus = isEnglish ? 'Cancelled' : 'Dibatalkan';
    } else if (order.status == 'packing') {
      displayStatus = isEnglish ? 'Packing' : 'Dikemas';
    } else if (order.status == 'dikirim') {
      displayStatus = isEnglish ? 'Shipped' : 'Dikirim';
    } else if (order.status == 'dalam perjalanan') {
      displayStatus = isEnglish ? 'In Transit' : 'Dalam Perjalanan';
    } else if (order.status == OrderModel.statusConfirmed) {
      displayStatus = isEnglish ? 'Awaiting Ship' : 'Menunggu Konfirmasi';
    } else if (order.status == OrderModel.statusShipped) {
      displayStatus = isEnglish ? 'Shipped' : 'Dikirim';
    } else if (order.status == OrderModel.statusDelivered) {
      displayStatus = isEnglish ? 'Completed' : 'Selesai';
    } else if (order.status == OrderModel.statusCancelled) {
      displayStatus = isEnglish ? 'Cancelled' : 'Dibatalkan';
    } else {
      displayStatus = isEnglish ? 'Processing' : 'Proses';
    }

    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF001A3D);
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF98A2B3);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${isEnglish ? 'Order' : 'Pesanan'} #${order.id}',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onStatusTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusBadge(displayStatus: displayStatus, status: order.status),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: mutedColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            order.productSummary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${formatRupiah(order.totalPrice.round())} - ${order.quantitySummary}',
            style: TextStyle(
              color: mutedColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PillButton(
                  label: isEnglish ? 'Details' : 'Detail',
                  backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7),
                  foregroundColor: isDark ? Colors.white : const Color(0xFF001A3D),
                  onTap: onDetail,
                ),
              ),
              if (onShip != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    label: isEnglish ? 'Ship' : 'Kirim',
                    icon: Icons.local_shipping,
                    backgroundColor: _CommodityPricesPageState._green,
                    foregroundColor: Colors.white,
                    onTap: onShip!,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String displayStatus;
  final String status;

  const _StatusBadge({required this.displayStatus, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isProcess = status == OrderModel.statusPending || status == OrderModel.statusConfirmed || status == 'accept' || status == 'packing';
    final isShipped = status == OrderModel.statusShipped || status == 'dikirim' || status == 'dalam perjalanan';
    final isCancelled = status == OrderModel.statusCancelled || status == 'cancel';

    final badgeBg = isShipped
        ? (isDark ? const Color(0xFF3D2E1B) : const Color(0xFFFFF3CD))
        : isProcess 
            ? (isDark ? const Color(0xFF1B3A5F) : const Color(0xFFD9E9FF))
            : isCancelled
                ? (isDark ? const Color(0xFF3D1B1B) : const Color(0xFFFDE8E8))
                : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7));
    final textColor = isShipped
        ? (isDark ? const Color(0xFFFFC107) : const Color(0xFF856404))
        : isProcess 
            ? (isDark ? const Color(0xFF7CB2FF) : const Color(0xFF1D63FF))
            : isCancelled
                ? (isDark ? const Color(0xFFF87171) : const Color(0xFF9B1C1C))
                : (isDark ? const Color(0xFFB0B0B0) : _CommodityPricesPageState._muted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foregroundColor, size: 20),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085);
    final valueColor = isDark ? Colors.white : const Color(0xFF101828);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: titleColor,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _CommodityPricesPageState._muted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: mutedColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CommodityPrice {
  final String name;
  final String unit;
  final String price;
  final bool isRising;
  final String note;

  const _CommodityPrice({
    required this.name,
    required this.unit,
    required this.price,
    required this.isRising,
    required this.note,
  });
}
