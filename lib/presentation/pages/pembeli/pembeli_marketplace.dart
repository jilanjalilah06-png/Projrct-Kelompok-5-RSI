import 'package:flutter/material.dart';
import 'product_detail_page.dart';

class PembeliMarketplace extends StatefulWidget {
  const PembeliMarketplace({super.key});

  @override
  State<PembeliMarketplace> createState() => _PembeliMarketplaceState();
}

class _PembeliMarketplaceState extends State<PembeliMarketplace> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  // Green theme colors
  static const Color _green = Color(0xFF159447);
  static const Color _greenLight = Color(0xFFE8F5E9);

  static const List<Map<String, dynamic>> _dummyProducts = [
    {
      'name': 'Padi Regular',
      'price': 'Rp 12.000/kg',
      'petani': 'Pak Budi',
      'icon': Icons.grain,
      'category': 'Padi',
      'rating': 4.7,
      'sold': 245,
      'stock': '20 kg',
    },
    {
      'name': 'Padi Premium',
      'price': 'Rp 15.000/kg',
      'petani': 'Pak Ahmad',
      'icon': Icons.grain,
      'category': 'Padi',
      'rating': 4.9,
      'sold': 182,
      'stock': '50 kg',
    },
    {
      'name': 'Jagung Regular',
      'price': 'Rp 10.000/kg',
      'petani': 'Bu Dewi',
      'icon': Icons.eco,
      'category': 'Jagung',
      'rating': 4.5,
      'sold': 356,
      'stock': '15 kg',
    },
    {
      'name': 'Jagung Premium',
      'price': 'Rp 17.000/kg',
      'petani': 'Bu Sari',
      'icon': Icons.eco,
      'category': 'Jagung',
      'rating': 4.8,
      'sold': 428,
      'stock': '30 kg',
    },
  ];

  final List<String> _categories = [
    'Semua',
    'Padi',
    'Jagung',
  ];

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 720;
    final products = _dummyProducts.where((product) {
      final categoryMatches =
          _selectedCategory == 'Semua' ||
          product['category'] == _selectedCategory;
      final queryMatches =
          _searchQuery.isEmpty ||
          (product['name'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (product['petani'] as String).toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return categoryMatches && queryMatches;
    }).toList();

    return Scaffold(
      backgroundColor: _greenLight,
      body: Column(
        children: [
          // Green gradient header with back button
          _buildHeader(context),
          // Main content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Cari produk pertanian...',
                        hintStyle: TextStyle(color: Color(0xFF98A2B3)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF98A2B3),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = category),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? _green : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? _green
                                      : const Color(0xFFD0D5DD),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF344054),
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
                  const SizedBox(height: 20),

                  // Product Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 3,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(context, product);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenAccent = Color(0xFF4CAF50);

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
                tooltip: 'Kembali ke Beranda',
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pasar Komoditas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Temukan produk segar dari petani lokal',
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

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductDetailPage()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE4E7EC),
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
            // Product Image/Icon with rating
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
            // Product Info
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
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                          product['petani'] as String,
                          style: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product['price'] as String,
                            style: const TextStyle(
                              color: _green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
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
