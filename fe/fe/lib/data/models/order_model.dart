class OrderItemModel {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final double totalPrice;
  final Map<String, dynamic>? product;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _toInt(json['id']),
      orderId: _toInt(json['order_id']),
      productId: _toInt(json['product_id']),
      quantity: _toInt(json['quantity']),
      price: _toDouble(json['unit_price'] ?? json['price']),
      totalPrice: _toDouble(json['total_price']),
      product: json['product'] as Map<String, dynamic>?,
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
      'unit_price': price,
      'total_price': totalPrice,
      'product': product,
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
  final String? snapToken;
  final String? redirectUrl;
  final String? paymentType;
  final String? paymentStatus;
  final String? deliveryProof;
  final String? buyerReview;
  final int? buyerRating;
  final Map<String, dynamic>? buyer;
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
    this.snapToken,
    this.redirectUrl,
    this.paymentType,
    this.paymentStatus,
    this.deliveryProof,
    this.buyerReview,
    this.buyerRating,
    this.buyer,
    this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList =
        (json['items'] as List?)
            ?.map(
              (item) => OrderItemModel.fromJson(item as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return OrderModel(
      id: _toInt(json['id']),
      buyerId: _toInt(json['buyer_id']),
      orderNumber: json['order_number']?.toString() ?? '',
      totalPrice: _toDouble(json['total_price']),
      status: json['status']?.toString() ?? OrderModel.statusPending,
      shippingAddress: json['shipping_address']?.toString() ?? '',
      notes: json['notes']?.toString(),
      snapToken: json['snap_token']?.toString(),
      redirectUrl: json['redirect_url']?.toString(),
      paymentType: json['payment_type']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      deliveryProof: json['delivery_proof']?.toString(),
      buyerReview: json['buyer_review']?.toString(),
      buyerRating: json['buyer_rating'] != null ? _toInt(json['buyer_rating']) : null,
      buyer: json['buyer'] as Map<String, dynamic>?,
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
      'snap_token': snapToken,
      'redirect_url': redirectUrl,
      'payment_type': paymentType,
      'payment_status': paymentStatus,
      'delivery_proof': deliveryProof,
      'buyer_review': buyerReview,
      'buyer_rating': buyerRating,
      'buyer': buyer,
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
    String? snapToken,
    String? redirectUrl,
    String? paymentType,
    String? paymentStatus,
    String? deliveryProof,
    String? buyerReview,
    int? buyerRating,
    Map<String, dynamic>? buyer,
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
      snapToken: snapToken ?? this.snapToken,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      paymentType: paymentType ?? this.paymentType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryProof: deliveryProof ?? this.deliveryProof,
      buyerReview: buyerReview ?? this.buyerReview,
      buyerRating: buyerRating ?? this.buyerRating,
      buyer: buyer ?? this.buyer,
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

  String get buyerName => buyer?['name'] as String? ?? 'Pembeli #$buyerId';
  String get productSummary {
    final orderItems = items ?? [];
    if (orderItems.isEmpty) return '-';
    return orderItems
        .map(
          (item) =>
              item.product?['name'] as String? ?? 'Produk #${item.productId}',
        )
        .join(', ');
  }

  String get quantitySummary {
    final orderItems = items ?? [];
    if (orderItems.isEmpty) return '-';
    return orderItems
        .map((item) {
          final unit = item.product?['unit'] as String? ?? 'item';
          return '${item.quantity} $unit';
        })
        .join(', ');
  }
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
