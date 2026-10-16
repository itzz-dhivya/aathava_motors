import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/customer_model.dart';
import '../models/invoice_model.dart';
import '../core/database/app_database.dart';

class CustomerProvider extends ChangeNotifier {
  List<CustomerModel> _customers = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<CustomerModel> get allCustomers => _customers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  int get totalCustomerCount => _customers.length;
  double get totalCreditDue => _customers.fold(0.0, (sum, c) => sum + c.pendingBalance);
  List<CustomerModel> get customersWithDues => _customers.where((c) => c.pendingBalance > 0.01).toList();

  List<CustomerModel> get filteredCustomers {
    if (_searchQuery.trim().isEmpty) return _customers;
    final q = _searchQuery.toLowerCase().trim();
    return _customers.where((c) {
      final name = c.name.toLowerCase();
      final phone = c.phone.toLowerCase();
      final vehicle = c.vehicleNumber.toLowerCase();
      final gstin = c.gstin.toLowerCase();
      return name.contains(q) || phone.contains(q) || vehicle.contains(q) || gstin.contains(q);
    }).toList();
  }

  CustomerProvider() {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _customers = await AppDatabase.instance.getAllCustomers();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    final newCust = customer.id.isEmpty
        ? customer.copyWith(id: 'cust_${const Uuid().v4().substring(0, 8)}')
        : customer;

    await AppDatabase.instance.insertCustomer(newCust);
    await loadCustomers();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await AppDatabase.instance.updateCustomer(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    await AppDatabase.instance.deleteCustomer(id);
    await loadCustomers();
  }

  Future<void> receivePayment({
    required String customerId,
    required double amountReceived,
    required String paymentMode,
    String notes = '',
  }) async {
    if (amountReceived <= 0) return;
    // Reduce pending balance by amountReceived
    await AppDatabase.instance.updateCustomerBalance(
      customerId,
      -amountReceived, // negative reduces balance
      0.0,
    );
    await loadCustomers();
  }

  Future<List<InvoiceModel>> getCustomerInvoices(String customerId) async {
    final all = await AppDatabase.instance.getAllInvoices();
    return all.where((inv) => inv.customerId == customerId).toList();
  }
}
