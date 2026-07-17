class SellerStatisticsModel {
  final int totalProducts;
  final int totalOrders;
  final int activeProducts;
  final double totalRevenue;
  final double netRevenue;
  final List<double> chartData;
  final double averageRating;
  final int totalReviews;

  SellerStatisticsModel({
    required this.totalProducts,
    required this.totalOrders,
    required this.activeProducts,
    required this.totalRevenue,
    required this.netRevenue,
    required this.chartData,
    required this.averageRating,
    required this.totalReviews,
  });

  factory SellerStatisticsModel.fromJson(Map<String, dynamic> json) {
    final totalProducts = json['total_products'] != null
        ? int.tryParse(json['total_products'].toString()) ?? 0
        : 0;
    final totalOrders = json['total_orders'] != null
        ? int.tryParse(json['total_orders'].toString()) ?? 0
        : 0;
    final activeProducts = json['active_products'] != null
        ? int.tryParse(json['active_products'].toString()) ?? 0
        : 0;
    final totalRevenue = json['total_revenue'] != null
        ? double.tryParse(json['total_revenue'].toString()) ?? 0.0
        : 0.0;
    final netRevenue = json['net_revenue'] != null
        ? double.tryParse(json['net_revenue'].toString()) ?? 0.0
        : totalRevenue * 0.94;
    final chartData = (json['chart_data'] as List?)
        ?.map((e) => double.tryParse(e.toString()) ?? 0.0)
        .toList() ?? <double>[];
    final averageRating = json['average_rating'] != null
        ? double.tryParse(json['average_rating'].toString()) ?? 0.0
        : 0.0;
    final totalReviews = json['total_reviews'] != null
        ? int.tryParse(json['total_reviews'].toString()) ?? 0
        : 0;

    return SellerStatisticsModel(
      totalProducts: totalProducts,
      totalOrders: totalOrders,
      activeProducts: activeProducts,
      totalRevenue: totalRevenue,
      netRevenue: netRevenue,
      chartData: chartData,
      averageRating: averageRating,
      totalReviews: totalReviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'total_orders': totalOrders,
      'active_products': activeProducts,
      'total_revenue': totalRevenue,
      'net_revenue': netRevenue,
      'chart_data': chartData,
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
