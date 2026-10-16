class StockHistoryModel {
  final String id;
  final String partId;
  final String partName;
  final String changeType; // 'Purchase', 'Sale', 'Return', 'Adjustment', 'Initial'
  final double quantityChange; // positive or negative
  final double resultingStock;
  final String referenceNumber; // Invoice # or Purchase #
  final String notes;
  final DateTime timestamp;

  StockHistoryModel({
    required this.id,
    required this.partId,
    required this.partName,
    required this.changeType,
    required this.quantityChange,
    required this.resultingStock,
    this.referenceNumber = '',
    this.notes = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isAddition => quantityChange >= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'partId': partId,
      'partName': partName,
      'changeType': changeType,
      'quantityChange': quantityChange,
      'resultingStock': resultingStock,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory StockHistoryModel.fromMap(Map<String, dynamic> map) {
    return StockHistoryModel(
      id: map['id'] as String,
      partId: map['partId'] as String,
      partName: map['partName'] as String? ?? '',
      changeType: map['changeType'] as String? ?? 'Adjustment',
      quantityChange: (map['quantityChange'] as num?)?.toDouble() ?? 0.0,
      resultingStock: (map['resultingStock'] as num?)?.toDouble() ?? 0.0,
      referenceNumber: map['referenceNumber'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
