class ProductModel {
  final int id;
  final int sellerId;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? image;
  final String unit;
  final bool isActive;
  final Map<String, dynamic>? seller;
  final Map<String, dynamic>? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
    required this.unit,
    required this.isActive,
    this.seller,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      sellerId: json['seller_id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: _toDouble(json['price']),
      stock: json['stock'] as int,
      image: json['image'] as String?,
      unit: json['unit'] as String,
      isActive: json['is_active'] as bool? ?? true,
      seller: json['seller'] as Map<String, dynamic>?,
      category: json['category'] as Map<String, dynamic>?,
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
      'seller_id': sellerId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image': image,
      'unit': unit,
      'is_active': isActive,
      'seller': seller,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    int? id,
    int? sellerId,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? image,
    String? unit,
    bool? isActive,
    Map<String, dynamic>? seller,
    Map<String, dynamic>? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      image: image ?? this.image,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      seller: seller ?? this.seller,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
