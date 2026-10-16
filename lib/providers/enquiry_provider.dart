import 'package:flutter/material.dart';
import '../models/enquiry_model.dart';

class EnquiryProvider extends ChangeNotifier {
  final List<EnquiryModel> _enquiries = [
    EnquiryModel(
      id: 'enq-01',
      enquiryType: 'test_drive',
      title: 'Test Drive: 2021 Hyundai Creta SX',
      subtitle: 'Showroom Visit • Reg: TN 38 CF 4410',
      customerName: 'Mr. Sathish Kumar',
      customerPhone: '89517 77054',
      date: DateTime.now().add(const Duration(days: 1)),
      status: 'confirmed',
      notes: 'Customer requested 11:30 AM slot. Sales team confirmed.',
    ),
    EnquiryModel(
      id: 'enq-02',
      enquiryType: 'sell_valuation',
      title: 'Free Valuation: 2018 Maruti Swift VDi',
      subtitle: 'Expected: ₹4.8 Lakhs • 54,000 km',
      customerName: 'Mr. Sathish Kumar',
      customerPhone: '89517 77054',
      date: DateTime.now().subtract(const Duration(hours: 14)),
      status: 'pending',
      notes: 'Valuation estimated: ₹4.65L - ₹4.90L. Inspection pending.',
    ),
    EnquiryModel(
      id: 'enq-03',
      enquiryType: 'service_booking',
      title: 'Periodic Maintenance Service',
      subtitle: 'Hyundai Accent • Doorstep Pickup',
      customerName: 'Mr. Sathish Kumar',
      customerPhone: '89517 77054',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: 'completed',
      notes: 'General service & synthetic oil change completed. Job #3168.',
    ),
  ];

  List<EnquiryModel> get allEnquiries => _enquiries;

  List<EnquiryModel> get customerEnquiries => _enquiries;

  List<EnquiryModel> get testDrives =>
      _enquiries.where((e) => e.enquiryType == 'test_drive').toList();

  List<EnquiryModel> get sellValuations =>
      _enquiries.where((e) => e.enquiryType == 'sell_valuation').toList();

  List<EnquiryModel> get serviceBookings =>
      _enquiries.where((e) => e.enquiryType == 'service_booking').toList();

  void addEnquiry(EnquiryModel enquiry) {
    _enquiries.insert(0, enquiry);
    notifyListeners();
  }

  void updateStatus(String id, String newStatus) {
    final idx = _enquiries.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = _enquiries[idx];
      _enquiries[idx] = EnquiryModel(
        id: old.id,
        enquiryType: old.enquiryType,
        title: old.title,
        subtitle: old.subtitle,
        customerName: old.customerName,
        customerPhone: old.customerPhone,
        vehicleId: old.vehicleId,
        date: old.date,
        status: newStatus,
        notes: old.notes,
      );
      notifyListeners();
    }
  }
}
