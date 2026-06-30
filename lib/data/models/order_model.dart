class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'] as double,
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
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class OrderModel {
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusShipped = 'shipped';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  final int id;
  final int buyerId;
  final String orderNumber;
  final double totalPrice;
  final String status;
  final String shippingAddress;
  final String? notes;
  final List<OrderItemModel>? items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.orderNumber,
    required this.totalPrice,
    required this.status,
    required this.shippingAddress,
    this.notes,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?)
            ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return OrderModel(
      id: json['id'] as int,
      buyerId: json['buyer_id'] as int,
      orderNumber: json['order_number'] as String,
      totalPrice: (json['total_price'] is int)
          ? (json['total_price'] as int).toDouble()
          : json['total_price'] as double,
      status: json['status'] as String,
      shippingAddress: json['shipping_address'] as String,
      notes: json['notes'] as String?,
      items: itemsList,
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
      'buyer_id': buyerId,
      'order_number': orderNumber,
      'total_price': totalPrice,
      'status': status,
      'shipping_address': shippingAddress,
      'notes': notes,
      'items': items?.map((item) => item.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    int? id,
    int? buyerId,
    String? orderNumber,
    double? totalPrice,
    String? status,
    String? shippingAddress,
    String? notes,
    List<OrderItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      orderNumber: orderNumber ?? this.orderNumber,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == statusPending;
  bool get isConfirmed => status == statusConfirmed;
  bool get isShipped => status == statusShipped;
  bool get isDelivered => status == statusDelivered;
  bool get isCancelled => status == statusCancelled;
  bool get isCompleted => status == statusDelivered;
  bool get isActive => !isCancelled && !isDelivered;
}
