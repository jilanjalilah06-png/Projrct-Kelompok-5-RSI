import 'dart:convert';
import '../services/api_service.dart';
import '../models/seller_model.dart';
import '../../core/constanst/api_constants.dart';

class SellerRepository {
  final ApiService _apiService;

  SellerRepository(this._apiService);

  /// Fetch all sellers
  Future<List<SellerModel>> getAllSellers({
    int? page,
    int? limit,
    bool? verified,
  }) async {
    String endpoint = ApiConstants.sellersEndpoint;

    // Build query parameters
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (verified != null) params['verified'] = verified.toString();

    if (params.isNotEmpty) {
      final queryString = Uri(queryParameters: params).query;
      endpoint = '$endpoint?$queryString';
    }

    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      return (data)
          .map((item) => SellerModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat penjual: ${response.statusCode}');
    }
  }

  /// Fetch a single seller by ID
  Future<SellerModel> getSellerById(int sellerId) async {
    final response = await _apiService
        .getRequest('${ApiConstants.sellersEndpoint}/$sellerId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return SellerModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat penjual: ${response.statusCode}');
    }
  }

  /// Get current seller's profile (Seller/Petani only)
  Future<SellerModel> getProfile() async {
    final response =
        await _apiService.getRequest(ApiConstants.sellerProfileEndpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return SellerModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat profil penjual: ${response.statusCode}');
    }
  }

  /// Update current seller's profile (Seller/Petani only)
  Future<SellerModel> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatar,
    String? shopName,
    String? shopDescription,
  }) async {
    final body = <String, dynamic>{};

    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (address != null) body['address'] = address;
    if (avatar != null) body['avatar'] = avatar;
    if (shopName != null) body['shop_name'] = shopName;
    if (shopDescription != null) body['shop_description'] = shopDescription;

    final response = await _apiService.putRequest(
      ApiConstants.sellerProfileEndpoint,
      body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final Map<String, dynamic> data = responseBody['data'];

      return SellerModel.fromJson(data);
    } else {
      throw Exception('Gagal memperbarui profil: ${response.statusCode}');
    }
  }

  /// Get current seller's statistics (Seller/Petani only)
  Future<SellerStatisticsModel> getStatistics({String? month}) async {
    String endpoint = ApiConstants.sellerStatisticsEndpoint;
    if (month != null && month.isNotEmpty) {
      final queryString = Uri(queryParameters: {'month': month}).query;
      endpoint = '$endpoint?$queryString';
    }
    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return SellerStatisticsModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat statistik: ${response.statusCode}');
    }
  }
}
