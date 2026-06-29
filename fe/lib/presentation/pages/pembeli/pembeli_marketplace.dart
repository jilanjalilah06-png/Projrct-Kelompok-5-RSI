import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';
import 'product_detail_page.dart';

class PembeliMarketplace extends StatefulWidget {
  const PembeliMarketplace({super.key});

  @override
  State<PembeliMarketplace> createState() => _PembeliMarketplaceState();
}

class _PembeliMarketplaceState extends State<PembeliMarketplace> {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  static const List<Map<String, dynamic>> _dummyProducts = [
    {
      'name': 'Padi Organik',
      'price': 'Rp 5.200/kg',
      'petani': 'Bandung',
      'icon': Icons.grain,
      'category': 'Padi',
      'rating': 4.8,
      'sold': 245,
    },
    {
      'name': 'Jagung Manis Segar',
      'price': 'Rp 4.800/kg',
      'petani': 'Bogor',
      'icon': Icons.grass,
      'category': 'Jagung',
      'rating': 4.6,
      'sold': 182,
    },
    {
      'name': 'Sayuran Segar',
      'price': 'Rp 3.500/kg',
      'petani': 'Karawang',
      'icon': Icons.eco,
      'category': 'Sayur',
      'rating': 4.7,
      'sold': 356,
    },
    {
      'name': 'Cabai Merah Keriting',
      'price': 'Rp 38.000/kg',
      'petani': 'Magelang',
      'icon': Icons.eco,
      'category': 'Cabai',
      'rating': 4.9,
      'sold': 428,
    },
    {
      'name': 'Kedelai Premium',
      'price': 'Rp 12.000/kg',
      'petani': 'Grobogan',
      'icon': Icons.spa,
      'category': 'Padi',
      'rating': 4.5,
      'sold': 197,
    },
    {
      'name': 'Buah Segar',
      'price': 'Rp 15.000/kg',
      'petani': 'Bangli',
      'icon': Icons.apple,
      'category': 'Buah',
      'rating': 4.8,
      'sold': 321,
    },
  ];

  final List<String> _categories = [
    'Semua',
    'Padi',
    'Jagung',
    'Sayur',
    'Cabai',
    'Buah',
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
      backgroundColor: AgriColors.background,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Pasar Komoditas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Temukan produk segar langsung dari petani lokal',
              style: TextStyle(color: AgriColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                decoration: InputDecoration(
                  hintText: 'Cari produk pertanian...',
                  hintStyle: const TextStyle(color: AgriColors.textLight),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AgriColors.textLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
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
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AgriColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AgriColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : AgriColors.accent,
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
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobile ? 180 : 240,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image/Icon
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: AgriColors.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  product['icon'] as IconData,
                  size: 40,
                  color: AgriColors.primary,
                ),
              ),
            ),
            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                            fontSize: 13,
                            color: AgriColors.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['price'] as String,
                          style: const TextStyle(
                            color: AgriColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product['rating']} (${product['sold']})',
                              style: const TextStyle(
                                color: AgriColors.textLight,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['petani'] as String,
                          style: const TextStyle(
                            color: AgriColors.textLight,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
