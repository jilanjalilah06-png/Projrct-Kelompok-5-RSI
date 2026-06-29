import 'dart:convert';
import '../services/api_service.dart';
import '../models/review_model.dart';
import '../../core/constanst/api_constants.dart';

class ReviewRepository {
  final ApiService _apiService;

  ReviewRepository(this._apiService);

  /// Fetch all reviews (with optional filters)
  Future<List<ReviewModel>> getAllReviews({
    int? page,
    int? limit,
    int? productId,
  }) async {
    String endpoint = ApiConstants.reviewsEndpoint;

    // Build query parameters
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (productId != null) params['product_id'] = productId.toString();

    if (params.isNotEmpty) {
      final queryString = Uri(queryParameters: params).query;
      endpoint = '$endpoint?$queryString';
    }

    final response = await _apiService.getRequest(endpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      return (data)
          .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Gagal memuat ulasan: ${response.statusCode}');
    }
  }

  /// Fetch reviews for a specific product
  Future<List<ReviewModel>> getProductReviews(
    int productId, {
    int? page,
    int? limit,
  }) {
    return getAllReviews(productId: productId, page: page, limit: limit);
  }

  /// Fetch a single review by ID
  Future<ReviewModel> getReviewById(int reviewId) async {
    final response = await _apiService
        .getRequest('${ApiConstants.reviewsEndpoint}/$reviewId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return ReviewModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat ulasan: ${response.statusCode}');
    }
  }

  /// Get product rating and statistics
  Future<ProductRatingModel> getProductRating(int productId) async {
    final response = await _apiService.getRequest(
      '${ApiConstants.reviewsEndpoint}/products/$productId/rating',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return ProductRatingModel.fromJson(data);
    } else {
      throw Exception('Gagal memuat rating produk: ${response.statusCode}');
    }
  }

  /// Create a new review
  Future<ReviewModel> createReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    final response = await _apiService.postRequest(
      ApiConstants.reviewsEndpoint,
      {
        'product_id': productId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final Map<String, dynamic> data = body['data'];

      return ReviewModel.fromJson(data);
    } else {
      throw Exception('Gagal membuat ulasan: ${response.statusCode}');
    }
  }

  /// Update a review
  Future<ReviewModel> updateReview(
    int reviewId, {
    int? rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{};

    if (rating != null) body['rating'] = rating;
    if (comment != null) body['comment'] = comment;

    final response = await _apiService.putRequest(
      '${ApiConstants.reviewsEndpoint}/$reviewId',
      body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final Map<String, dynamic> data = responseBody['data'];

      return ReviewModel.fromJson(data);
    } else {
      throw Exception('Gagal memperbarui ulasan: ${response.statusCode}');
    }
  }

  /// Delete a review
  Future<void> deleteReview(int reviewId) async {
    final response =
        await _apiService.deleteRequest('${ApiConstants.reviewsEndpoint}/$reviewId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus ulasan: ${response.statusCode}');
    }
  }
}
