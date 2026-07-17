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
  List<Map<String, dynamic>> _notifications = [];

  AuthController(this._apiService)
    : _authRepository = AuthRepository(_apiService) {
    _apiService.onSessionExpired = () {
      _currentRole = null;
      _currentUser = null;
      _lastError = null;
      _notifications = [];
      notifyListeners();
    };
  }

  bool get isLoggedIn => _apiService.hasToken;
  String? get currentRole => _currentRole;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get notifications => _notifications;

  int get unreadNotificationsCount {
    return _notifications.where((n) {
      final isRead = n['is_read'];
      return isRead == 0 || isRead == false || isRead == '0' || isRead == null;
    }).length;
  }

  /// Pesan error terakhir dari server (null jika sukses / belum login).
  String? get lastError => _lastError;

  // =====================================================
  // MODE: REAL API — Tersambung ke Laravel via HTTP
  // =====================================================
  Future<bool> executeLogin(
    String email,
    String password, [
    String? intendedRole,
  ]) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final data = await _authRepository.login(email, password);

      final String token = data['token'] as String;
      final UserModel? user = data['user'] as UserModel?;

      final String serverRole = data['role'] as String;

      if (intendedRole != null) {
        final String normalizedIntended = intendedRole.toLowerCase();
        if (serverRole.toLowerCase() != normalizedIntended) {
          _lastError = 'Akun ini tidak memiliki akses sebagai $intendedRole.';
          return false;
        }
      }

      String capitalizedRole = serverRole;
      if (serverRole.toLowerCase() == 'admin') {
        capitalizedRole = 'Admin';
      } else if (serverRole.toLowerCase() == 'petani') {
        capitalizedRole = 'Petani';
      } else if (serverRole.toLowerCase() == 'pembeli') {
        capitalizedRole = 'Pembeli';
      }

      _apiService.updateToken(token);
      _currentRole = capitalizedRole;
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
    String? phone,
    String? username,
    String? nik,
    String? noRekening,
    String? namaBank,
    String? address,
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
        phone: phone,
        username: username,
        nik: nik,
        noRekening: noRekening,
        namaBank: namaBank,
        address: address,
      );

      if (data.containsKey('token') && data['token'] != null) {
        final String token = data['token'] as String;
        final UserModel? user = data['user'] as UserModel?;
        _apiService.updateToken(token);
        _currentRole = role;
        _currentUser = user;
      } else {
        // Just return true so the UI knows registration succeeded but they must wait
        // The message is displayed via UI or we can set lastError as a success message
        _lastError = 'Pendaftaran berhasil. Akun Anda sedang menunggu verifikasi.';
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
    _notifications = [];
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      _notifications = await _authRepository.getNotifications();
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsRead() async {
    _lastError = null;
    try {
      await _authRepository.markAllNotificationsRead();
      _notifications = _notifications.map((n) {
        final updated = Map<String, dynamic>.from(n);
        updated['is_read'] = 1; // Mark as read locally
        return updated;
      }).toList();
      notifyListeners();
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<void> markNotificationRead(int id) async {
    _lastError = null;
    try {
      await _authRepository.markNotificationRead(id);
      _notifications = _notifications.map((n) {
        if (n['id'] == id) {
          final updated = Map<String, dynamic>.from(n);
          updated['is_read'] = 1; // Mark as read locally
          return updated;
        }
        return n;
      }).toList();
      notifyListeners();
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final res = await _authRepository.forgotPassword(email);
      return res;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final res = await _authRepository.requestOtp(phone);
      return res;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPasswordOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _authRepository.resetPasswordOtp(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
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
