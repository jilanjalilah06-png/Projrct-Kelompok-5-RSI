import 'dart:convert';
import '../services/api_service.dart';
import '../models/category_model.dart';
import '../../core/constanst/api_constants.dart';

class CategoryRepository {
  final ApiService _apiService;

  CategoryRepository(this._apiService);

  /// Fetch all categories
  Future<List<CategoryModel>> getAllCategories() async {
    final response = await _apiService.getRequest(
      ApiConstants.categoriesEndpoint,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      return (data)
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat kategori: ${response.statusCode}');
    }
  }

  /// Fetch a single category by ID
  Future<CategoryModel> getCategoryById(int categoryId) async {
    final response = await _apiService.getRequest(
      '${ApiConstants.categoriesEndpoint}/$categoryId',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return CategoryModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat kategori: ${response.statusCode}');
    }
  }

  /// Create a new category (Admin only)
  Future<CategoryModel> createCategory({
    required String name,
    String? description,
  }) async {
    final body = <String, dynamic>{'name': name};

    if (description != null) body['description'] = description;

    final response = await _apiService.postRequest(
      ApiConstants.categoriesEndpoint,
      body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return CategoryModel.fromJson(data);
    } else {
      throw Exception('Gagal membuat kategori: ${response.statusCode}');
    }
  }

  /// Update a category (Admin only)
  Future<CategoryModel> updateCategory(
    int categoryId, {
    String? name,
    String? description,
  }) async {
    final body = <String, dynamic>{};

    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;

    final response = await _apiService.putRequest(
      '${ApiConstants.categoriesEndpoint}/$categoryId',
      body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final Map<String, dynamic> data = responseBody['data'];

      return CategoryModel.fromJson(data);
    } else {
      throw Exception('Gagal memperbarui kategori: ${response.statusCode}');
    }
  }

  /// Delete a category (Admin only)
  Future<void> deleteCategory(int categoryId) async {
    final response = await _apiService.deleteRequest(
      '${ApiConstants.categoriesEndpoint}/$categoryId',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus kategori: ${response.statusCode}');
    }
  }
}
