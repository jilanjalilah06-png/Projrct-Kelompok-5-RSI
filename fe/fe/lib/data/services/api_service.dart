import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/constanst/api_constants.dart';

class ApiService {
  static const Duration _requestTimeout = Duration(seconds: 45);


  String? _token;
  Timer? _sessionTimer;
  void Function()? onSessionExpired;

  bool get hasToken => _token != null;

  void updateToken(String? token) {
    _token = token;
    if (_token != null) {
      _startTimeoutCounter();
    } else {
      _sessionTimer?.cancel();
    }
  }

  void _startTimeoutCounter() {
    _sessionTimer?.cancel();
    // Kebijakan Keamanan: Sesi auto-logout setelah 2 jam pasif
    _sessionTimer = Timer(const Duration(hours: 2), () {
      updateToken(null);
      onSessionExpired?.call();
    });
  }

  void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) {
      updateToken(null);
      onSessionExpired?.call();
    }
  }

  Map<String, String> _buildHeaders() {
    if (hasToken) _startTimeoutCounter(); // Refresh timer aktivitas
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Map<String, String> _buildMultipartHeaders() {
    if (hasToken) _startTimeoutCounter();
    return {
      'Accept': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  String get _connectionErrorMessage =>
      'Tidak bisa terhubung ke server (${ApiConstants.baseUrl}). '
      'Pastikan Laravel sudah berjalan (php artisan serve) dan MySQL aktif.';

  Future<http.Response> getRequest(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _buildHeaders(),
          )
          .timeout(_requestTimeout);
      _checkUnauthorized(response.statusCode);
      return response;
    } on TimeoutException {
      throw Exception('Koneksi timeout. $_connectionErrorMessage');
    } on http.ClientException {
      throw Exception(_connectionErrorMessage);
    }
  }

  Future<http.Response> postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
      _checkUnauthorized(response.statusCode);
      return response;
    } on TimeoutException {
      throw Exception('Koneksi timeout. $_connectionErrorMessage');
    } on http.ClientException {
      throw Exception(_connectionErrorMessage);
    }
  }

  Future<http.Response> putRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
      _checkUnauthorized(response.statusCode);
      return response;
    } on TimeoutException {
      throw Exception('Koneksi timeout. $_connectionErrorMessage');
    } on http.ClientException {
      throw Exception(_connectionErrorMessage);
    }
  }

  Future<http.Response> patchRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _buildHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
      _checkUnauthorized(response.statusCode);
      return response;
    } on TimeoutException {
      throw Exception('Koneksi timeout. $_connectionErrorMessage');
    } on http.ClientException {
      throw Exception(_connectionErrorMessage);
    }
  }

  Future<http.Response> deleteRequest(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$endpoint'),
            headers: _buildHeaders(),
          )
          .timeout(_requestTimeout);
      _checkUnauthorized(response.statusCode);
      return response;
    } on TimeoutException {
      throw Exception('Koneksi timeout. $_connectionErrorMessage');
    } on http.ClientException {
      throw Exception(_connectionErrorMessage);
    }
  }

  Future<http.StreamedResponse> postMultipartRequest(
    String endpoint, {
    Map<String, String> fields = const {},
    Map<String, http.MultipartFile> files = const {},
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      );
      request.headers.addAll(_buildMultipartHeaders());
      request.fields.addAll(fields);
      request.files.addAll(files.values);

      final response = await request.send().timeout(_requestTimeout);
      _checkUnauthorized(response.statusCode);
      return response;
    } on TimeoutException {
      throw Exception('Koneksi timeout. $_connectionErrorMessage');
    } on http.ClientException {
      throw Exception(_connectionErrorMessage);
    }
  }

  Future<Map<String, dynamic>> sendChatbotMessage(String message) async {
    try {
      final response = await postRequest(
        ApiConstants.chatbotMessageEndpoint,
        {'message': message},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['message'] ?? 'Gagal mengirim pesan.');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
