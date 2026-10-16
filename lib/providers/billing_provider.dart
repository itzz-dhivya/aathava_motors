import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice_model.dart';
import '../models/part_model.dart';
import '../models/customer_model.dart';
import '../models/shop_profile_model.dart';
import '../models/stock_history_model.dart';
import '../core/database/app_database.dart';
import '../core/utils/gst_calculator.dart';

class CartItem {
  final PartModel part;
  double quantity;
  double price;
  double gstRate;
  double discount; // flat discount or per item

  CartItem({
    required this.part,
    this.quantity = 1.0,
    double? price,
    double? gstRate,
    this.discount = 0.0,
  })  : price = price ?? part.sellingPrice,
        gstRate = gstRate ?? part.gstRate;
}

class BillingProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  CustomerModel? _selectedCustomer;
  String _walkInName = 'Walk-in Customer';
  String _walkInPhone = '';
  String _walkInVehicle = '';

  bool _isGstInclusive = true;
  double _billDiscountFlat = 0.0;
  String _paymentMode = 'Cash'; // Cash, UPI, Card, Credit
  double _amountPaid = 0.0;
  String _billingNotes = '';
  List<InvoiceModel> _allInvoices = [];
  bool _isLoading = false;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  CustomerModel? get selectedCustomer => _selectedCustomer;
  String get walkInName => _walkInName;
  String get walkInPhone => _walkInPhone;
  String get walkInVehicle => _walkInVehicle;
  bool get isGstInclusive => _isGstInclusive;
  double get billDiscountFlat => _billDiscountFlat;
  String get paymentMode => _paymentMode;
  double get amountPaid => _amountPaid;
  String get billingNotes => _billingNotes;
  List<InvoiceModel> get allInvoices => _allInvoices;
  bool get isLoading => _isLoading;

  BillingProvider() {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allInvoices = await AppDatabase.instance.getAllInvoices();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void selectCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setWalkInDetails({String? name, String? phone, String? vehicle}) {
    if (name != null) _walkInName = name;
    if (phone != null) _walkInPhone = phone;
    if (vehicle != null) _walkInVehicle = vehicle;
    notifyListeners();
  }

  void toggleGstInclusive(bool value) {
    _isGstInclusive = value;
    notifyListeners();
  }

  void setPaymentMode(String mode) {
    _paymentMode = mode;
    if (mode == 'Credit') {
      _amountPaid = 0.0; // Default to unpaid for full credit
    } else {
      _amountPaid = grandTotal; // Default to full payment
    }
    notifyListeners();
  }

  void setAmountPaid(double amount) {
    _amountPaid = amount;
    notifyListeners();
  }

  void setBillDiscount(double discount) {
    _billDiscountFlat = discount;
    notifyListeners();
  }

  void setBillingNotes(String notes) {
    _billingNotes = notes;
    notifyListeners();
  }

  // Cart Management
  void addToCart(PartModel part) {
    final existingIndex = _cartItems.indexWhere((item) => item.part.id == part.id);
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += 1.0;
    } else {
      _cartItems.add(CartItem(part: part, price: part.sellingPrice, gstRate: part.gstRate));
    }
    // Update amount paid if mode was cash/upi
    if (_paymentMode != 'Credit') {
      _amountPaid = grandTotal;
    }
    notifyListeners();
  }

  void updateCartItemQty(int index, double newQty) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQty <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQty;
      }
      if (_paymentMode != 'Credit') {
        _amountPaid = grandTotal;
      }
      notifyListeners();
    }
  }

  void updateCartItemPrice(int index, double newPrice) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].price = newPrice;
      if (_paymentMode != 'Credit') {
        _amountPaid = grandTotal;
      }
      notifyListeners();
    }
  }

  void updateCartItemDiscount(int index, double discount) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems[index].discount = discount;
      if (_paymentMode != 'Credit') {
        _amountPaid = grandTotal;
      }
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      if (_paymentMode != 'Credit') {
        _amountPaid = grandTotal;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _selectedCustomer = null;
    _walkInName = 'Walk-in Customer';
    _walkInPhone = '';
    _walkInVehicle = '';
    _billDiscountFlat = 0.0;
    _paymentMode = 'Cash';
    _amountPaid = 0.0;
    _billingNotes = '';
    notifyListeners();
  }

  // Calculations
  bool get isInterState {
    // If selected customer has state != shop state
    if (_selectedCustomer != null && _selectedCustomer!.state.isNotEmpty) {
      return GstCalculator.checkIsInterState('Tamil Nadu', _selectedCustomer!.state);
    }
    return false;
  }

  double get subtotalTaxable {
    double total = 0.0;
    for (final item in _cartItems) {
      final res = GstCalculator.calculateItem(
        price: item.price,
        quantity: item.quantity,
        gstRate: item.gstRate,
        isGstInclusive: _isGstInclusive,
        isInterState: isInterState,
        itemDiscountFlat: item.discount,
      );
      total += res.itemTaxable;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double get cgstTotal {
    if (isInterState) return 0.0;
    double total = 0.0;
    for (final item in _cartItems) {
      final res = GstCalculator.calculateItem(
        price: item.price,
        quantity: item.quantity,
        gstRate: item.gstRate,
        isGstInclusive: _isGstInclusive,
        isInterState: isInterState,
        itemDiscountFlat: item.discount,
      );
      total += res.itemCgst;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double get sgstTotal {
    if (isInterState) return 0.0;
    double total = 0.0;
    for (final item in _cartItems) {
      final res = GstCalculator.calculateItem(
        price: item.price,
        quantity: item.quantity,
        gstRate: item.gstRate,
        isGstInclusive: _isGstInclusive,
        isInterState: isInterState,
        itemDiscountFlat: item.discount,
      );
      total += res.itemSgst;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double get igstTotal {
    if (!isInterState) return 0.0;
    double total = 0.0;
    for (final item in _cartItems) {
      final res = GstCalculator.calculateItem(
        price: item.price,
        quantity: item.quantity,
        gstRate: item.gstRate,
        isGstInclusive: _isGstInclusive,
        isInterState: isInterState,
        itemDiscountFlat: item.discount,
      );
      total += res.itemIgst;
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double get totalTax => double.parse((cgstTotal + sgstTotal + igstTotal).toStringAsFixed(2));

  double get grossBeforeRoundOff {
    double total = 0.0;
    for (final item in _cartItems) {
      final res = GstCalculator.calculateItem(
        price: item.price,
        quantity: item.quantity,
        gstRate: item.gstRate,
        isGstInclusive: _isGstInclusive,
        isInterState: isInterState,
        itemDiscountFlat: item.discount,
      );
      total += res.itemTotal;
    }
    total -= _billDiscountFlat;
    return total > 0 ? total : 0.0;
  }

  double get grandTotal => double.parse(grossBeforeRoundOff.roundToDouble().toStringAsFixed(2));
  double get roundOff => double.parse((grandTotal - grossBeforeRoundOff).toStringAsFixed(2));
  double get balanceDue => (grandTotal - _amountPaid).clamp(0.0, double.infinity);

  // Generate and Save Invoice
  Future<InvoiceModel?> checkout({
    required ShopProfileModel shop,
    required String createdBy,
  }) async {
    if (_cartItems.isEmpty) return null;

    final invoiceNumber = '${shop.invoicePrefix}-${shop.nextInvoiceNumber}';
    final invoiceId = 'inv_${const Uuid().v4().substring(0, 8)}';

    final invoiceItems = _cartItems.map((cartItem) {
      final calc = GstCalculator.calculateItem(
        price: cartItem.price,
        quantity: cartItem.quantity,
        gstRate: cartItem.gstRate,
        isGstInclusive: _isGstInclusive,
        isInterState: isInterState,
        itemDiscountFlat: cartItem.discount,
      );

      return InvoiceItemModel(
        id: 'item_${const Uuid().v4().substring(0, 8)}',
        partId: cartItem.part.id,
        partName: cartItem.part.name,
        partNumber: cartItem.part.partNumber,
        hsnCode: cartItem.part.hsnCode,
        unit: cartItem.part.unit,
        price: cartItem.price,
        quantity: cartItem.quantity,
        gstRate: cartItem.gstRate,
        discount: cartItem.discount,
        taxableAmount: calc.itemTaxable,
        cgstAmount: calc.itemCgst,
        sgstAmount: calc.itemSgst,
        igstAmount: calc.itemIgst,
        totalTax: calc.itemTax,
        totalAmount: calc.itemTotal,
      );
    }).toList();

    final invoice = InvoiceModel(
      id: invoiceId,
      invoiceNumber: invoiceNumber,
      customerId: _selectedCustomer?.id,
      customerName: _selectedCustomer?.name ?? _walkInName,
      customerPhone: _selectedCustomer?.phone ?? _walkInPhone,
      vehicleNumber: _selectedCustomer?.vehicleNumber ?? _walkInVehicle,
      customerAddress: _selectedCustomer?.address ?? '',
      customerGstin: _selectedCustomer?.gstin ?? '',
      customerState: _selectedCustomer?.state ?? shop.state,
      date: DateTime.now(),
      items: invoiceItems,
      isGstInclusive: _isGstInclusive,
      isInterState: isInterState,
      subtotalTaxable: subtotalTaxable,
      cgstTotal: cgstTotal,
      sgstTotal: sgstTotal,
      igstTotal: igstTotal,
      totalTax: totalTax,
      discountTotal: _billDiscountFlat,
      roundOff: roundOff,
      grandTotal: grandTotal,
      paymentMode: _paymentMode,
      paidAmount: _amountPaid,
      balanceDue: balanceDue,
      status: 'Completed',
      notes: _billingNotes,
      createdBy: createdBy,
    );

    // 1. Insert invoice
    await AppDatabase.instance.insertInvoice(invoice);

    // 2. Reduce stock for each item & record history
    for (final item in _cartItems) {
      final currentPart = await AppDatabase.instance.getPartById(item.part.id);
      if (currentPart != null) {
        final newStock = (currentPart.stockQuantity - item.quantity).clamp(0.0, double.infinity);
        await AppDatabase.instance.updatePartStock(item.part.id, newStock);

        final stockLog = StockHistoryModel(
          id: 'hist_${const Uuid().v4().substring(0, 8)}',
          partId: item.part.id,
          partName: item.part.name,
          changeType: 'Sale',
          quantityChange: -item.quantity,
          resultingStock: newStock,
          referenceNumber: invoiceNumber,
          notes: 'Sold on invoice $invoiceNumber to ${invoice.customerName}',
          timestamp: DateTime.now(),
        );
        await AppDatabase.instance.insertStockHistory(stockLog);
      }
    }

    // 3. Update customer balance if registered customer
    if (_selectedCustomer != null) {
      await AppDatabase.instance.updateCustomerBalance(
        _selectedCustomer!.id,
        balanceDue, // positive increases credit balance
        grandTotal,
        incrementInvoice: true,
      );
    }

    // 4. Increment shop invoice sequence
    final updatedShop = shop.copyWith(nextInvoiceNumber: shop.nextInvoiceNumber + 1);
    await AppDatabase.instance.updateShopProfile(updatedShop);

    // 5. Reload list & clear cart
    await loadInvoices();
    clearCart();

    return invoice;
  }

  // Process Return / Cancellation
  Future<bool> processInvoiceReturn({
    required InvoiceModel invoice,
    required String reason,
  }) async {
    try {
      // 1. Restore stock for all items
      for (final item in invoice.items) {
        final currentPart = await AppDatabase.instance.getPartById(item.partId);
        if (currentPart != null) {
          final newStock = currentPart.stockQuantity + item.quantity;
          await AppDatabase.instance.updatePartStock(item.partId, newStock);

          final stockLog = StockHistoryModel(
            id: 'hist_${const Uuid().v4().substring(0, 8)}',
            partId: item.partId,
            partName: item.partName,
            changeType: 'Return',
            quantityChange: item.quantity,
            resultingStock: newStock,
            referenceNumber: 'RET-${invoice.invoiceNumber}',
            notes: 'Returned from invoice ${invoice.invoiceNumber}. Reason: $reason',
            timestamp: DateTime.now(),
          );
          await AppDatabase.instance.insertStockHistory(stockLog);
        }
      }

      // 2. Adjust customer balance if credit was used
      if (invoice.customerId != null && invoice.balanceDue > 0) {
        await AppDatabase.instance.updateCustomerBalance(
          invoice.customerId!,
          -invoice.balanceDue, // removes the credit debt
          -invoice.grandTotal,
        );
      }

      // 3. Update invoice status to 'Returned'
      final updated = invoice.copyWith(status: 'Returned', notes: 'Returned: $reason');
      await AppDatabase.instance.updateInvoice(updated);

      await loadInvoices();
      return true;
    } catch (_) {
      return false;
    }
  }
}
