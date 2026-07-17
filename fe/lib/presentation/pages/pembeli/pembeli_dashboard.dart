import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/api_constants.dart';
import '../../controllers/language_controller.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/agri_brand_logo.dart';
import '../../widgets/order_notifications_sheet.dart';
import 'pembeli_marketplace.dart';
import 'product_detail_page.dart';

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

  final List<String> _categories = ['Semua', 'Beras', 'Jagung'];
  String _searchQuery = '';

  List<Map<String, dynamic>> _filteredProducts(
    List<Map<String, dynamic>> products,
  ) {
    var result = products;
    if (_selectedCategory != 'Semua') {
      result = result.where((p) => p['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) => p['name'].toString().toLowerCase().contains(q)).toList();
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().loadProducts(limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : _greenLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: _green,
          onRefresh: () async {
            await context.read<ProductController>().loadProducts(limit: 50);
            await context.read<CartController>().loadCart();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              const Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AgriBrandLogo(
                    useTextLogo: true,
                    textLogoHeight: 38,
                    iconSize: 38,
                    iconBackground: Colors.white,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const OrderNotificationsButton(
                color: Colors.white,
                badgeColor: Color(0xFFFF5252),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isEnglish ? 'Welcome Buyer' : 'Selamat Datang Pembeli',
            style: const TextStyle(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : _cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: isEnglish ? 'Search agricultural products...' : 'Cari produk pertanian...',
            hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF98A2B3), size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
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
                    isEnglish ? 'Best price today' : 'Harga terbaik hari ini',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnglish ? 'Fresh Products Directly\nfrom Farmers!' : 'Produk Segar Langsung\ndari Petani!',
                    style: const TextStyle(
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
                      child: Text(
                        isEnglish ? 'View Marketplace' : 'Lihat Pasar',
                        style: const TextStyle(
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
            const Text('🌿', style: TextStyle(fontSize: 56)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            final displayCat = cat == 'Semua' 
                ? (isEnglish ? 'All' : 'Semua') 
                : cat == 'Beras' 
                    ? (isEnglish ? 'Rice' : 'Beras') 
                    : cat == 'Jagung' 
                        ? (isEnglish ? 'Corn' : 'Jagung') 
                        : cat;

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
                    color: isSelected ? _green : (isDark ? const Color(0xFF1E1E1E) : _cardBg),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected 
                          ? _green 
                          : (isDark ? Colors.white24 : const Color(0xFFD0D5DD)),
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
    );
  }

  Widget _buildProductSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final productController = context.watch<ProductController>();
    final isLoading = productController.isLoading && productController.products.isEmpty;
    final sourceProducts = productController.products.isEmpty
        ? const <Map<String, dynamic>>[]
        : productController.products.map(_productToMap).toList();
    final products = _filteredProducts(sourceProducts).take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEnglish ? 'Available Products' : 'Produk Tersedia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1D2939),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PembeliMarketplace()),
                ),
                child: Text(
                  isEnglish ? 'See all' : 'Lihat semua',
                  style: const TextStyle(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  productController.lastError != null
                      ? (isEnglish ? 'Failed to load products from server.' : 'Tidak bisa memuat produk dari server.')
                      : (isEnglish ? 'No products available at the moment.' : 'Belum ada produk tersedia saat ini.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF667085)),
                ),
              ),
            )
          else
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium
                ? _green.withValues(alpha: 0.3)
                : (isDark ? Colors.white12 : const Color(0xFFE4E7EC)),
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
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
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
                          product['seller'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : const Color(0xFF98A2B3),
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
                        GestureDetector(
                          onTap: () async {
                            final cart = context.read<CartController>();
                            final item = {
                              'id': product['id'],
                              'product_id': product['product_id'],
                              'name': product['name'],
                              'price': product['rawPrice'] ?? 0,
                              'unit': product['unitName'] ?? product['unit']?.toString().replaceAll('/', '') ?? 'kg',
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
    final isPremium =
        product.name.toLowerCase().contains('premium') ||
        product.name.toLowerCase().contains('grade a') ||
        product.name.toLowerCase().contains('organik');

    return {
      'id': product.id,
      'product_id': product.id,
      'name': product.name,
      'description': product.description,
      'category': category,
      'stock': '${product.stock} ${product.unit}',
      'seller': sellerDisplay,
      'sellerName': sellerName,
      'shopName': shopName,
      'sellerDescription': product.seller?['shop_description']?.toString() ?? '',
      'sellerAddress': product.seller?['address']?.toString() ?? '',
      'sellerPhone': product.seller?['phone']?.toString() ?? '',
      'rawPrice': product.price.round(),
      'unitName': product.unit,
      'price': _formatRupiah(product.price),
      'unit': '/${product.unit}',
      'rating': (4.4 + (product.id % 6) / 10).toStringAsFixed(1),
      'icon': category == 'Jagung' ? Icons.eco : Icons.grain,
      'isPremium': isPremium,
      'image': product.image,
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
