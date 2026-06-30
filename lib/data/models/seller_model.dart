class SellerStatisticsModel {
  final int totalProducts;
  final int totalOrders;
  final double totalRevenue;
  final double averageRating;
  final int totalReviews;

  SellerStatisticsModel({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageRating,
    required this.totalReviews,
  });

  factory SellerStatisticsModel.fromJson(Map<String, dynamic> json) {
    return SellerStatisticsModel(
      totalProducts: json['total_products'] as int,
      totalOrders: json['total_orders'] as int,
      totalRevenue: (json['total_revenue'] is int)
          ? (json['total_revenue'] as int).toDouble()
          : json['total_revenue'] as double,
      averageRating: (json['average_rating'] is int)
          ? (json['average_rating'] as int).toDouble()
          : json['average_rating'] as double,
      totalReviews: json['total_reviews'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'average_rating': averageRating,
      'total_reviews': totalReviews,
    };
  }
}

class SellerModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? avatar;
  final String? shopName;
  final String? shopDescription;
  final bool isVerified;
  final SellerStatisticsModel? statistics;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SellerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.avatar,
    this.shopName,
    this.shopDescription,
    required this.isVerified,
    this.statistics,
    this.createdAt,
    this.updatedAt,
  });

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      avatar: json['avatar'] as String?,
      shopName: json['shop_name'] as String?,
      shopDescription: json['shop_description'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      statistics: json['statistics'] != null
          ? SellerStatisticsModel.fromJson(
              json['statistics'] as Map<String, dynamic>)
          : null,
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
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'avatar': avatar,
      'shop_name': shopName,
      'shop_description': shopDescription,
      'is_verified': isVerified,
      'statistics': statistics?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SellerModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? avatar,
    String? shopName,
    String? shopDescription,
    bool? isVerified,
    SellerStatisticsModel? statistics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SellerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
      isVerified: isVerified ?? this.isVerified,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
