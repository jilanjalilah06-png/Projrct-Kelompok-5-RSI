import 'package:flutter/material.dart';
import '../../widgets/order_notifications_sheet.dart';
import 'pembeli_marketplace.dart';

class PembeliDashboard extends StatefulWidget {
  const PembeliDashboard({super.key});

  @override
  State<PembeliDashboard> createState() => _PembeliDashboardState();
}

class _PembeliDashboardState extends State<PembeliDashboard> {
  String _selectedCategory = 'Semua';

  // Green theme colors matching the design
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);
  static const Color _greenAccent = Color(0xFF4CAF50);
  static const Color _cardBg = Colors.white;

  // Dummy products: Padi Regular, Padi Premium, Jagung Regular, Jagung Premium
  static const List<Map<String, dynamic>> _products = [
    {
      'name': 'Padi Regular',
      'category': 'Padi',
      'stock': '20 kg',
      'seller': 'Pak Budi',
      'price': 'Rp 12.000',
      'unit': '/kg',
      'rating': 4.7,
      'icon': Icons.grain,
      'isPremium': false,
    },
    {
      'name': 'Padi Premium',
      'category': 'Padi',
      'stock': '50 kg',
      'seller': 'Pak Ahmad',
      'price': 'Rp 15.000',
      'unit': '/kg',
      'rating': 4.9,
      'icon': Icons.grain,
      'isPremium': true,
    },
    {
      'name': 'Jagung Regular',
      'category': 'Jagung',
      'stock': '15 kg',
      'seller': 'Bu Dewi',
      'price': 'Rp 10.000',
      'unit': '/kg',
      'rating': 4.5,
      'icon': Icons.eco,
      'isPremium': false,
    },
    {
      'name': 'Jagung Premium',
      'category': 'Jagung',
      'stock': '30 kg',
      'seller': 'Bu Sari',
      'price': 'Rp 17.000',
      'unit': '/kg',
      'rating': 4.8,
      'icon': Icons.eco,
      'isPremium': true,
    },
  ];

  final List<String> _categories = ['Semua', 'Padi', 'Jagung'];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'Semua') return _products;
    return _products
        .where((p) => p['category'] == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildPromoBanner(context),
              const SizedBox(height: 20),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              _buildProductSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Logo icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    '🌾',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AgriConnect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              const OrderNotificationsButton(
                color: Colors.white,
                badgeColor: Color(0xFFFF5252),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Selamat Datang Pembeli',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Cari produk pertanian...',
            hintStyle: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF98A2B3),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_green, _greenAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _green.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Harga terbaik hari ini',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Produk Segar Langsung\ndari Petani!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PembeliMarketplace(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Lihat Pasar',
                        style: TextStyle(
                          color: _green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '🌿',
              style: TextStyle(fontSize: 56),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _green : _cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? _green
                          : const Color(0xFFD0D5DD),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: _green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF344054),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductSection(BuildContext context) {
    final products = _filteredProducts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produk Tersedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PembeliMarketplace(),
                  ),
                ),
                child: const Text(
                  'Lihat semua',
                  style: TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.68,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildProductCard(context, products[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final bool isPremium = product['isPremium'] as bool;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PembeliMarketplace()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium
                ? _green.withValues(alpha: 0.3)
                : const Color(0xFFE4E7EC),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with rating badge
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      product['icon'] as IconData,
                      size: 48,
                      color: _green,
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product['rating']}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF344054),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Product info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D2939),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Stok: ${product['stock']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product['seller'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF98A2B3),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${product['price']}${product['unit']}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _green,
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
