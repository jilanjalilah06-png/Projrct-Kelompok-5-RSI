import 'package:flutter/material.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/services/api_service.dart';

class ProductController extends ChangeNotifier {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  ProductModel? _currentProduct;
  CategoryModel? _currentCategory;
  bool _isLoading = false;
  String? _lastError;

  ProductController(ApiService apiService)
      : _productRepository = ProductRepository(apiService),
        _categoryRepository = CategoryRepository(apiService);

  // Getters
  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  ProductModel? get currentProduct => _currentProduct;
  CategoryModel? get currentCategory => _currentCategory;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  // ===================== PRODUCTS =====================

  Future<void> loadProducts({
    int? page,
    int? limit,
    String? search,
    int? categoryId,
    int? sellerId,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _products = await _productRepository.getAllProducts(
        page: page,
        limit: limit,
        search: search,
        categoryId: categoryId,
        sellerId: sellerId,
      );
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductById(int productId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentProduct = await _productRepository.getProductById(productId);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSellerProducts(int sellerId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _products = await _productRepository.getSellerProducts(sellerId);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProduct({
    required int categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String unit,
    String? image,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final newProduct = await _productRepository.createProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        unit: unit,
        image: image,
        imageBytes: imageBytes,
        imageName: imageName,
      );

      _products.insert(0, newProduct);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProduct(
    int productId, {
    int? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? unit,
    String? image,
    bool? isActive,
    String? status,
    List<int>? imageBytes,
    String? imageName,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final updatedProduct = await _productRepository.updateProduct(
        productId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        unit: unit,
        image: image,
        isActive: isActive,
        status: status,
        imageBytes: imageBytes,
        imageName: imageName,
      );

      final index = _products.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        _products[index] = updatedProduct;
      }
      if (_currentProduct?.id == productId) {
        _currentProduct = updatedProduct;
      }

      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int productId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _productRepository.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleProductStatus(int productId, bool isActive, {String? status}) async {
    return updateProduct(productId, isActive: isActive, status: status);
  }

  Future<bool> sendProductReviewNote(int productId, String note) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _productRepository.sendProductReviewNote(productId, note);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== CATEGORIES =====================

  Future<void> loadCategories() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _categories = await _categoryRepository.getAllCategories();
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategoryById(int categoryId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentCategory = await _categoryRepository.getCategoryById(categoryId);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory({
    required String name,
    String? description,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final newCategory = await _categoryRepository.createCategory(
        name: name,
        description: description,
      );

      _categories.insert(0, newCategory);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCategory(
    int categoryId, {
    String? name,
    String? description,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final updatedCategory = await _categoryRepository.updateCategory(
        categoryId,
        name: name,
        description: description,
      );

      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index >= 0) {
        _categories[index] = updatedCategory;
      }

      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _categoryRepository.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
