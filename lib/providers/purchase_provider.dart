import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/purchase_model.dart';
import '../models/supplier_model.dart';
import '../models/stock_history_model.dart';
import '../core/database/app_database.dart';

class PurchaseProvider extends ChangeNotifier {
  List<PurchaseModel> _purchases = [];
  List<SupplierModel> _suppliers = [];
  bool _isLoading = false;

  List<PurchaseModel> get purchases => _purchases;
  List<SupplierModel> get suppliers => _suppliers;
  bool get isLoading => _isLoading;

  int get totalPurchasesCount => _purchases.length;
  double get totalPurchasesAmount => _purchases.fold(0.0, (sum, p) => sum + p.totalAmount);

  PurchaseProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _purchases = await AppDatabase.instance.getAllPurchases();
      _suppliers = await AppDatabase.instance.getAllSuppliers();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    final newSup = supplier.id.isEmpty
        ? supplier.copyWith(id: 'sup_${const Uuid().v4().substring(0, 8)}')
        : supplier;
    await AppDatabase.instance.insertSupplier(newSup);
    await loadData();
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await AppDatabase.instance.updateSupplier(supplier);
    await loadData();
  }

  Future<void> deleteSupplier(String id) async {
    await AppDatabase.instance.deleteSupplier(id);
    await loadData();
  }

  Future<void> addPurchaseEntry({
    required String purchaseInvoiceNumber,
    required SupplierModel supplier,
    required List<PurchaseItemModel> items,
    required double totalAmount,
    String notes = '',
  }) async {
    final purchase = PurchaseModel(
      id: 'purch_${const Uuid().v4().substring(0, 8)}',
      purchaseInvoiceNumber: purchaseInvoiceNumber,
      supplierId: supplier.id,
      supplierName: supplier.name,
      date: DateTime.now(),
      items: items,
      totalAmount: totalAmount,
      notes: notes,
    );

    // 1. Insert purchase
    await AppDatabase.instance.insertPurchase(purchase);

    // 2. Increase stock for each part and log history
    for (final item in items) {
      final part = await AppDatabase.instance.getPartById(item.partId);
      if (part != null) {
        final newStock = part.stockQuantity + item.quantity;
        await AppDatabase.instance.updatePartStock(item.partId, newStock);

        final history = StockHistoryModel(
          id: 'hist_${const Uuid().v4().substring(0, 8)}',
          partId: item.partId,
          partName: item.partName,
          changeType: 'Purchase',
          quantityChange: item.quantity,
          resultingStock: newStock,
          referenceNumber: purchaseInvoiceNumber,
          notes: 'Purchase entry from ${supplier.name}',
          timestamp: DateTime.now(),
        );
        await AppDatabase.instance.insertStockHistory(history);
      }
    }

    await loadData();
  }
}
