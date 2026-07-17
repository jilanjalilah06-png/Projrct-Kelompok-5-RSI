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
  final String status;
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
    required this.status,
    this.seller,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final act = json['is_active'];
    final bool isActiveVal = act is bool
        ? act
        : (act is int ? act == 1 : (act is String ? act == '1' : true));

    return ProductModel(
      id: _toInt(json['id']),
      sellerId: _toInt(json['seller_id']),
      categoryId: _toInt(json['category_id']),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: _toDouble(json['price']),
      stock: _toInt(json['stock']),
      image: json['image'] as String?,
      unit: json['unit'] as String? ?? 'kg',
      isActive: isActiveVal,
      status: json['status'] as String? ?? (isActiveVal ? 'public' : 'tinjau'),
      seller: json['seller'] as Map<String, dynamic>?,
      category: json['category'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
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
      'status': status,
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
    String? status,
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
      status: status ?? this.status,
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
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}
