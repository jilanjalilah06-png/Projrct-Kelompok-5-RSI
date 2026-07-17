class PlantingScheduleModel {
  final int id;
  final int userId;
  final String plant;
  final String land;
  final DateTime startDate;
  final DateTime harvestDate;
  final DateTime harvestEndDate;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PlantingScheduleModel({
    required this.id,
    required this.userId,
    required this.plant,
    required this.land,
    required this.startDate,
    required this.harvestDate,
    required this.harvestEndDate,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PlantingScheduleModel.fromJson(Map<String, dynamic> json) {
    return PlantingScheduleModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      plant: json['plant'] as String,
      land: json['land'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      harvestDate: DateTime.parse(json['harvest_date'] as String),
      harvestEndDate: DateTime.parse(json['harvest_end_date'] as String),
      status: json['status'] as String? ?? 'planned',
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
      'plant': plant,
      'land': land,
      'start_date': startDate.toIso8601String(),
      'harvest_date': harvestDate.toIso8601String(),
      'harvest_end_date': harvestEndDate.toIso8601String(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
