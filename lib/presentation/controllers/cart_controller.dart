import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/cart_repository.dart';

class CartController extends ChangeNotifier {
  final CartRepository _repo;

  CartController(ApiService apiService) : _repo = CartRepository(apiService) {
    loadCart();
  }

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  Future<void> loadCart() async {
    try {
      final cart = await _repo.getCart();
      _hydrateFromCart(cart);
    } catch (_) {
      // ignore load errors for now
    }
    notifyListeners();
  }

  static int _valueToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }

  void _hydrateFromCart(Map<String, dynamic> cart) {
    _items.clear();
    final items = (cart['items'] as List<dynamic>?) ?? [];
    for (final it in items) {
      final m = Map<String, dynamic>.from(it as Map<String, dynamic>);
      final product = m['product'] as Map<String, dynamic>?;
      final unitPrice = _valueToInt(m['unit_price'] ?? m['price'] ?? product?['price'] ?? 0);
      final quantity = _valueToInt(m['quantity'] ?? m['qty'] ?? 1);
      _items.add({
        'id': m['id'],
        'product_id': m['product_id'] ?? product?['id'],
        'name': product != null ? product['name'] : m['name'],
        'qty': quantity,
        'price': unitPrice,
        'unit_price': unitPrice,
        'unit': product != null ? product['unit'] : m['unit'] ?? 'kg',
        'total_price': _valueToInt(m['total_price'] ?? quantity * unitPrice),
        'product': product,
        'selected': m['selected'] ?? true,
      });
    }
  }

  Future<void> addItem(Map<String, dynamic> item) async {
    final productId = item['product_id'] ?? item['id'];
    final qty = item['qty'] as int? ?? 1;

    if (productId == null) return;

    try {
      final cart = await _repo.addItem(productId as int, quantity: qty);
      _hydrateFromCart(cart);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItemAt(int index) async {
    final item = _items[index];
    final id = item['id'];
    if (id == null) return;
    try {
      final cart = await _repo.removeItem(id as int);
      if (cart.isNotEmpty) {
        _hydrateFromCart(cart);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      await _repo.clearCart();
      _items.clear();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementQtyAt(int index) async {
    final item = _items[index];
    final id = item['id'];
    if (id == null) return;
    final newQty = (item['qty'] as int) + 1;
    try {
      final cart = await _repo.updateItem(id as int, newQty);
      _hydrateFromCart(cart);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> decrementQtyAt(int index) async {
    final item = _items[index];
    final id = item['id'];
    if (id == null) return;
    final current = item['qty'] as int;
    if (current > 1) {
      final newQty = current - 1;
      try {
        final cart = await _repo.updateItem(id as int, newQty);
        _hydrateFromCart(cart);
        notifyListeners();
      } catch (e) {
        rethrow;
      }
    }
  }

  List<Map<String, dynamic>> get selectedItems =>
      _items.where((i) => i['selected'] == true || !i.containsKey('selected')).toList();
}
