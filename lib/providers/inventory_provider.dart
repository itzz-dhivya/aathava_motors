import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/part_model.dart';
import '../models/stock_history_model.dart';
import '../core/database/app_database.dart';

class InventoryProvider extends ChangeNotifier {
  List<PartModel> _parts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showOnlyLowStock = false;

  List<PartModel> get allParts => _parts;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get showOnlyLowStock => _showOnlyLowStock;

  int get totalPartsCount => _parts.length;
  int get lowStockCount => _parts.where((p) => p.isLowStock || p.isOutOfStock).length;
  double get totalStockValueCost => _parts.fold(0.0, (sum, p) => sum + (p.purchasePrice * p.stockQuantity));
  double get totalStockValueRetail => _parts.fold(0.0, (sum, p) => sum + (p.sellingPrice * p.stockQuantity));

  List<PartModel> get filteredParts {
    return _parts.where((part) {
      // Category filter
      if (_selectedCategory != 'All' &&
          !part.category.toLowerCase().contains(_selectedCategory.toLowerCase())) {
        return false;
      }
      // Low stock filter
      if (_showOnlyLowStock && !part.isLowStock && !part.isOutOfStock) {
        return false;
      }
      // Search query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchesName = part.name.toLowerCase().contains(q);
        final matchesNum = part.partNumber.toLowerCase().contains(q);
        final matchesBrand = part.brand.toLowerCase().contains(q);
        final matchesBarcode = part.barcode.toLowerCase().contains(q);
        final matchesHsn = part.hsnCode.toLowerCase().contains(q);
        return matchesName || matchesNum || matchesBrand || matchesBarcode || matchesHsn;
      }
      return true;
    }).toList();
  }

  InventoryProvider() {
    loadParts();
  }

  Future<void> loadParts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _parts = await AppDatabase.instance.getAllParts();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleLowStockFilter() {
    _showOnlyLowStock = !_showOnlyLowStock;
    notifyListeners();
  }

  Future<PartModel?> findByBarcode(String barcode) async {
    final clean = barcode.trim().toLowerCase();
    for (final part in _parts) {
      if (part.barcode.toLowerCase() == clean || part.partNumber.toLowerCase() == clean) {
        return part;
      }
    }
    return await AppDatabase.instance.getPartByBarcode(barcode);
  }

  Future<void> addPart(PartModel part) async {
    final newPart = part.id.isEmpty
        ? part.copyWith(id: 'part_${const Uuid().v4().substring(0, 8)}')
        : part;

    await AppDatabase.instance.insertPart(newPart);

    // Record Initial stock movement
    final history = StockHistoryModel(
      id: 'hist_${const Uuid().v4().substring(0, 8)}',
      partId: newPart.id,
      partName: newPart.name,
      changeType: 'Initial',
      quantityChange: newPart.stockQuantity,
      resultingStock: newPart.stockQuantity,
      referenceNumber: 'NEW-PART-ENTRY',
      notes: 'Initial inventory entry',
      timestamp: DateTime.now(),
    );
    await AppDatabase.instance.insertStockHistory(history);

    await loadParts();
  }

  Future<void> updatePart(PartModel part) async {
    await AppDatabase.instance.updatePart(part);
    await loadParts();
  }

  Future<void> deletePart(String id) async {
    await AppDatabase.instance.deletePart(id);
    await loadParts();
  }

  Future<void> adjustStock({
    required String partId,
    required double quantityDelta,
    required String reason,
  }) async {
    final part = await AppDatabase.instance.getPartById(partId);
    if (part != null) {
      final newStock = (part.stockQuantity + quantityDelta).clamp(0.0, double.infinity);
      await AppDatabase.instance.updatePartStock(partId, newStock);

      final history = StockHistoryModel(
        id: 'hist_${const Uuid().v4().substring(0, 8)}',
        partId: part.id,
        partName: part.name,
        changeType: 'Adjustment',
        quantityChange: quantityDelta,
        resultingStock: newStock,
        referenceNumber: 'STOCK-ADJUST',
        notes: reason.isNotEmpty ? reason : 'Manual stock adjustment',
        timestamp: DateTime.now(),
      );
      await AppDatabase.instance.insertStockHistory(history);

      await loadParts();
    }
  }
}
