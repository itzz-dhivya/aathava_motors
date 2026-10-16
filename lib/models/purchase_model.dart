import 'dart:convert';

class PurchaseItemModel {
  final String id;
  final String partId;
  final String partName;
  final String partNumber;
  final String unit;
  final double purchasePrice;
  final double quantity;
  final double gstRate;
  final double totalAmount;

  PurchaseItemModel({
    required this.id,
    required this.partId,
    required this.partName,
    this.partNumber = '',
    this.unit = 'Pcs',
    required this.purchasePrice,
    required this.quantity,
    this.gstRate = 18.0,
    required this.totalAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partId': partId,
      'partName': partName,
      'partNumber': partNumber,
      'unit': unit,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'gstRate': gstRate,
      'totalAmount': totalAmount,
    };
  }

  factory PurchaseItemModel.fromMap(Map<String, dynamic> map) {
    return PurchaseItemModel(
      id: map['id'] as String,
      partId: map['partId'] as String,
      partName: map['partName'] as String,
      partNumber: map['partNumber'] as String? ?? '',
      unit: map['unit'] as String? ?? 'Pcs',
      purchasePrice: (map['purchasePrice'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      gstRate: (map['gstRate'] as num?)?.toDouble() ?? 18.0,
      totalAmount: (map['totalAmount'] as num).toDouble(),
    );
  }
}

class PurchaseModel {
  final String id;
  final String purchaseInvoiceNumber;
  final String supplierId;
  final String supplierName;
  final DateTime date;
  final List<PurchaseItemModel> items;
  final double totalAmount;
  final String notes;

  PurchaseModel({
    required this.id,
    required this.purchaseInvoiceNumber,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    required this.items,
    required this.totalAmount,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchaseInvoiceNumber': purchaseInvoiceNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'date': date.toIso8601String(),
      'itemsJson': jsonEncode(items.map((i) => i.toMap()).toList()),
      'totalAmount': totalAmount,
      'notes': notes,
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    List<PurchaseItemModel> parsedItems = [];
    if (map['itemsJson'] != null) {
      try {
        final decoded = jsonDecode(map['itemsJson'] as String) as List<dynamic>;
        parsedItems = decoded
            .map((item) => PurchaseItemModel.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }

    return PurchaseModel(
      id: map['id'] as String,
      purchaseInvoiceNumber: map['purchaseInvoiceNumber'] as String,
      supplierId: map['supplierId'] as String,
      supplierName: map['supplierName'] as String? ?? '',
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
      items: parsedItems,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
    );
  }
}
