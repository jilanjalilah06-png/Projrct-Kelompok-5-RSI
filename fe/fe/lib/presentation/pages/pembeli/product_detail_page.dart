import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../../core/constanst/api_constants.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/language_controller.dart';
import 'checkout_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductDetailPage({super.key, this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Green theme colors
  static const Color _green = Color(0xFF159447);
  static const Color _greenLight = Color(0xFFE8F5E9);

  int _qty = 2; // Minimal 2 kg
  int _stock = 0;

  @override
  void initState() {
    super.initState();
    // Parse stock
    var stockVal = widget.product?['stock'] ?? widget.product?['stok'];
    if (stockVal != null) {
      final digitsOnly = stockVal.toString().replaceAll(RegExp(r'[^0-9]'), '');
      _stock = int.tryParse(digitsOnly) ?? 0;
    }
    
    // Validasi minimal 2 jika stock > 1
    if (_stock < 2 && _stock > 0) {
      _qty = _stock;
    }
  }

  void _increment() {
    if (_qty < _stock) {
      setState(() => _qty++);
    }
  }

  void _decrement() {
    if (_qty > 2) {
      setState(() => _qty--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;

    final product = widget.product;
    final name = product?['name']?.toString() ?? 'Beras Premium';
    final price = product?['price']?.toString() ?? 'Rp 15.000 / kg';
    final rawPrice =
        product?['rawPrice'] as int? ??
        int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ??
        15000;
    final unit =
        product?['unitName']?.toString() ??
        product?['unit']?.toString().replaceAll('/', '') ??
        'kg';
    final sellerName =
        product?['sellerName']?.toString() ??
        product?['petani']?.toString() ??
        product?['seller']?.toString() ??
        'Petani AgriConnect';
    final shopName = product?['shopName']?.toString() ?? '';
    final sellerDescription = product?['sellerDescription']?.toString() ?? '';
    final sellerAddress = product?['sellerAddress']?.toString() ?? '';
    final sellerPhone = product?['sellerPhone']?.toString() ?? '';

    final description =
        product?['description']?.toString() ??
        (isEnglish
            ? '$name of the best quality from local farmers, processed with high hygiene standards. Suitable for household or business needs.'
            : '$name kualitas terbaik dari petani lokal, diproses dengan standar higienis tinggi. Cocok untuk kebutuhan rumah tangga maupun usaha.');
    final icon = product?['icon'] as IconData? ?? Icons.grain;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: _green,
        title: Text(
          isEnglish ? 'Product Details' : 'Detail Produk',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E3D2B) : _greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildProductImage(product, icon),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AgriColors.textDark,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _stock > 0 
                        ? (isDark ? const Color(0xFF1E351F) : _greenLight) 
                        : (isDark ? const Color(0xFF3D1E1E) : Colors.red.shade50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _stock > 0 ? _green : Colors.red),
                  ),
                  child: Text(
                    _stock > 0 
                        ? (isEnglish ? 'Stock: $_stock $unit' : 'Sisa Stok: $_stock $unit') 
                        : 'Sold',
                    style: TextStyle(
                      color: _stock > 0 ? _green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                color: _green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEnglish ? 'Product Description' : 'Deskripsi Produk',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty ? description : (isEnglish ? 'No product description.' : 'Tidak ada deskripsi produk.'),
              style: TextStyle(
                color: isDark ? Colors.white70 : AgriColors.textDark, 
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEnglish ? 'Seller Information' : 'Informasi Penjual',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE4E7EC)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sellerName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : AgriColors.textDark,
                    ),
                  ),
                  if (shopName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? 'Shop/Land Name: $shopName' : 'Nama Toko/Lahan: $shopName',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AgriColors.textLight,
                      ),
                    ),
                  ],
                  if (sellerDescription.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      sellerDescription,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : AgriColors.textDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (sellerAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: isDark ? Colors.white54 : AgriColors.textLight),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            sellerAddress,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AgriColors.textLight),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (sellerPhone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 16, color: isDark ? Colors.white54 : AgriColors.textLight),
                        const SizedBox(width: 6),
                        Text(
                          sellerPhone,
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : AgriColors.textLight),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Area Aksi (Kuantitas & Tombol)
            if (_stock > 0) ...[
              Text(
                isEnglish ? 'Specify Purchase Quantity' : 'Tentukan Jumlah Pembelian',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Selector
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _qty > 2 ? _decrement : null,
                          color: _green,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_qty',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: _qty < _stock ? _increment : null,
                          color: _green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEnglish ? 'Minimum 2 $unit' : 'Minimal 2 $unit', 
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _green, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final item = <String, dynamic>{
                            'id': product?['id'] ?? product?['product_id'],
                            'product_id': product?['product_id'] ?? product?['id'],
                            'name': name,
                            'price': rawPrice,
                            'unit': unit,
                            'qty': _qty,
                            'emoji': (product?['category'] == 'Jagung' || name.toLowerCase().contains('jagung')) ? '🌽' : '🌾',
                            'selected': true,
                          };

                          final cart = context.read<CartController>();
                          try {
                            await cart.addItem(item);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEnglish 
                                      ? 'Successfully added to cart!' 
                                      : 'Berhasil ditambahkan ke keranjang!'
                                  ),
                                  duration: const Duration(seconds: 2),
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
                        child: Text(
                          isEnglish ? '+ Cart' : '+ Keranjang',
                          style: const TextStyle(
                            color: _green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final item = <String, dynamic>{
                            'id': product?['id'] ?? product?['product_id'],
                            'product_id': product?['product_id'] ?? product?['id'],
                            'name': name,
                            'price': rawPrice,
                            'unit': unit,
                            'qty': _qty,
                            'emoji': (product?['category'] == 'Jagung' || name.toLowerCase().contains('jagung')) ? '🌽' : '🌾',
                            'selected': true,
                          };

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutPage(items: [item]),
                            ),
                          );
                        },
                        child: const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Habis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3D1E1E) : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.outbox_outlined, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Sold',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish ? 'This product is currently out of stock' : 'Produk ini telah habis terjual',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(Map<String, dynamic>? product, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: (product != null && product['image'] != null && product['image'].toString().isNotEmpty)
          ? Image.network(
              '${ApiConstants.storageUrl}/${product['image']}',
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackImage(product, icon),
            )
          : _buildFallbackImage(product, icon),
    );
  }

  Widget _buildFallbackImage(Map<String, dynamic>? product, IconData icon) {
    return Image.asset(
      product?['category'] == 'Jagung' 
          ? 'assets/image/jagung.jpg' 
          : 'assets/image/beras.jpg',
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: double.infinity,
        height: 240,
        color: const Color(0xFFF2F4F7),
        child: Icon(icon, size: 64, color: const Color(0xFF98A2B3)),
      ),
    );
  }
}
