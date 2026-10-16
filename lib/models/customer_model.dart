class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleNumber;
  final String address;
  final String state;
  final String gstin;
  final double pendingBalance;
  final double totalPurchases;
  final int invoiceCount;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleNumber = '',
    this.address = '',
    this.state = 'Tamil Nadu',
    this.gstin = '',
    this.pendingBalance = 0.0,
    this.totalPurchases = 0.0,
    this.invoiceCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasDues => pendingBalance > 0.01;
  bool get isB2B => gstin.trim().isNotEmpty;

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehicleNumber,
    String? address,
    String? state,
    String? gstin,
    double? pendingBalance,
    double? totalPurchases,
    int? invoiceCount,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      address: address ?? this.address,
      state: state ?? this.state,
      gstin: gstin ?? this.gstin,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      invoiceCount: invoiceCount ?? this.invoiceCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleNumber': vehicleNumber,
      'address': address,
      'state': state,
      'gstin': gstin,
      'pendingBalance': pendingBalance,
      'totalPurchases': totalPurchases,
      'invoiceCount': invoiceCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String? ?? '',
      vehicleNumber: map['vehicleNumber'] as String? ?? '',
      address: map['address'] as String? ?? '',
      state: map['state'] as String? ?? 'Tamil Nadu',
      gstin: map['gstin'] as String? ?? '',
      pendingBalance: (map['pendingBalance'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (map['totalPurchases'] as num?)?.toDouble() ?? 0.0,
      invoiceCount: (map['invoiceCount'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
