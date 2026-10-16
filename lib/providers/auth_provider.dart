import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/shop_profile_model.dart';
import '../core/database/app_database.dart';
import '../core/database/sample_data.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  UserRole _selectedRole = UserRole.admin;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  UserRole get selectedRole => _selectedRole;
  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser?.isAdmin ?? (_selectedRole == UserRole.admin);
  bool get isUser => _currentUser?.isUser ?? (_selectedRole == UserRole.user);
  bool get isWorker => _currentUser?.isWorker ?? (_selectedRole == UserRole.worker);

  // Backward compatibility
  bool get isOwner => isAdmin;
  bool get isStaff => isWorker;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initDefaultAuth();
  }

  Future<void> _initDefaultAuth() async {
    // Keep initially null so user gets to experience the Splash Screen & User Mode selection screen
    _currentUser = null;
    notifyListeners();
  }

  void setSelectedRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  /// Fast 1-tap login for the selected role using seeded sample profiles
  Future<bool> loginAsRole(UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedRole = role;
    notifyListeners();

    try {
      final users = await AppDatabase.instance.getAllUsers();
      UserModel? target;
      for (final u in users) {
        if (u.role == role) {
          target = u;
          break;
        }
      }

      if (target == null) {
        // Fallback to sample user
        final samples = SampleData.defaultUsers;
        target = samples.firstWhere(
          (u) => u.role == role,
          orElse: () => samples.first,
        );
        try {
          await AppDatabase.instance.insertUser(target);
        } catch (_) {}
      }

      _currentUser = target;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to switch role: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password, {UserRole? targetRole}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await AppDatabase.instance.authenticateUser(email, password);
      if (user != null) {
        _currentUser = user;
        _selectedRole = user.role;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Check if demo credentials match
        final demoMatch = SampleData.defaultUsers.firstWhere(
          (u) => (u.email.toLowerCase() == email.trim().toLowerCase() ||
                  u.phone == email.trim()),
          orElse: () => UserModel(
            id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
            name: (targetRole ?? _selectedRole) == UserRole.admin
                ? 'Garage Admin'
                : (targetRole ?? _selectedRole) == UserRole.user
                    ? 'Customer User'
                    : 'Technician Muthu',
            email: email,
            phone: '9840011223',
            password: password,
            role: targetRole ?? _selectedRole,
            shopId: 'shop_autozone',
            createdAt: DateTime.now(),
          ),
        );

        _currentUser = demoMatch;
        _selectedRole = demoMatch.role;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Authentication error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithPhoneOtp(String phone, String otp, {UserRole? targetRole}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanOtp = otp.trim();
      // Allow demo OTP 123456 or 1234 or any 4/6-digit OTP
      if (cleanOtp == '123456' || cleanOtp == '1234' || cleanOtp.length >= 4) {
        final user = await AppDatabase.instance.getUserByPhone(phone.trim());
        if (user != null) {
          _currentUser = user;
          _selectedRole = user.role;
          _isLoading = false;
          notifyListeners();
          return true;
        }

        final roleToUse = targetRole ?? _selectedRole;
        final name = roleToUse == UserRole.admin
            ? 'Aathava Motors Admin'
            : roleToUse == UserRole.user
                ? 'Mr. Sathish Kumar (Customer)'
                : 'Muthu (Senior Mechanic)';

        final newUser = UserModel(
          id: 'user_phone_${phone.replaceAll(RegExp(r'\D'), '')}',
          name: name,
          email: '${phone.trim()}@aathavamotors.com',
          phone: phone.trim(),
          password: 'demo',
          role: roleToUse,
          shopId: 'shop_aathava',
          vehicleNumber: roleToUse == UserRole.user ? 'TN 01 X 2943' : null,
          specialty: roleToUse == UserRole.worker ? 'Hyundai & Multi-Brand Specialist' : null,
          createdAt: DateTime.now(),
        );

        try {
          await AppDatabase.instance.insertUser(newUser);
        } catch (_) {}

        _currentUser = newUser;
        _selectedRole = roleToUse;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid OTP. Please enter 1234 to proceed.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'OTP error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerShop({
    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String password,
    required String gstin,
    required String address,
    required String state,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final shopId = 'shop_${const Uuid().v4().substring(0, 8)}';
      final userId = 'user_${const Uuid().v4().substring(0, 8)}';

      final newShop = ShopProfileModel(
        id: shopId,
        shopName: shopName,
        ownerName: ownerName,
        phone: phone,
        email: email,
        gstin: gstin,
        address: address,
        state: state,
      );

      final newUser = UserModel(
        id: userId,
        name: ownerName,
        email: email,
        phone: phone,
        password: password,
        role: UserRole.admin,
        shopId: shopId,
        createdAt: DateTime.now(),
      );

      await AppDatabase.instance.updateShopProfile(newShop);
      await AppDatabase.instance.insertUser(newUser);

      _currentUser = newUser;
      _selectedRole = UserRole.admin;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void switchDemoRole(UserRole role) async {
    await loginAsRole(role);
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
