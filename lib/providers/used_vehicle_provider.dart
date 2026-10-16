import 'package:flutter/material.dart';
import '../core/database/app_database.dart';
import '../core/database/sample_data.dart';
import '../models/used_vehicle_model.dart';

class UsedVehicleProvider extends ChangeNotifier {
  List<UsedVehicleModel> _vehicles = [];
  String _selectedTypeFilter = 'all'; // 'all', 'car', 'bike'
  String _searchQuery = '';
  bool _isLoading = false;

  UsedVehicleProvider() {
    loadVehicles();
  }

  List<UsedVehicleModel> get allVehicles => _vehicles;
  bool get isLoading => _isLoading;
  String get selectedTypeFilter => _selectedTypeFilter;
  String get searchQuery => _searchQuery;

  int get totalCount => _vehicles.length;
  int get carsCount => _vehicles.where((v) => v.isCar).length;
  int get bikesCount => _vehicles.where((v) => v.isBike).length;
  int get availableCount => _vehicles.where((v) => v.isAvailable).length;

  List<UsedVehicleModel> get filteredVehicles {
    return _vehicles.where((v) {
      if (_selectedTypeFilter == 'car' && !v.isCar) return false;
      if (_selectedTypeFilter == 'bike' && !v.isBike) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = v.title.toLowerCase().contains(q);
        final matchesBrand = v.brand.toLowerCase().contains(q);
        final matchesReg = v.regNumber.toLowerCase().contains(q);
        final matchesFuel = v.fuelType.toLowerCase().contains(q);
        if (!matchesTitle && !matchesBrand && !matchesReg && !matchesFuel) return false;
      }

      return true;
    }).toList();
  }

  Future<void> loadVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final list = await AppDatabase.instance.getUsedVehicles();
      _vehicles = list.isNotEmpty ? list : List.from(SampleData.defaultUsedVehicles);
    } catch (_) {
      _vehicles = List.from(SampleData.defaultUsedVehicles);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setTypeFilter(String type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<bool> addVehicle(UsedVehicleModel vehicle) async {
    try {
      await AppDatabase.instance.insertUsedVehicle(vehicle);
      _vehicles.insert(0, vehicle);
      notifyListeners();
      return true;
    } catch (_) {
      _vehicles.insert(0, vehicle);
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateVehicle(UsedVehicleModel vehicle) async {
    try {
      await AppDatabase.instance.updateUsedVehicle(vehicle);
      final idx = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (idx != -1) {
        _vehicles[idx] = vehicle;
        notifyListeners();
      }
      return true;
    } catch (_) {
      final idx = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (idx != -1) {
        _vehicles[idx] = vehicle;
        notifyListeners();
      }
      return true;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      await AppDatabase.instance.deleteUsedVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateStatus(String id, String newStatus) async {
    final idx = _vehicles.indexWhere((v) => v.id == id);
    if (idx != -1) {
      final updated = _vehicles[idx].copyWith(status: newStatus);
      return await updateVehicle(updated);
    }
    return false;
  }
}
