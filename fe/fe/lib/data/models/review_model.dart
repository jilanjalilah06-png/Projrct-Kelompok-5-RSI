class ReviewModel {
  final int id;
  final int productId;
  final int reviewerId;
  final int? orderId;
  final int rating;
  final String? comment;
  final String? reviewerName;
  final String? reviewerAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.reviewerId,
    this.orderId,
    required this.rating,
    this.comment,
    this.reviewerName,
    this.reviewerAvatar,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      reviewerId: (json['reviewer_id'] ?? json['user_id'] ?? 0) as int,
      orderId: json['order_id'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      reviewerName: json['reviewer']?['name'] as String?
          ?? json['user']?['name'] as String?
          ?? json['user_name'] as String?,
      reviewerAvatar: json['reviewer']?['avatar'] as String?
          ?? json['user']?['avatar'] as String?
          ?? json['user_avatar'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'reviewer_id': reviewerId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    int? id,
    int? productId,
    int? reviewerId,
    int? orderId,
    int? rating,
    String? comment,
    String? reviewerName,
    String? reviewerAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      reviewerId: reviewerId ?? this.reviewerId,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerAvatar: reviewerAvatar ?? this.reviewerAvatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ProductRatingModel {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // rating -> count

  ProductRatingModel({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ProductRatingModel.fromJson(Map<String, dynamic> json) {
    final dist = <int, int>{};
    if (json['rating_distribution'] is Map) {
      (json['rating_distribution'] as Map).forEach((key, value) {
        dist[int.parse(key.toString())] = value as int;
      });
    }

    return ProductRatingModel(
      averageRating: (json['average_rating'] is int)
          ? (json['average_rating'] as int).toDouble()
          : json['average_rating'] as double,
      totalReviews: json['total_reviews'] as int,
      ratingDistribution: dist,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'rating_distribution': ratingDistribution,
    };
  }
}
