import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

class AuthController extends ChangeNotifier {
  final ApiService _apiService;
  final AuthRepository _authRepository;

  String? _currentRole;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _lastError;

  AuthController(this._apiService)
    : _authRepository = AuthRepository(_apiService) {
    _apiService.onSessionExpired = () {
      _currentRole = null;
      _currentUser = null;
      _lastError = null;
      notifyListeners();
    };
  }

  bool get isLoggedIn => _apiService.hasToken;
  String? get currentRole => _currentRole;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  /// Pesan error terakhir dari server (null jika sukses / belum login).
  String? get lastError => _lastError;

  // =====================================================
  // MODE: REAL API — Tersambung ke Laravel via HTTP
  // =====================================================
  Future<bool> executeLogin(
    String email,
    String password,
    String intendedRole,
  ) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final data = await _authRepository.login(email, password);

      final String token = data['token'] as String;
      final UserModel? user = data['user'] as UserModel?;

      // Role dari server (lowercase) dicocokkan dengan intendedRole (Capitalized)
      final String serverRole = (data['role'] as String).toLowerCase();
      final String normalizedIntended = intendedRole.toLowerCase();

      if (serverRole != normalizedIntended) {
        _lastError = 'Akun ini tidak memiliki akses sebagai $intendedRole.';
        return false;
      }

      _apiService.updateToken(token);
      _currentRole = intendedRole; // simpan versi Capitalized untuk navigasi
      _currentUser = user;
      return true;
    } catch (e) {
      // Tampilkan pesan error dari server / koneksi
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> executeRegister({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final data = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );

      final String token = data['token'] as String;
      final UserModel? user = data['user'] as UserModel?;
      _apiService.updateToken(token);
      _currentRole = role;
      _currentUser = user;
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? shopName,
    String? shopDescription,
    XFile? avatar,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _currentUser = await _authRepository.updateProfile(
        name: name,
        phone: phone,
        address: address,
        shopName: shopName,
        shopDescription: shopDescription,
        avatar: avatar,
      );
      _currentRole = _currentUser?.role ?? _currentRole;
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> executeLogout() async {
    await _authRepository.logout();
    _apiService.updateToken(null);
    _currentRole = null;
    _currentUser = null;
    _lastError = null;
    notifyListeners();
  }
}
