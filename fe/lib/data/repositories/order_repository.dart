import 'dart:convert';
import '../services/api_service.dart';
import '../models/order_model.dart';
import '../../core/constanst/api_constants.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  /// Fetch all orders (for current user or with filters)
  Future<List<OrderModel>> getAllOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    String endpoint = ApiConstants.ordersEndpoint;

    // Build query parameters
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (status != null) params['status'] = status;

    if (params.isNotEmpty) {
      final queryString = Uri(queryParameters: params).query;
      endpoint = '$endpoint?$queryString';
    }

    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      return (data)
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat pesanan: ${response.statusCode}');
    }
  }

  /// Fetch a single order by ID
  Future<OrderModel> getOrderById(int orderId) async {
    final response = await _apiService.getRequest(
      '${ApiConstants.ordersEndpoint}/$orderId',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return OrderModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat pesanan: ${response.statusCode}');
    }
  }

  /// Create a new order
  Future<OrderModel> createOrder({
    required List<Map<String, dynamic>> items, // [{product_id, quantity}, ...]
    required String shippingAddress,
    String? notes,
  }) async {
    final response = await _apiService.postRequest(
      ApiConstants.ordersEndpoint,
      {'items': items, 'shipping_address': shippingAddress, 'notes': ?notes},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return OrderModel.fromJson(data);
    } else {
      throw Exception('Gagal membuat pesanan: ${response.statusCode}');
    }
  }

  /// Update order status (Admin/Seller only)
  /// Status: pending, confirmed, shipped, delivered, cancelled
  Future<OrderModel> updateOrderStatus(int orderId, String status) async {
    final response = await _apiService.patchRequest(
      '${ApiConstants.ordersEndpoint}/$orderId/status',
      {'status': status},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return OrderModel.fromJson(data);
    } else {
      throw Exception(
        'Gagal memperbarui status pesanan: ${response.statusCode}',
      );
    }
  }

  /// Cancel an order
  Future<OrderModel> cancelOrder(int orderId) async {
    final response = await _apiService.postRequest(
      '${ApiConstants.ordersEndpoint}/$orderId/cancel',
      {},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return OrderModel.fromJson(data);
    } else {
      throw Exception('Gagal membatalkan pesanan: ${response.statusCode}');
    }
  }

  /// Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status) {
    return getAllOrders(status: status);
  }

  /// Get pending orders
  Future<List<OrderModel>> getPendingOrders() {
    return getOrdersByStatus(OrderModel.statusPending);
  }

  /// Get completed orders
  Future<List<OrderModel>> getCompletedOrders() {
    return getAllOrders(status: OrderModel.statusDelivered);
  }
}
