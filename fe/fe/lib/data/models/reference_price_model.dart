class ReferencePriceModel {
  final int id;
  final String name;
  final int minPrice;
  final int maxPrice;
  final String? note;
  final String? updatedBy;
  final DateTime? updatedAt;

  ReferencePriceModel({
    required this.id,
    required this.name,
    required this.minPrice,
    required this.maxPrice,
    this.note,
    this.updatedBy,
    this.updatedAt,
  });

  factory ReferencePriceModel.fromJson(Map<String, dynamic> json) {
    return ReferencePriceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      minPrice: json['min_price'] is int ? json['min_price'] : int.parse(json['min_price'].toString()),
      maxPrice: json['max_price'] is int ? json['max_price'] : int.parse(json['max_price'].toString()),
      note: json['note'],
      updatedBy: json['updated_by'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
