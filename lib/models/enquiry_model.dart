class EnquiryModel {
  final String id;
  final String enquiryType; // 'test_drive', 'sell_valuation', 'service_booking'
  final String title;
  final String subtitle;
  final String customerName;
  final String customerPhone;
  final String? vehicleId;
  final DateTime date;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String notes;

  EnquiryModel({
    required this.id,
    required this.enquiryType,
    required this.title,
    required this.subtitle,
    required this.customerName,
    required this.customerPhone,
    this.vehicleId,
    required this.date,
    this.status = 'pending',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enquiryType': enquiryType,
      'title': title,
      'subtitle': subtitle,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory EnquiryModel.fromMap(Map<String, dynamic> map) {
    return EnquiryModel(
      id: map['id'] ?? '',
      enquiryType: map['enquiryType'] ?? 'test_drive',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      vehicleId: map['vehicleId'],
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      notes: map['notes'] ?? '',
    );
  }
}
