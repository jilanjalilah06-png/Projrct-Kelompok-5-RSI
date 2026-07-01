import 'package:flutter/material.dart';

class CommodityPricesPage extends StatefulWidget {
  const CommodityPricesPage({super.key});

  @override
  State<CommodityPricesPage> createState() => _CommodityPricesPageState();
}

class _CommodityPricesPageState extends State<CommodityPricesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _headerBackground = Color(0xFFDCECDD);
  static const _title = Color(0xFF1F2937);
  static const _muted = Color(0xFF98A2B3);

  static const List<_CommodityPrice> _prices = [
    _CommodityPrice(
      name: 'Beras',
      unit: 'Kg',
      price: 'Rp 12.000',
      isRising: false,
    ),
    _CommodityPrice(
      name: 'Beras Premium',
      unit: 'Kg',
      price: 'Rp 15.000',
      isRising: true,
    ),
    _CommodityPrice(
      name: 'Jagung',
      unit: 'Kg',
      price: 'Rp 4.800',
      isRising: true,
    ),
    _CommodityPrice(
      name: 'Jagung Premium',
      unit: 'Kg',
      price: 'Rp 5.500',
      isRising: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrices = _prices
        .where((item) => item.name.toLowerCase().contains(_query))
        .toList();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              title: 'Harga Referensi',
              onBack: () => Navigator.pop(context),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: _SearchField(
                controller: _searchController,
                hintText: 'Cari komoditas...',
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const _TableHeader(),
                  const SizedBox(height: 8),
                  if (filteredPrices.isEmpty)
                    const _EmptyMessage(message: 'Komoditas tidak ditemukan.')
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

  static const List<_OrderInfo> _orders = [
    _OrderInfo(
      id: 1,
      productName: 'Beras',
      summary: 'Rp 40.000 - 2 Kg',
      status: _OrderStatus.process,
    ),
    _OrderInfo(
      id: 2,
      productName: 'Beras Premium',
      summary: 'Rp 75.000 - 5 Kg',
      status: _OrderStatus.done,
    ),
    _OrderInfo(
      id: 3,
      productName: 'Jagung',
      summary: 'Rp 48.000 - 10 Kg',
      status: _OrderStatus.done,
    ),
    _OrderInfo(
      id: 4,
      productName: 'Jagung Premium',
      summary: 'Rp 82.500 - 15 Kg',
      status: _OrderStatus.done,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((order) {
      final target = '${order.productName} ${order.id}'.toLowerCase();
      return target.contains(_query);
    }).toList();

    return Scaffold(
      backgroundColor: _CommodityPricesPageState._background,
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              title: 'Kelola Pesanan',
              onBack: () => Navigator.pop(context),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: _SearchField(
                controller: _searchController,
                hintText: 'Cari produk, ID pesanan...',
                onChanged: (value) {
                  setState(() => _query = value.trim().toLowerCase());
                },
              ),
            ),
            Expanded(
              child: filteredOrders.isEmpty
                  ? const _EmptyMessage(message: 'Pesanan tidak ditemukan.')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(8, 18, 8, 24),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _OrderCard(order: filteredOrders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _PageHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      color: _CommodityPricesPageState._green,
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
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: _CommodityPricesPageState._title,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _CommodityPricesPageState._muted,
          fontSize: 20,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF98A2B3),
          size: 28,
        ),
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
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
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: _CommodityPricesPageState._headerBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              'Komoditas',
              style: TextStyle(
                color: _CommodityPricesPageState._green,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Satuan',
              style: TextStyle(
                color: _CommodityPricesPageState._green,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Harga/Kg',
              textAlign: TextAlign.right,
              style: TextStyle(
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

class _PriceCard extends StatelessWidget {
  final _CommodityPrice item;

  const _PriceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final trendColor = item.isRising
        ? const Color(0xFF00A63E)
        : const Color(0xFFFF3147);
    final trendIcon = item.isRising ? Icons.trending_up : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD7FBE5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.eco_outlined,
              color: Color(0xFF079447),
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _CommodityPricesPageState._title,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              item.unit,
              style: const TextStyle(
                color: _CommodityPricesPageState._muted,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    item.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _CommodityPricesPageState._title,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(trendIcon, color: trendColor, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _OrderInfo order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final isProcess = order.status == _OrderStatus.process;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
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
                  'Pesanan #${order.id}',
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(isProcess: isProcess),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            order.productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF001A3D),
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.summary,
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PillButton(
                  label: 'Detail',
                  backgroundColor: const Color(0xFFF2F4F7),
                  foregroundColor: const Color(0xFF001A3D),
                  onTap: () {},
                ),
              ),
              if (isProcess) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    label: 'Selesai',
                    icon: Icons.check,
                    backgroundColor: _CommodityPricesPageState._green,
                    foregroundColor: Colors.white,
                    onTap: () {},
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
  final bool isProcess;

  const _StatusBadge({required this.isProcess});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isProcess ? const Color(0xFFD9E9FF) : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        isProcess ? 'Proses' : 'Selesai',
        style: TextStyle(
          color: isProcess
              ? const Color(0xFF1D63FF)
              : _CommodityPricesPageState._muted,
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

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: _CommodityPricesPageState._muted,
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

  const _CommodityPrice({
    required this.name,
    required this.unit,
    required this.price,
    required this.isRising,
  });
}

enum _OrderStatus { process, done }

class _OrderInfo {
  final int id;
  final String productName;
  final String summary;
  final _OrderStatus status;

  const _OrderInfo({
    required this.id,
    required this.productName,
    required this.summary,
    required this.status,
  });
}
