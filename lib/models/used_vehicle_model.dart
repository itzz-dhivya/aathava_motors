class UsedVehicleModel {
  final String id;
  final String title;
  final String vehicleType; // 'car' or 'bike'
  final String brand;
  final int year;
  final String regNumber;
  final int kmDriven;
  final String fuelType; // 'Petrol', 'Diesel', 'Electric', 'CNG'
  final String transmission; // 'Manual', 'Automatic'
  final int ownershipCount; // 1, 2, 3
  final double sellingPrice;
  final bool isNegotiable;
  final String insuranceValidity;
  final String status; // 'available', 'booked', 'sold'
  final String inspectionScore; // e.g. '96/100 (Aathava Certified)'
  final List<String> features;
  final String description;
  final String contactPhone;
  final String sellerName;
  final DateTime createdAt;

  UsedVehicleModel({
    required this.id,
    required this.title,
    required this.vehicleType,
    required this.brand,
    required this.year,
    required this.regNumber,
    required this.kmDriven,
    required this.fuelType,
    this.transmission = 'Manual',
    this.ownershipCount = 1,
    required this.sellingPrice,
    this.isNegotiable = true,
    this.insuranceValidity = 'Comprehensive Insurance Valid',
    this.status = 'available',
    this.inspectionScore = '95/100 (Aathava Certified)',
    this.features = const [],
    this.description = '',
    this.contactPhone = '94422 49149',
    this.sellerName = 'AATHAVA MOTORS Showroom',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCar => vehicleType.toLowerCase() == 'car';
  bool get isBike => vehicleType.toLowerCase() == 'bike';
  bool get isAvailable => status.toLowerCase() == 'available';
  bool get isSold => status.toLowerCase() == 'sold';
  bool get isBooked => status.toLowerCase() == 'booked';

  UsedVehicleModel copyWith({
    String? id,
    String? title,
    String? vehicleType,
    String? brand,
    int? year,
    String? regNumber,
    int? kmDriven,
    String? fuelType,
    String? transmission,
    int? ownershipCount,
    double? sellingPrice,
    bool? isNegotiable,
    String? insuranceValidity,
    String? status,
    String? inspectionScore,
    List<String>? features,
    String? description,
    String? contactPhone,
    String? sellerName,
    DateTime? createdAt,
  }) {
    return UsedVehicleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      year: year ?? this.year,
      regNumber: regNumber ?? this.regNumber,
      kmDriven: kmDriven ?? this.kmDriven,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      ownershipCount: ownershipCount ?? this.ownershipCount,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      insuranceValidity: insuranceValidity ?? this.insuranceValidity,
      status: status ?? this.status,
      inspectionScore: inspectionScore ?? this.inspectionScore,
      features: features ?? this.features,
      description: description ?? this.description,
      contactPhone: contactPhone ?? this.contactPhone,
      sellerName: sellerName ?? this.sellerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'vehicleType': vehicleType,
      'brand': brand,
      'year': year,
      'regNumber': regNumber,
      'kmDriven': kmDriven,
      'fuelType': fuelType,
      'transmission': transmission,
      'ownershipCount': ownershipCount,
      'sellingPrice': sellingPrice,
      'isNegotiable': isNegotiable ? 1 : 0,
      'insuranceValidity': insuranceValidity,
      'status': status,
      'inspectionScore': inspectionScore,
      'features': features.join(', '),
      'description': description,
      'contactPhone': contactPhone,
      'sellerName': sellerName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UsedVehicleModel.fromMap(Map<String, dynamic> map) {
    return UsedVehicleModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      vehicleType: map['vehicleType']?.toString() ?? 'car',
      brand: map['brand']?.toString() ?? '',
      year: (map['year'] as num?)?.toInt() ?? DateTime.now().year,
      regNumber: map['regNumber']?.toString() ?? '',
      kmDriven: (map['kmDriven'] as num?)?.toInt() ?? 0,
      fuelType: map['fuelType']?.toString() ?? 'Petrol',
      transmission: map['transmission']?.toString() ?? 'Manual',
      ownershipCount: (map['ownershipCount'] as num?)?.toInt() ?? 1,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      isNegotiable: (map['isNegotiable'] == 1 || map['isNegotiable'] == true),
      insuranceValidity: map['insuranceValidity']?.toString() ?? 'Valid',
      status: map['status']?.toString() ?? 'available',
      inspectionScore: map['inspectionScore']?.toString() ?? '95/100 (Aathava Certified)',
      features: map['features'] != null && map['features'].toString().isNotEmpty
          ? (map['features'] as String).split(',').map((e) => e.trim()).toList()
          : [],
      description: map['description']?.toString() ?? '',
      contactPhone: map['contactPhone']?.toString() ?? '94422 49149',
      sellerName: map['sellerName']?.toString() ?? 'AATHAVA MOTORS Showroom',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
