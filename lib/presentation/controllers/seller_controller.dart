import 'package:flutter/material.dart';
import '../../data/repositories/seller_repository.dart';
import '../../data/models/seller_model.dart';
import '../../data/services/api_service.dart';

class SellerController extends ChangeNotifier {
  final SellerRepository _sellerRepository;

  List<SellerModel> _sellers = [];
  SellerModel? _currentSeller;
  SellerStatisticsModel? _statistics;
  bool _isLoading = false;
  String? _lastError;

  SellerController(ApiService apiService)
      : _sellerRepository = SellerRepository(apiService);

  // Getters
  List<SellerModel> get sellers => _sellers;
  SellerModel? get currentSeller => _currentSeller;
  SellerStatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  // ===================== SELLERS =====================

  Future<void> loadSellers({
    int? page,
    int? limit,
    bool? verified,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _sellers = await _sellerRepository.getAllSellers(
        page: page,
        limit: limit,
        verified: verified,
      );
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSellerById(int sellerId) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentSeller = await _sellerRepository.getSellerById(sellerId);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentSeller = await _sellerRepository.getProfile();
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatar,
    String? shopName,
    String? shopDescription,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final updatedSeller = await _sellerRepository.updateProfile(
        name: name,
        phone: phone,
        address: address,
        avatar: avatar,
        shopName: shopName,
        shopDescription: shopDescription,
      );

      _currentSeller = updatedSeller;
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics({String? month}) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _statistics = await _sellerRepository.getStatistics(month: month);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all seller data (profile + statistics)
  Future<void> loadAllData() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      // Load profile and statistics in parallel
      await Future.wait([
        loadProfile(),
        loadStatistics(),
      ]);
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
