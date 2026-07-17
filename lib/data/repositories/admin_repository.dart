import 'dart:convert';

import '../../core/constanst/api_constants.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../models/reference_price_model.dart';
import '../services/api_service.dart';

class AdminDashboardData {
  final int totalPetani;
  final int totalPembeli;
  final int activeUsers;
  final int totalProducts;
  final int totalStock;
  final int totalOrders;
  final double totalRevenue;
  final List<Map<String, dynamic>> recentActivity;
  final List<Map<String, dynamic>> transactions;
  final int unverifiedPetaniCount;
  final int pendingOrdersCount;
  final int pendingPayoutsCount;

  const AdminDashboardData({
    required this.totalPetani,
    required this.totalPembeli,
    required this.activeUsers,
    required this.totalProducts,
    required this.totalStock,
    required this.totalOrders,
    required this.totalRevenue,
    required this.recentActivity,
    required this.transactions,
    required this.unverifiedPetaniCount,
    required this.pendingOrdersCount,
    required this.pendingPayoutsCount,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      totalPetani: _toInt(json['total_petani']),
      totalPembeli: _toInt(json['total_pembeli']),
      activeUsers: _toInt(json['active_users']),
      totalProducts: _toInt(json['total_products']),
      totalStock: _toInt(json['total_stock']),
      totalOrders: _toInt(json['total_orders']),
      totalRevenue: _toDouble(json['total_revenue']),
      recentActivity: (json['recent_activity'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      transactions: (json['transactions'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      unverifiedPetaniCount: _toInt(json['unverified_petani_count']),
      pendingOrdersCount: _toInt(json['pending_orders_count']),
      pendingPayoutsCount: _toInt(json['pending_payouts_count']),
    );
  }
}

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  Future<AdminDashboardData> getDashboardData() async {
    final response = await _apiService.getRequest(
      ApiConstants.adminStatisticsEndpoint,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return AdminDashboardData.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal memuat statistik admin: ${response.statusCode}');
  }

  Future<List<UserModel>> getUsers({String? role, String? search}) async {
    var endpoint = ApiConstants.adminUsersEndpoint;
    final params = <String, String>{};

    if (role != null && role.isNotEmpty && role != 'Semua Role') {
      params['role'] = role;
    }
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    if (params.isNotEmpty) {
      endpoint = '$endpoint?${Uri(queryParameters: params).query}';
    }

    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal memuat user: ${response.statusCode}');
  }

  Future<UserModel> toggleUserStatus(int userId) async {
    final response = await _apiService.postRequest(
      '${ApiConstants.adminUsersEndpoint}/$userId/toggle',
      {},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    throw Exception(body?['message'] ?? 'Gagal mengubah status user.');
  }

  Future<UserModel> togglePetaniStatus(int userId) async {
    final response = await _apiService.postRequest(
      '/admin/petani/$userId/toggle',
      {},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    throw Exception(body?['message'] ?? 'Gagal mengubah status petani.');
  }

  Future<UserModel> verifyUser(int userId) async {
    final response = await _apiService.postRequest(
      '${ApiConstants.adminUsersEndpoint}/$userId/verify',
      {},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    throw Exception(body?['message'] ?? 'Gagal memverifikasi user.');
  }

  Future<List<OrderModel>> getOrders({String? status, String? search}) async {
    var endpoint = ApiConstants.ordersEndpoint;
    final params = <String, String>{'limit': '100'};

    if (status != null && status.isNotEmpty && status != 'Semua Status') {
      params['status'] = status;
    }
    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    endpoint = '$endpoint?${Uri(queryParameters: params).query}';
    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal memuat order: ${response.statusCode}');
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiService.getRequest(
      ApiConstants.categoriesEndpoint,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal memuat komoditas: ${response.statusCode}');
  }

  Future<CategoryModel> createCategory({
    required String name,
    String? description,
  }) async {
    final response = await _apiService.postRequest(
      ApiConstants.categoriesEndpoint,
      {'name': name, 'description': description},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return CategoryModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal menambah komoditas: ${response.statusCode}');
  }

  Future<void> deleteCategory(int categoryId) async {
    final response = await _apiService.deleteRequest(
      '${ApiConstants.categoriesEndpoint}/$categoryId',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus komoditas: ${response.statusCode}');
    }
  }

  Future<List<ProductModel>> getProducts({String? search}) async {
    var endpoint = ApiConstants.productsEndpoint;
    final params = <String, String>{'limit': '100'};

    if (search != null && search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }

    endpoint = '$endpoint?${Uri(queryParameters: params).query}';
    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal memuat harga referensi: ${response.statusCode}');
  }

  Future<ProductModel> updateProductPrice(int productId, double price) async {
    final response = await _apiService.putRequest(
      '${ApiConstants.productsEndpoint}/$productId',
      {'price': price},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ProductModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal memperbarui harga: ${response.statusCode}');
  }

  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    final response = await _apiService.patchRequest(
      '${ApiConstants.ordersEndpoint}/$orderId/status',
      {'status': status},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return OrderModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception('Gagal memperbarui status order: ${response.statusCode}');
  }

  Future<List<Map<String, dynamic>>> getActivityLogs() async {
    final response = await _apiService.getRequest('/admin/activity-logs');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }

    throw Exception('Gagal memuat log aktivitas: ${response.statusCode}');
  }

  Future<List<ReferencePriceModel>> getReferencePrices({String? search}) async {
    var endpoint = ApiConstants.adminReferencePricesEndpoint;
    if (search != null && search.trim().isNotEmpty) {
      endpoint = '$endpoint?search=${Uri.encodeComponent(search.trim())}';
    }

    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data
          .map((item) => ReferencePriceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal memuat harga referensi: ${response.statusCode}');
  }

  Future<ReferencePriceModel> updateReferencePrice({
    required String name,
    required int minPrice,
    required int maxPrice,
    String? note,
  }) async {
    final response = await _apiService.postRequest(
      ApiConstants.adminUpdateReferencePriceEndpoint,
      {
        'name': name,
        'min_price': minPrice,
        'max_price': maxPrice,
        'note': note,
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ReferencePriceModel.fromJson(body['data'] as Map<String, dynamic>);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    throw Exception(body?['message'] ?? 'Gagal memperbarui harga referensi.');
  }

  Future<Map<String, dynamic>> getPendingPayouts() async {
    final response = await _apiService.getRequest('/admin/payouts/pending');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};
      return {
        'pending': (data['pending'] as List? ?? []).map((e) => e as Map<String, dynamic>).toList(),
        'history': (data['history'] as List? ?? []).map((e) => e as Map<String, dynamic>).toList(),
      };
    }

    throw Exception('Gagal memuat data pencairan: ${response.statusCode}');
  }

  Future<bool> processPayout(int userId) async {
    final response = await _apiService.postRequest('/admin/payouts/process', {'user_id': userId});
    
    if (response.statusCode == 200) {
      return true;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    throw Exception(body?['message'] ?? 'Gagal memproses pencairan dana.');
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
