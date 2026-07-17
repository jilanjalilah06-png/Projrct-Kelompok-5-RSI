import 'dart:convert';
import '../services/api_service.dart';
import '../models/planting_schedule_model.dart';
import '../models/farmer_land_model.dart';
import '../../core/constanst/api_constants.dart';

class PlantingScheduleRepository {
  final ApiService _apiService;

  PlantingScheduleRepository(this._apiService);

  // --- Planting Schedules ---

  Future<List<PlantingScheduleModel>> getSchedules() async {
    final response = await _apiService.getRequest(ApiConstants.plantingSchedulesEndpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((item) => PlantingScheduleModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat jadwal tanam: ${response.statusCode}');
    }
  }

  Future<PlantingScheduleModel> createSchedule({
    required String plant,
    required String land,
    required DateTime startDate,
    required DateTime harvestDate,
    required DateTime harvestEndDate,
    required String status,
  }) async {
    final body = {
      'plant': plant,
      'land': land,
      'start_date': startDate.toIso8601String().split('T')[0],
      'harvest_date': harvestDate.toIso8601String().split('T')[0],
      'harvest_end_date': harvestEndDate.toIso8601String().split('T')[0],
      'status': status,
    };

    final response = await _apiService.postRequest(ApiConstants.plantingSchedulesEndpoint, body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return PlantingScheduleModel.fromJson(body['data']);
    } else {
      throw Exception('Gagal membuat jadwal tanam: ${response.statusCode}');
    }
  }

  Future<PlantingScheduleModel> updateSchedule(
    int id, {
    String? plant,
    String? land,
    DateTime? startDate,
    DateTime? harvestDate,
    DateTime? harvestEndDate,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (plant != null) body['plant'] = plant;
    if (land != null) body['land'] = land;
    if (startDate != null) body['start_date'] = startDate.toIso8601String().split('T')[0];
    if (harvestDate != null) body['harvest_date'] = harvestDate.toIso8601String().split('T')[0];
    if (harvestEndDate != null) body['harvest_end_date'] = harvestEndDate.toIso8601String().split('T')[0];
    if (status != null) body['status'] = status;

    final response = await _apiService.putRequest(
      '${ApiConstants.plantingSchedulesEndpoint}/$id',
      body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return PlantingScheduleModel.fromJson(body['data']);
    } else {
      throw Exception('Gagal memperbarui jadwal tanam: ${response.statusCode}');
    }
  }

  Future<void> deleteSchedule(int id) async {
    final response = await _apiService.deleteRequest('${ApiConstants.plantingSchedulesEndpoint}/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus jadwal tanam: ${response.statusCode}');
    }
  }

  // --- Farmer Lands (Mapping Sawah) ---

  Future<List<FarmerLandModel>> getLands() async {
    final response = await _apiService.getRequest(ApiConstants.farmerLandsEndpoint);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      return data.map((item) => FarmerLandModel.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Gagal memuat lahan: ${response.statusCode}');
    }
  }

  Future<FarmerLandModel> createLand({
    required String name,
    required double latitude,
    required double longitude,
    String? areaSize,
    String? description,
  }) async {
    final body = {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'area_size': areaSize,
      'description': description,
    };

    final response = await _apiService.postRequest(ApiConstants.farmerLandsEndpoint, body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return FarmerLandModel.fromJson(body['data']);
    } else {
      throw Exception('Gagal menambahkan lahan: ${response.statusCode}');
    }
  }

  Future<void> deleteLand(int id) async {
    final response = await _apiService.deleteRequest('${ApiConstants.farmerLandsEndpoint}/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus lahan: ${response.statusCode}');
    }
  }
}
