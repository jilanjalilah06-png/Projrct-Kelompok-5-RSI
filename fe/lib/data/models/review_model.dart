class ReviewModel {
  final int id;
  final int productId;
  final int userId;
  final int rating;
  final String? comment;
  final String? userName;
  final String? userAvatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.comment,
    this.userName,
    this.userAvatar,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      userId: json['user_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      userName: json['user_name'] as String? ?? json['user']?['name'] as String?,
      userAvatar:
          json['user_avatar'] as String? ?? json['user']?['avatar'] as String?,
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
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'user_name': userName,
      'user_avatar': userAvatar,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    int? id,
    int? productId,
    int? userId,
    int? rating,
    String? comment,
    String? userName,
    String? userAvatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
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
