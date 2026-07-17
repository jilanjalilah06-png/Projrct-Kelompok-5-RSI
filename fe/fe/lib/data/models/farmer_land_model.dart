class FarmerLandModel {
  final int id;
  final int userId;
  final String name;
  final double latitude;
  final double longitude;
  final String? areaSize;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FarmerLandModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.areaSize,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory FarmerLandModel.fromJson(Map<String, dynamic> json) {
    return FarmerLandModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      areaSize: json['area_size'] as String?,
      description: json['description'] as String?,
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
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'area_size': areaSize,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
