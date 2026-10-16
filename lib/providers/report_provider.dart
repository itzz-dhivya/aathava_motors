import 'package:flutter/material.dart';
import '../models/invoice_model.dart';
import '../models/part_model.dart';
import '../models/customer_model.dart';
import '../core/database/app_database.dart';

class Gstr1Summary {
  final double b2bTaxable;
  final double b2bTotalTax;
  final double b2bGrandTotal;
  final int b2bInvoicesCount;

  final double b2cTaxable;
  final double b2cTotalTax;
  final double b2cGrandTotal;
  final int b2cInvoicesCount;

  final double totalTaxable;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double grandTotalTax;
  final double totalSales;

  Gstr1Summary({
    required this.b2bTaxable,
    required this.b2bTotalTax,
    required this.b2bGrandTotal,
    required this.b2bInvoicesCount,
    required this.b2cTaxable,
    required this.b2cTotalTax,
    required this.b2cGrandTotal,
    required this.b2cInvoicesCount,
    required this.totalTaxable,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.grandTotalTax,
    required this.totalSales,
  });
}

class TopSellingPart {
  final String partId;
  final String partName;
  final String partNumber;
  final double totalQuantity;
  final double totalRevenue;

  TopSellingPart({
    required this.partId,
    required this.partName,
    required this.partNumber,
    required this.totalQuantity,
    required this.totalRevenue,
  });
}

class ReportProvider extends ChangeNotifier {
  List<InvoiceModel> _invoices = [];
  List<PartModel> _parts = [];
  List<CustomerModel> _customers = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<InvoiceModel> get invoices => _invoices;

  ReportProvider() {
    loadReports();
  }

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      _invoices = await AppDatabase.instance.getAllInvoices();
      _parts = await AppDatabase.instance.getAllParts();
      _customers = await AppDatabase.instance.getAllCustomers();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  // Active (non-returned/non-cancelled) invoices
  List<InvoiceModel> get completedInvoices =>
      _invoices.where((i) => i.status == 'Completed').toList();

  // Daily Sales (Today)
  double get todaySales {
    final now = DateTime.now();
    return completedInvoices.where((i) {
      return i.date.year == now.year &&
          i.date.month == now.month &&
          i.date.day == now.day;
    }).fold(0.0, (sum, i) => sum + i.grandTotal);
  }

  int get todayInvoiceCount {
    final now = DateTime.now();
    return completedInvoices.where((i) {
      return i.date.year == now.year &&
          i.date.month == now.month &&
          i.date.day == now.day;
    }).length;
  }

  // Monthly Sales (This Month)
  double get thisMonthSales {
    final now = DateTime.now();
    return completedInvoices.where((i) {
      return i.date.year == now.year && i.date.month == now.month;
    }).fold(0.0, (sum, i) => sum + i.grandTotal);
  }

  int get thisMonthInvoiceCount {
    final now = DateTime.now();
    return completedInvoices.where((i) {
      return i.date.year == now.year && i.date.month == now.month;
    }).length;
  }

  // Total Lifetime Sales
  double get totalLifetimeSales =>
      completedInvoices.fold(0.0, (sum, i) => sum + i.grandTotal);

  // Total Lifetime Tax
  double get totalLifetimeTax =>
      completedInvoices.fold(0.0, (sum, i) => sum + i.totalTax);

  // Total Outstanding Customer Dues
  double get totalOutstandingDues =>
      _customers.fold(0.0, (sum, c) => sum + c.pendingBalance);

  // Payment Mode Breakdown
  Map<String, double> get paymentModeBreakdown {
    final Map<String, double> map = {
      'Cash': 0.0,
      'UPI': 0.0,
      'Card': 0.0,
      'Credit': 0.0,
    };
    for (final inv in completedInvoices) {
      final mode = inv.paymentMode;
      map[mode] = (map[mode] ?? 0.0) + inv.paidAmount;
      if (inv.balanceDue > 0) {
        map['Credit'] = (map['Credit'] ?? 0.0) + inv.balanceDue;
      }
    }
    return map;
  }

  // GSTR-1 Ready Summary
  Gstr1Summary get gstr1Summary {
    double b2bTaxable = 0.0;
    double b2bTotalTax = 0.0;
    double b2bGrandTotal = 0.0;
    int b2bCount = 0;

    double b2cTaxable = 0.0;
    double b2cTotalTax = 0.0;
    double b2cGrandTotal = 0.0;
    int b2cCount = 0;

    double totalCgst = 0.0;
    double totalSgst = 0.0;
    double totalIgst = 0.0;

    for (final inv in completedInvoices) {
      totalCgst += inv.cgstTotal;
      totalSgst += inv.sgstTotal;
      totalIgst += inv.igstTotal;

      if (inv.isB2B) {
        b2bTaxable += inv.subtotalTaxable;
        b2bTotalTax += inv.totalTax;
        b2bGrandTotal += inv.grandTotal;
        b2bCount++;
      } else {
        b2cTaxable += inv.subtotalTaxable;
        b2cTotalTax += inv.totalTax;
        b2cGrandTotal += inv.grandTotal;
        b2cCount++;
      }
    }

    return Gstr1Summary(
      b2bTaxable: double.parse(b2bTaxable.toStringAsFixed(2)),
      b2bTotalTax: double.parse(b2bTotalTax.toStringAsFixed(2)),
      b2bGrandTotal: double.parse(b2bGrandTotal.toStringAsFixed(2)),
      b2bInvoicesCount: b2Count(b2bCount),
      b2cTaxable: double.parse(b2cTaxable.toStringAsFixed(2)),
      b2cTotalTax: double.parse(b2cTotalTax.toStringAsFixed(2)),
      b2cGrandTotal: double.parse(b2cGrandTotal.toStringAsFixed(2)),
      b2cInvoicesCount: b2Count(b2cCount),
      totalTaxable: double.parse((b2bTaxable + b2cTaxable).toStringAsFixed(2)),
      totalCgst: double.parse(totalCgst.toStringAsFixed(2)),
      totalSgst: double.parse(totalSgst.toStringAsFixed(2)),
      totalIgst: double.parse(totalIgst.toStringAsFixed(2)),
      grandTotalTax: double.parse((totalCgst + totalSgst + totalIgst).toStringAsFixed(2)),
      totalSales: double.parse((b2bGrandTotal + b2cGrandTotal).toStringAsFixed(2)),
    );
  }

  int b2Count(int count) => count;

  // Top Selling Items
  List<TopSellingPart> get topSellingParts {
    final Map<String, ({String name, String number, double qty, double revenue})> agg = {};

    for (final inv in completedInvoices) {
      for (final item in inv.items) {
        if (!agg.containsKey(item.partId)) {
          agg[item.partId] = (
            name: item.partName,
            number: item.partNumber,
            qty: item.quantity,
            revenue: item.totalAmount,
          );
        } else {
          final current = agg[item.partId]!;
          agg[item.partId] = (
            name: current.name,
            number: current.number,
            qty: current.qty + item.quantity,
            revenue: current.revenue + item.totalAmount,
          );
        }
      }
    }

    final list = agg.entries.map((e) {
      return TopSellingPart(
        partId: e.key,
        partName: e.value.name,
        partNumber: e.value.number,
        totalQuantity: e.value.qty,
        totalRevenue: e.value.revenue,
      );
    }).toList();

    list.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    return list;
  }

  // Low Stock Items
  List<PartModel> get lowStockParts =>
      _parts.where((p) => p.isLowStock || p.isOutOfStock).toList();

  // Customers with Dues
  List<CustomerModel> get customerDues =>
      _customers.where((c) => c.pendingBalance > 0.01).toList();
}
