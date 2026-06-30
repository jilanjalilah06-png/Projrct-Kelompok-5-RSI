import 'dart:convert';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../../core/constanst/api_constants.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  /// Fetch all products
  /// Optional: can pass query parameters like page, limit, search, category, etc.
  Future<List<ProductModel>> getAllProducts({
    int? page,
    int? limit,
    String? search,
    int? categoryId,
    int? sellerId,
  }) async {
    String endpoint = ApiConstants.productsEndpoint;

    // Build query parameters
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (search != null) params['search'] = search;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (sellerId != null) params['seller_id'] = sellerId.toString();

    if (params.isNotEmpty) {
      final queryString = Uri(queryParameters: params).query;
      endpoint = '$endpoint?$queryString';
    }

    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      return (data)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat produk: ${response.statusCode}');
    }
  }

  /// Fetch a single product by ID
  Future<ProductModel> getProductById(int productId) async {
    final response = await _apiService.getRequest(
      '${ApiConstants.productsEndpoint}/$productId',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return ProductModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat produk: ${response.statusCode}');
    }
  }

  /// Fetch products by a specific seller
  Future<List<ProductModel>> getSellerProducts(int sellerId) async {
    final response = await _apiService.getRequest(
      '${ApiConstants.sellerProductsEndpoint}/$sellerId/products',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      return (data)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat produk penjual: ${response.statusCode}');
    }
  }

  /// Create a new product (Petani/Seller only)
  Future<ProductModel> createProduct({
    required int categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String unit,
    String? image,
  }) async {
    final response = await _apiService
        .postRequest(ApiConstants.productsEndpoint, {
          'category_id': categoryId,
          'name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'unit': unit,
          'image': ?image,
        });

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return ProductModel.fromJson(data);
    } else {
      throw Exception('Gagal membuat produk: ${response.statusCode}');
    }
  }

  /// Update a product (Petani/Seller only)
  Future<ProductModel> updateProduct(
    int productId, {
    int? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? unit,
    String? image,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};

    if (categoryId != null) body['category_id'] = categoryId;
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (price != null) body['price'] = price;
    if (stock != null) body['stock'] = stock;
    if (unit != null) body['unit'] = unit;
    if (image != null) body['image'] = image;
    if (isActive != null) body['is_active'] = isActive;

    final response = await _apiService.putRequest(
      '${ApiConstants.productsEndpoint}/$productId',
      body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final Map<String, dynamic> data = responseBody['data'];

      return ProductModel.fromJson(data);
    } else {
      throw Exception('Gagal memperbarui produk: ${response.statusCode}');
    }
  }

  /// Delete a product (Petani/Seller only)
  Future<void> deleteProduct(int productId) async {
    final response = await _apiService.deleteRequest(
      '${ApiConstants.productsEndpoint}/$productId',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus produk: ${response.statusCode}');
    }
  }

  /// Toggle product visibility (active/inactive)
  Future<ProductModel> toggleProductStatus(int productId, bool isActive) async {
    return updateProduct(productId, isActive: isActive);
  }
}
