class SupplierModel {
  final String id;
  final String name;
  final String company;
  final String phone;
  final String email;
  final String gstin;
  final String address;
  final String state;
  final DateTime createdAt;

  SupplierModel({
    required this.id,
    required this.name,
    this.company = '',
    required this.phone,
    this.email = '',
    this.gstin = '',
    this.address = '',
    this.state = 'Tamil Nadu',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SupplierModel copyWith({
    String? id,
    String? name,
    String? company,
    String? phone,
    String? email,
    String? gstin,
    String? address,
    String? state,
    DateTime? createdAt,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'gstin': gstin,
      'address': address,
      'state': state,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] as String,
      name: map['name'] as String,
      company: map['company'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      gstin: map['gstin'] as String? ?? '',
      address: map['address'] as String? ?? '',
      state: map['state'] as String? ?? 'Tamil Nadu',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
