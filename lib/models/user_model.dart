enum UserRole {
  admin,
  user,
  worker;

  // Compatibility aliases
  static UserRole get owner => admin;
  static UserRole get staff => worker;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Garage Admin';
      case UserRole.user:
        return 'Vehicle Owner / Customer';
      case UserRole.worker:
        return 'Mechanic / Technician';
    }
  }

  String get badgeText {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.user:
        return 'CUSTOMER';
      case UserRole.worker:
        return 'MECHANIC';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final UserRole role;
  final String shopId;
  final DateTime createdAt;
  final String? vehicleNumber;
  final String? specialty;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
    required this.shopId,
    required this.createdAt,
    this.vehicleNumber,
    this.specialty,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;
  bool get isWorker => role == UserRole.worker;

  // Backward-compatible getters
  bool get isOwner => role == UserRole.admin;
  bool get isStaff => role == UserRole.worker;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': role.name,
      'shopId': shopId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    UserRole parsedRole;
    final r = map['role']?.toString().toLowerCase();
    if (r == 'user' || r == 'customer') {
      parsedRole = UserRole.user;
    } else if (r == 'worker' || r == 'staff' || r == 'mechanic') {
      parsedRole = UserRole.worker;
    } else {
      parsedRole = UserRole.admin;
    }

    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      password: map['password'] as String? ?? '',
      role: parsedRole,
      shopId: map['shopId'] as String? ?? 'shop_default',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      vehicleNumber: map['vehicleNumber'] as String?,
      specialty: map['specialty'] as String?,
    );
  }
}
