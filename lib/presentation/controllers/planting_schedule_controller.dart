import 'package:flutter/material.dart';
import '../../data/repositories/planting_schedule_repository.dart';
import '../../data/models/planting_schedule_model.dart';
import '../../data/models/farmer_land_model.dart';
import '../../data/services/api_service.dart';

class PlantingScheduleController extends ChangeNotifier {
  final PlantingScheduleRepository _repository;

  List<PlantingScheduleModel> _schedules = [];
  List<FarmerLandModel> _lands = [];
  bool _isLoading = false;
  String? _lastError;

  PlantingScheduleController(ApiService apiService)
      : _repository = PlantingScheduleRepository(apiService);

  List<PlantingScheduleModel> get schedules => _schedules;
  List<FarmerLandModel> get lands => _lands;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

  // --- Planting Schedules ---

  Future<void> loadSchedules() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _schedules = await _repository.getSchedules();
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSchedule({
    required String plant,
    required String land,
    required DateTime startDate,
    required DateTime harvestDate,
    required DateTime harvestEndDate,
    required String status,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final newSchedule = await _repository.createSchedule(
        plant: plant,
        land: land,
        startDate: startDate,
        harvestDate: harvestDate,
        harvestEndDate: harvestEndDate,
        status: status,
      );
      _schedules.insert(0, newSchedule);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSchedule(
    int id, {
    String? plant,
    String? land,
    DateTime? startDate,
    DateTime? harvestDate,
    DateTime? harvestEndDate,
    String? status,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final updatedSchedule = await _repository.updateSchedule(
        id,
        plant: plant,
        land: land,
        startDate: startDate,
        harvestDate: harvestDate,
        harvestEndDate: harvestEndDate,
        status: status,
      );

      final index = _schedules.indexWhere((s) => s.id == id);
      if (index >= 0) {
        _schedules[index] = updatedSchedule;
      }
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSchedule(int id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _repository.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Farmer Lands (Mapping Sawah) ---

  Future<void> loadLands() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _lands = await _repository.getLands();
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLand({
    required String name,
    required double latitude,
    required double longitude,
    String? areaSize,
    String? description,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final newLand = await _repository.createLand(
        name: name,
        latitude: latitude,
        longitude: longitude,
        areaSize: areaSize,
        description: description,
      );
      _lands.insert(0, newLand);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLand(int id) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      await _repository.deleteLand(id);
      _lands.removeWhere((l) => l.id == id);
      return true;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
