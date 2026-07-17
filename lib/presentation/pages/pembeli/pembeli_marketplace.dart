import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../../core/constanst/api_constants.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/product_controller.dart';
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

  final List<String> _categories = ['Semua', 'Beras', 'Jagung'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().loadProducts(limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 720;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final productController = context.watch<ProductController>();
    final sourceProducts = productController.products.isEmpty
        ? const <Map<String, dynamic>>[]
        : productController.products.map(_productToMap).toList();
    final products = sourceProducts.where((product) {
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
      backgroundColor: isDark ? const Color(0xFF121212) : _greenLight,
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
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: isEnglish ? 'Search agricultural products...' : 'Cari produk pertanian...',
                        hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF98A2B3),
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
                        final displayCat = category == 'Semua' 
                            ? (isEnglish ? 'All' : 'Semua') 
                            : category == 'Beras' 
                                ? (isEnglish ? 'Rice' : 'Beras') 
                                : category == 'Jagung' 
                                    ? (isEnglish ? 'Corn' : 'Jagung') 
                                    : category;

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
                                color: isSelected ? _green : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? _green
                                      : (isDark ? Colors.white24 : const Color(0xFFD0D5DD)),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                displayCat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF344054)),
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
                    child: RefreshIndicator(
                      onRefresh: () => context
                          .read<ProductController>()
                          .loadProducts(limit: 50),
                      child: productController.isLoading && productController.products.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : products.isEmpty
                              ? Center(
                                  child: Text(
                                    productController.lastError != null
                                        ? (isEnglish ? 'Failed to load products from server.' : 'Gagal memuat produk dari server.')
                                        : (isEnglish ? 'No products available at the moment.' : 'Belum ada produk tersedia saat ini.'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF667085)),
                                  ),
                                )
                              : GridView.builder(
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
                tooltip: isEnglish ? 'Back to Home' : 'Kembali ke Beranda',
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? 'Commodity Marketplace' : 'Pasar Komoditas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEnglish ? 'Find fresh products from local farmers' : 'Temukan produk segar dari petani lokal',
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

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE4E7EC),
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
                    color: isDark ? const Color(0xFF1B3D2B) : _greenLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: (product['image'] != null && product['image'].toString().isNotEmpty)
                        ? Image.network(
                            '${ApiConstants.storageUrl}/${product['image']}',
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackImage(product),
                          )
                        : _buildFallbackImage(product),
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
                      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
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
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : const Color(0xFF344054),
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF1D2939),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isEnglish ? 'Stock: ${product['stock']}' : 'Stok: ${product['stock']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product['petani'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.white38 : const Color(0xFF98A2B3),
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
                        GestureDetector(
                          onTap: () async {
                            final cart = context.read<CartController>();
                            final item = {
                              'id': product['id'],
                              'product_id': product['product_id'],
                              'name': product['name'],
                              'price': product['rawPrice'] ?? 0,
                              'unit': product['unitName'] ?? product['unit'],
                              'qty': 1,
                              'emoji': product['category'] == 'Jagung' ? '🌽' : '🌾',
                              'selected': true,
                            };
                            try {
                              await cart.addItem(item);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEnglish 
                                        ? '${product['name']} added to cart' 
                                        : '${product['name']} ditambahkan ke keranjang'
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEnglish 
                                        ? 'Failed to add to cart: $e' 
                                        : 'Gagal menambah ke keranjang: $e'
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
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

  Widget _buildFallbackImage(Map<String, dynamic> product) {
    return Image.asset(
      product['category'] == 'Jagung'
          ? 'assets/image/jagung.jpg'
          : 'assets/image/beras.jpg',
      width: double.infinity,
      height: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          product['icon'] as IconData,
          size: 48,
          color: _green,
        ),
      ),
    );
  }

  Map<String, dynamic> _productToMap(ProductModel product) {
    final category = product.category?['name']?.toString() ?? '';
    final shopName = product.seller?['shop_name']?.toString() ?? '';
    final sellerName = product.seller?['name']?.toString() ?? 'Petani AgriConnect';
    final sellerDisplay = shopName.isNotEmpty ? '$sellerName — $shopName' : sellerName;

    // Build full image URL from product image path
    String? imageUrl;
    if (product.image != null && product.image!.isNotEmpty) {
      imageUrl = '${ApiConstants.storageUrl}/${product.image}';
    }

    return {
      'id': product.id,
      'product_id': product.id,
      'name': product.name,
      'description': product.description,
      'rawPrice': product.price.round(),
      'unitName': product.unit,
      'price': '${_formatRupiah(product.price)}/${product.unit}',
      'petani': sellerDisplay,
      'sellerName': sellerName,
      'shopName': shopName,
      'sellerDescription': product.seller?['shop_description']?.toString() ?? '',
      'sellerAddress': product.seller?['address']?.toString() ?? '',
      'sellerPhone': product.seller?['phone']?.toString() ?? '',
      'imageUrl': imageUrl,
      'icon': category == 'Jagung' ? Icons.eco : Icons.grain,
      'category': category,
      'rating': (4.4 + (product.id % 6) / 10).toStringAsFixed(1),
      'sold': 120 + (product.id * 7),
      'stock': '${product.stock} ${product.unit}',
    };
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
