import 'dart:convert';
import '../services/api_service.dart';
import '../../core/constanst/api_constants.dart';

class CartRepository {
  final ApiService _apiService;

  CartRepository(this._apiService);

  Future<Map<String, dynamic>> getCart() async {
    final response = await _apiService.getRequest(ApiConstants.cartEndpoint);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>;
    }
    throw Exception('Gagal memuat keranjang: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> addItem(int productId, {int quantity = 1}) async {
    final response = await _apiService.postRequest(
      ApiConstants.cartEndpoint,
      {'product_id': productId, 'quantity': quantity},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception('Gagal menambah item ke keranjang: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateItem(int itemId, int quantity) async {
    final response = await _apiService.patchRequest(
      '${ApiConstants.cartItemsEndpoint}/$itemId',
      {'quantity': quantity},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>;
    }

    throw Exception('Gagal memperbarui item keranjang: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> removeItem(int itemId) async {
    final response = await _apiService.deleteRequest('${ApiConstants.cartItemsEndpoint}/$itemId');

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return body['data'] as Map<String, dynamic>;
      }
      return {};
    }

    throw Exception('Gagal menghapus item keranjang: ${response.statusCode}');
  }

  Future<void> clearCart() async {
    final response = await _apiService.postRequest('${ApiConstants.cartEndpoint}/clear', {});
    if (response.statusCode != 200) {
      throw Exception('Gagal mengosongkan keranjang: ${response.statusCode}');
    }
  }
}
