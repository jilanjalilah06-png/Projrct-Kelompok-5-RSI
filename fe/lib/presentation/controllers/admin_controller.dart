import 'package:flutter/foundation.dart';

import '../../data/models/category_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/reference_price_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/services/api_service.dart';

class AdminController extends ChangeNotifier {
  final AdminRepository _adminRepository;

  AdminDashboardData? _dashboard;
  List<UserModel> _users = [];
  List<OrderModel> _orders = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<Map<String, dynamic>> _activityLogs = [];
  List<ReferencePriceModel> _referencePrices = [];
  List<Map<String, dynamic>> _pendingPayouts = [];
  List<Map<String, dynamic>> _payoutHistory = [];
  String _searchQuery = '';
  bool _loading = false;
  String? _error;

  AdminController(ApiService apiService)
    : _adminRepository = AdminRepository(apiService);

  AdminDashboardData? get dashboard => _dashboard;
  List<UserModel> get users => _users;
  List<OrderModel> get orders => _orders;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  List<Map<String, dynamic>> get activityLogs => _activityLogs;
  List<ReferencePriceModel> get referencePrices => _referencePrices;
  List<Map<String, dynamic>> get pendingPayouts => _pendingPayouts;
  List<Map<String, dynamic>> get payoutHistory => _payoutHistory;
  String get searchQuery => _searchQuery;
  bool get loading => _loading;
  String? get error => _error;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    await _run(() async {
      _dashboard = await _adminRepository.getDashboardData();
    });
  }

  Future<void> loadUsers({String? role, String? search}) async {
    await _run(() async {
      _users = await _adminRepository.getUsers(role: role, search: search);
    });
  }

  Future<void> toggleUserStatus(int userId) async {
    await _run(() async {
      final updated = await _adminRepository.toggleUserStatus(userId);
      final index = _users.indexWhere((user) => user.id == userId);
      if (index >= 0) {
        _users[index] = updated;
      }
    });
  }

  Future<void> togglePetaniStatus(int userId) async {
    await _run(() async {
      final updated = await _adminRepository.togglePetaniStatus(userId);
      final index = _users.indexWhere((user) => user.id == userId);
      if (index >= 0) {
        _users[index] = updated;
      }
    });
  }

  Future<void> verifyUser(int userId) async {
    await _run(() async {
      final updated = await _adminRepository.verifyUser(userId);
      final index = _users.indexWhere((user) => user.id == userId);
      if (index >= 0) {
        _users[index] = updated;
      }
    });
  }

  Future<void> loadOrders({String? status, String? search}) async {
    await _run(() async {
      _orders = await _adminRepository.getOrders(status: status, search: search);
    });
  }

  Future<void> updateOrderStatus(int orderId, String status) async {
    await _run(() async {
      final updated = await _adminRepository.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index >= 0) {
        _orders[index] = updated;
        _orders = List.from(_orders); // Paksa reference baru agar UI mendeteksi perubahan
      }
      
      // Sinkronisasi ulang secara asinkron (optional tapi disarankan)
      _orders = await _adminRepository.getOrders();
    });
  }

  Future<void> loadCategories() async {
    await _run(() async {
      _categories = await _adminRepository.getCategories();
      _products = await _adminRepository.getProducts();
    });
  }

  Future<void> createCategory({
    required String name,
    String? description,
  }) async {
    await _run(() async {
      await _adminRepository.createCategory(
        name: name,
        description: description,
      );
      _categories = await _adminRepository.getCategories();
    });
  }

  Future<void> deleteCategory(int categoryId) async {
    await _run(() async {
      await _adminRepository.deleteCategory(categoryId);
      _categories.removeWhere((category) => category.id == categoryId);
    });
  }

  Future<void> loadProducts({String? search}) async {
    await _run(() async {
      _products = await _adminRepository.getProducts(search: search);
    });
  }

  Future<void> updateProductPrice(int productId, double price) async {
    await _run(() async {
      final updated = await _adminRepository.updateProductPrice(
        productId,
        price,
      );
      final index = _products.indexWhere((product) => product.id == productId);
      if (index >= 0) {
        _products[index] = updated;
      }
    });
  }

  Future<void> loadActivityLogs() async {
    await _run(() async {
      _activityLogs = await _adminRepository.getActivityLogs();
    });
  }

  Future<void> _run(Future<void> Function() task) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await task();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadReferencePrices({String? search}) async {
    await _run(() async {
      _referencePrices = await _adminRepository.getReferencePrices(search: search);
    });
  }

  Future<void> updateReferencePrice({
    required String name,
    required int minPrice,
    required int maxPrice,
    String? note,
  }) async {
    await _run(() async {
      final updated = await _adminRepository.updateReferencePrice(
        name: name,
        minPrice: minPrice,
        maxPrice: maxPrice,
        note: note,
      );
      final index = _referencePrices.indexWhere((p) => p.name == name);
      if (index >= 0) {
        _referencePrices[index] = updated;
        _referencePrices = List.from(_referencePrices);
      }
    });
  }

  Future<void> loadPayouts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _adminRepository.getPendingPayouts();
      _pendingPayouts = data['pending'] ?? [];
      _payoutHistory = data['history'] ?? [];
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> processPayout(int userId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _adminRepository.processPayout(userId);
      if (success) {
        await loadPayouts(); // refresh
      }
      return success;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
