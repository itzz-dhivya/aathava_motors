class GstCalculationResult {
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalTax;
  final double grossAmount;
  final double discountAmount;
  final double netAmount;
  final double roundOff;
  final double grandTotal;
  final bool isInterState;

  GstCalculationResult({
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalTax,
    required this.grossAmount,
    required this.discountAmount,
    required this.netAmount,
    required this.roundOff,
    required this.grandTotal,
    required this.isInterState,
  });
}

class GstCalculator {
  /// Calculate line item values
  static ({
    double itemTaxable,
    double itemCgst,
    double itemSgst,
    double itemIgst,
    double itemTax,
    double itemTotal,
  }) calculateItem({
    required double price,
    required double quantity,
    required double gstRate, // e.g. 18.0
    required bool isGstInclusive,
    required bool isInterState,
    double itemDiscountPercent = 0.0,
    double itemDiscountFlat = 0.0,
  }) {
    double baseTotal = price * quantity;
    double discount = 0.0;
    if (itemDiscountPercent > 0) {
      discount += (baseTotal * (itemDiscountPercent / 100));
    }
    discount += itemDiscountFlat;
    if (discount > baseTotal) discount = baseTotal;

    double effectiveAmount = baseTotal - discount;
    double taxable = 0.0;
    double totalTax = 0.0;

    if (isGstInclusive) {
      // price includes GST
      taxable = effectiveAmount / (1 + (gstRate / 100.0));
      totalTax = effectiveAmount - taxable;
    } else {
      // price excludes GST
      taxable = effectiveAmount;
      totalTax = taxable * (gstRate / 100.0);
    }

    double cgst = 0.0;
    double sgst = 0.0;
    double igst = 0.0;

    if (isInterState) {
      igst = totalTax;
    } else {
      cgst = totalTax / 2.0;
      sgst = totalTax / 2.0;
    }

    double itemTotal = taxable + totalTax;

    return (
      itemTaxable: double.parse(taxable.toStringAsFixed(2)),
      itemCgst: double.parse(cgst.toStringAsFixed(2)),
      itemSgst: double.parse(sgst.toStringAsFixed(2)),
      itemIgst: double.parse(igst.toStringAsFixed(2)),
      itemTax: double.parse(totalTax.toStringAsFixed(2)),
      itemTotal: double.parse(itemTotal.toStringAsFixed(2)),
    );
  }

  /// Check if two states represent an inter-state sale
  static bool checkIsInterState(String shopState, String customerState) {
    if (customerState.trim().isEmpty) return false; // Default to intra-state if customer state empty
    final s1 = shopState.trim().toLowerCase();
    final s2 = customerState.trim().toLowerCase();
    return s1 != s2;
  }
}
