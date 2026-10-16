import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/shop_profile_model.dart';
import '../models/user_model.dart';
import '../core/database/app_database.dart';
import '../core/database/sample_data.dart';

class SettingsProvider extends ChangeNotifier {
  ShopProfileModel _shop = SampleData.defaultShop;
  List<UserModel> _staffUsers = [];
  bool _isLoading = false;

  ShopProfileModel get shop => _shop;
  List<UserModel> get staffUsers => _staffUsers;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    try {
      _shop = await AppDatabase.instance.getShopProfile();
      final allUsers = await AppDatabase.instance.getAllUsers();
      _staffUsers = allUsers.where((u) => u.isStaff).toList();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateShopProfile(ShopProfileModel updated) async {
    _shop = updated;
    notifyListeners();
    await AppDatabase.instance.updateShopProfile(updated);
  }

  Future<void> addStaffUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final newUser = UserModel(
      id: 'user_${const Uuid().v4().substring(0, 8)}',
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: UserRole.staff,
      shopId: _shop.id,
      createdAt: DateTime.now(),
    );
    await AppDatabase.instance.insertUser(newUser);
    await loadSettings();
  }
}
