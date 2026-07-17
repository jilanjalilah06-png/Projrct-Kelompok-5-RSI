import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/language_controller.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Green theme colors
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenAccent = Color(0xFF4CAF50);
  static const Color _greenLight = Color(0xFFE8F5E9);
  static const Color _bgColor = Color(0xFFF5F5F5);

  // Cart items are stored in CartController
  List<Map<String, dynamic>> get _cartItems => context.watch<CartController>().items;

    bool get _allSelected =>
      _cartItems.isNotEmpty && _cartItems.every((item) => item['selected'] == true || !item.containsKey('selected'));

    int get _selectedCount =>
      _cartItems.where((item) => item['selected'] == true || !item.containsKey('selected')).length;

  int get _totalPrice {
    int total = 0;
    for (final item in _cartItems) {
      final selected = item['selected'] == null ? true : item['selected'] == true;
      if (selected) {
        total += (item['price'] as int) * (item['qty'] as int);
      }
    }
    return total;
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i > 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  void _toggleSelectAll(bool? value) {
    final cart = context.read<CartController>();
    for (var i = 0; i < cart.items.length; i++) {
      cart.items[i]['selected'] = value ?? false;
    }
    setState(() {});
  }

  void _toggleItem(int index, bool? value) {
    context.read<CartController>().items[index]['selected'] = value ?? false;
    setState(() {});
  }

  void _incrementQty(int index) {
    context.read<CartController>().incrementQtyAt(index);
    setState(() {});
  }

  void _decrementQty(int index) {
    context.read<CartController>().decrementQtyAt(index);
    setState(() {});
  }

  void _removeItem(int index) {
    context.read<CartController>().removeItemAt(index);
    setState(() {});
  }

    List<Map<String, dynamic>> get _selectedItems =>
      context.read<CartController>().selectedItems;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : _bgColor,
      body: Column(
        children: [
          // Green gradient header
          _buildHeader(context),
          // Cart items list
          Expanded(
            child: RefreshIndicator(
              color: _green,
              onRefresh: () async {
                await context.read<CartController>().loadCart();
              },
              child: _cartItems.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [_buildEmptyCart()],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        return _buildCartItemCard(index);
                      },
                    ),
            ),
          ),
          // Bottom bar with total and checkout
          if (_cartItems.isNotEmpty) _buildBottomBar(context),
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
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
              Text(
                isEnglish ? 'My Cart' : 'Keranjang Saya',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              Text(
                isEnglish ? '${_cartItems.length} Items' : '${_cartItems.length} Item',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isEnglish ? 'Your cart is empty' : 'Keranjang masih kosong',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white60 : Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEnglish ? 'Let\'s start shopping for fresh products!' : 'Yuk, mulai belanja produk segar!',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final item = _cartItems[index];
    final int price = (item['price'] as num?)?.toInt() ?? (item['unit_price'] as num?)?.toInt() ?? 0;
    final int qty = (item['qty'] as num?)?.toInt() ?? 1;
    final int subtotal = price * qty;
    final bool isSelected = item['selected'] as bool? ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleItem(index, value),
                activeColor: _green,
                shape: const CircleBorder(),
                side: BorderSide(
                  color: isSelected ? _green : (isDark ? Colors.white30 : Colors.grey.shade300),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Product emoji icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1B3D2B) : _greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item['emoji']?.toString() ?? '🛒',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product info + quantity controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name']?.toString() ?? (isEnglish ? 'Unknown product' : 'Produk tidak diketahui'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_formatPrice(price)}/${item['unit']?.toString() ?? 'kg'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity controls
                  Row(
                    children: [
                      _buildQtyButton(
                        icon: Icons.remove,
                        onTap: () => _decrementQty(index),
                        enabled: qty > 1,
                      ),
                      Container(
                        width: 36,
                        alignment: Alignment.center,
                        child: Text(
                          '$qty',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1D2939),
                          ),
                        ),
                      ),
                      _buildQtyButton(
                        icon: Icons.add,
                        onTap: () => _incrementQty(index),
                        enabled: true,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right side: delete button + subtotal
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Delete button
                GestureDetector(
                  onTap: () => _showDeleteConfirm(index),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3D1E1E) : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Subtotal
                Text(
                  'Rp ${_formatPrice(subtotal)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D2939),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    bool isPrimary = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isPrimary
              ? _green
              : (enabled 
                  ? (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100) 
                  : (isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50)),
          borderRadius: BorderRadius.circular(20),
          border: isPrimary
              ? null
              : Border.all(
                  color: enabled 
                      ? (isDark ? Colors.white12 : Colors.grey.shade300) 
                      : (isDark ? Colors.white10 : Colors.grey.shade200),
                ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary
              ? Colors.white
              : (enabled ? (isDark ? Colors.white70 : Colors.grey.shade600) : (isDark ? Colors.white24 : Colors.grey.shade300)),
        ),
      ),
    );
  }

  void _showDeleteConfirm(int index) {
    final isEnglish = context.read<LanguageController>().isEnglish;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEnglish ? 'Remove Item' : 'Hapus Item'),
        content: Text(
          isEnglish
              ? 'Remove "${_cartItems[index]['name']}" from cart?'
              : 'Hapus "${_cartItems[index]['name']}" dari keranjang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isEnglish ? 'Cancel' : 'Batal',
              style: const TextStyle(color: Color(0xFF667085)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeItem(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isEnglish ? 'Remove' : 'Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnglish = context.watch<LanguageController>().isEnglish;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Select all + Total row
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _allSelected,
                      onChanged: _toggleSelectAll,
                      activeColor: _green,
                      shape: const CircleBorder(),
                      side: BorderSide(
                        color: _allSelected ? _green : (isDark ? Colors.white30 : Colors.grey.shade400),
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEnglish ? 'All' : 'Semua',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : const Color(0xFF344054),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEnglish ? 'Total: ' : 'Total: ',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF667085),
                    ),
                  ),
                  Text(
                    'Rp ${_formatPrice(_totalPrice)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1D2939),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Checkout button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: _green.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _selectedCount > 0
                      ? () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      CheckoutPage(items: _selectedItems),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  )),
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                            ),
                          )
                      : null,
                  child: Text(
                    'Checkout ($_selectedCount)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
