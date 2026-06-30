import 'package:flutter/material.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/models/order_model.dart';
import '../../data/models/review_model.dart';
import '../../data/services/api_service.dart';

class OrderController extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final ReviewRepository _reviewRepository;

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  List<ReviewModel> _productReviews = [];
  ProductRatingModel? _productRating;
  bool _isLoading = false;
  String? _lastError;

  OrderController(ApiService apiService)
      : _orderRepository = OrderRepository(apiService),
        _reviewRepository = ReviewRepository(apiService);

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get currentOrder => _currentOrder;
  List<ReviewModel> get productReviews => _productReviews;
  ProductRatingModel? get productRating => _productRating;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  // ===================== ORDERS =====================

  Future<void> loadOrders({
    int? page,
    int? limit,
    String? status,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _orders = await _orderRepository.getAllOrders(
        page: page,
        limit: limit,
        status: status,
      );
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrderById(int orderId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentOrder = await _orderRepository.getOrderById(orderId);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingOrders() async {
    return loadOrders(status: OrderModel.statusPending);
  }

  Future<void> loadCompletedOrders() async {
    return loadOrders(status: OrderModel.statusDelivered);
  }

  Future<bool> createOrder({
    required List<Map<String, dynamic>> items,
    required String shippingAddress,
    String? notes,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final newOrder = await _orderRepository.createOrder(
        items: items,
        shippingAddress: shippingAddress,
        notes: notes,
      );

      _orders.insert(0, newOrder);
      _currentOrder = newOrder;
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus(int orderId, String status) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final updatedOrder = await _orderRepository.updateOrderStatus(orderId, status);

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index] = updatedOrder;
      }
      if (_currentOrder?.id == orderId) {
        _currentOrder = updatedOrder;
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

  Future<bool> cancelOrder(int orderId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final cancelledOrder = await _orderRepository.cancelOrder(orderId);

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        _orders[index] = cancelledOrder;
      }
      if (_currentOrder?.id == orderId) {
        _currentOrder = cancelledOrder;
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

  // ===================== REVIEWS =====================

  Future<void> loadProductReviews(int productId, {int? page, int? limit}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _productReviews = await _reviewRepository.getProductReviews(
        productId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductRating(int productId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _productRating = await _reviewRepository.getProductRating(productId);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final newReview = await _reviewRepository.createReview(
        productId: productId,
        rating: rating,
        comment: comment,
      );

      _productReviews.insert(0, newReview);
      // Reload product rating to update statistics
      await loadProductRating(productId);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReview(
    int reviewId, {
    int? rating,
    String? comment,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final updatedReview = await _reviewRepository.updateReview(
        reviewId,
        rating: rating,
        comment: comment,
      );

      final index = _productReviews.indexWhere((r) => r.id == reviewId);
      if (index >= 0) {
        _productReviews[index] = updatedReview;
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

  Future<bool> deleteReview(int reviewId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _reviewRepository.deleteReview(reviewId);
      _productReviews.removeWhere((r) => r.id == reviewId);
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
