class PartModel {
  final String id;
  final String name;
  final String partNumber;
  final String brand;
  final String hsnCode;
  final String category;
  final double purchasePrice;
  final double sellingPrice;
  final double gstRate; // e.g. 18.0
  final double stockQuantity;
  final double minStockAlert;
  final String unit; // Pcs, Set, Ltr, Box, etc.
  final String barcode;
  final bool isGstInclusive;
  final DateTime createdAt;

  PartModel({
    required this.id,
    required this.name,
    required this.partNumber,
    required this.brand,
    required this.hsnCode,
    required this.category,
    required this.purchasePrice,
    required this.sellingPrice,
    this.gstRate = 18.0,
    required this.stockQuantity,
    this.minStockAlert = 5.0,
    this.unit = 'Pcs',
    this.barcode = '',
    this.isGstInclusive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isLowStock => stockQuantity <= minStockAlert && stockQuantity > 0;
  bool get isOutOfStock => stockQuantity <= 0;

  PartModel copyWith({
    String? id,
    String? name,
    String? partNumber,
    String? brand,
    String? hsnCode,
    String? category,
    double? purchasePrice,
    double? sellingPrice,
    double? gstRate,
    double? stockQuantity,
    double? minStockAlert,
    String? unit,
    String? barcode,
    bool? isGstInclusive,
    DateTime? createdAt,
  }) {
    return PartModel(
      id: id ?? this.id,
      name: name ?? this.name,
      partNumber: partNumber ?? this.partNumber,
      brand: brand ?? this.brand,
      hsnCode: hsnCode ?? this.hsnCode,
      category: category ?? this.category,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      gstRate: gstRate ?? this.gstRate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      unit: unit ?? this.unit,
      barcode: barcode ?? this.barcode,
      isGstInclusive: isGstInclusive ?? this.isGstInclusive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'partNumber': partNumber,
      'brand': brand,
      'hsnCode': hsnCode,
      'category': category,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'gstRate': gstRate,
      'stockQuantity': stockQuantity,
      'minStockAlert': minStockAlert,
      'unit': unit,
      'barcode': barcode,
      'isGstInclusive': isGstInclusive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PartModel.fromMap(Map<String, dynamic> map) {
    return PartModel(
      id: map['id'] as String,
      name: map['name'] as String,
      partNumber: map['partNumber'] as String? ?? '',
      brand: map['brand'] as String? ?? '',
      hsnCode: map['hsnCode'] as String? ?? '8708',
      category: map['category'] as String? ?? 'General',
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      gstRate: (map['gstRate'] as num?)?.toDouble() ?? 18.0,
      stockQuantity: (map['stockQuantity'] as num?)?.toDouble() ?? 0.0,
      minStockAlert: (map['minStockAlert'] as num?)?.toDouble() ?? 5.0,
      unit: map['unit'] as String? ?? 'Pcs',
      barcode: map['barcode'] as String? ?? '',
      isGstInclusive: (map['isGstInclusive'] is int)
          ? map['isGstInclusive'] == 1
          : (map['isGstInclusive'] as bool? ?? true),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
