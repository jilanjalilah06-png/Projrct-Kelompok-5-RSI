import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../../core/constanst/api_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  AuthRepository(this._apiService);

  /// Login ke Laravel API.
  /// Mengembalikan map yang berisi: `token` (String), `role` (String), dan `user` (UserModel).
  /// Response format dari backend:
  /// {
  ///   "success": true,
  ///   "message": "Login successful",
  ///   "data": {
  ///     "user": { "role": "Admin|Petani|Pembeli", ... },
  ///     "token": "..."
  ///   }
  /// }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.postRequest(
      ApiConstants.loginEndpoint,
      {'email': email, 'password': password},
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Navigasi ke data.token dan data.user
      final dynamic dataMap = body['data'];
      if (dataMap is! Map) {
        throw Exception('Response API tidak memiliki struktur yang diharapkan.');
      }

      final String? token = dataMap['token'] as String?;
      if (token == null) {
        throw Exception('Response API tidak mengandung token.');
      }

      // Ambil role dari data.user.role
      final dynamic userMap = dataMap['user'];
      final String? role = (userMap is Map ? userMap['role'] as String? : null);
      if (role == null) {
        throw Exception('Response API tidak mengandung role pengguna.');
      }

      final UserModel user = UserModel.fromJson(Map<String, dynamic>.from(userMap as Map));

      return {'token': token, 'role': role, 'user': user};
    } else {
      // Ambil pesan error dari Laravel jika ada
      final String message =
          body['message'] as String? ?? 'Gagal login, periksa kredensial Anda.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> register({
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
    final response = await _apiService.postRequest(
      ApiConstants.registerEndpoint,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'role': role,
        'phone': phone,
        'username': username,
        'nik': nik,
        'no_rekening': noRekening,
        'nama_bank': namaBank,
        'address': address,
      },
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final dynamic dataMap = body['data'];
      if (dataMap is! Map) {
        throw Exception('Response API tidak memiliki struktur yang diharapkan.');
      }

      final String? token = dataMap['token'] as String?;

      final dynamic userMap = dataMap['user'];
      final String? responseRole = (userMap is Map ? userMap['role'] as String? : null);
      if (responseRole == null) {
        throw Exception('Response API tidak mengandung role.');
      }

      final UserModel user = UserModel.fromJson(Map<String, dynamic>.from(userMap as Map));

      return {'token': token, 'role': responseRole, 'user': user};
    } else {
      final String message = _errorMessage(
        body,
        fallback: 'Gagal registrasi, silakan coba lagi.',
      );
      throw Exception(message);
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? shopName,
    String? shopDescription,
    XFile? avatar,
  }) async {
    final fields = <String, String>{};
    if (name != null) fields['name'] = name;
    if (phone != null) fields['phone'] = phone;
    if (address != null) fields['address'] = address;
    if (shopName != null) fields['shop_name'] = shopName;
    if (shopDescription != null) fields['shop_description'] = shopDescription;

    final files = <String, http.MultipartFile>{};
    if (avatar != null) {
      files['avatar'] = http.MultipartFile.fromBytes(
        'avatar',
        await avatar.readAsBytes(),
        filename: avatar.name,
      );
    }

    final streamedResponse = await _apiService.postMultipartRequest(
      ApiConstants.profileEndpoint,
      fields: fields,
      files: files,
    );
    final response = await http.Response.fromStream(streamedResponse);
    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(Map<String, dynamic>.from(body['data'] as Map));
    }

    throw Exception(
      _errorMessage(body, fallback: 'Gagal memperbarui profil.'),
    );
  }

  /// Logout dari Laravel API (invalidate token di server).
  Future<void> logout() async {
    try {
      await _apiService.postRequest(ApiConstants.logoutEndpoint, {});
    } catch (_) {
      // Jika gagal hit endpoint logout, tetap lanjutkan proses local logout
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _apiService.getRequest('/notifications');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List? ?? [];
      return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }

    throw Exception('Gagal memuat notifikasi: ${response.statusCode}');
  }

  Future<void> markAllNotificationsRead() async {
    final response = await _apiService.postRequest('/notifications/mark-read', {});

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai semua dibaca: ${response.statusCode}');
    }
  }

  Future<void> markNotificationRead(int id) async {
    final response = await _apiService.postRequest('/notifications/$id/mark-read', {});

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai dibaca: ${response.statusCode}');
    }
  }

  String _errorMessage(
    Map<String, dynamic> body, {
    required String fallback,
  }) {
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
      return first.toString();
    }

    return body['message'] as String? ?? fallback;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _apiService.postRequest('/auth/forgot-password', {
      'email': email,
    });

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return body;
    }
    throw Exception(body['message'] ?? 'Email tidak ditemukan.');
  }

  Future<Map<String, dynamic>> requestOtp(String phone) async {
    final response = await _apiService.postRequest('/auth/request-otp', {
      'phone': phone,
    });

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return body;
    }
    throw Exception(body['message'] ?? 'Nomor WhatsApp tidak terdaftar.');
  }

  Future<void> resetPasswordOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _apiService.postRequest('/auth/reset-password-otp', {
      'phone': phone,
      'otp': otp,
      'new_password': newPassword,
    });

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Gagal memperbarui kata sandi.');
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _apiService.postRequest('/auth/change-password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['message'] ?? 'Gagal mengubah kata sandi.');
    }
  }
}
