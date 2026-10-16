import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrCompact = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _pdfFormat = NumberFormat('#,##,##0.00', 'en_IN');
  static final NumberFormat _pdfCompact = NumberFormat('#,##,##0', 'en_IN');

  static String format(double amount, {bool showDecimals = true}) {
    if (!showDecimals || amount == amount.roundToDouble()) {
      return _inrCompact.format(amount);
    }
    return _inrFormat.format(amount);
  }

  /// Formats currency with 'Rs.' prefix for PDF generators,
  /// avoiding missing-glyph box errors with Unicode '₹' in standard PDF fonts.
  static String formatPdf(double amount, {bool showDecimals = false}) {
    if (!showDecimals || amount == amount.roundToDouble()) {
      return 'Rs. ${_pdfCompact.format(amount)}';
    }
    return 'Rs. ${_pdfFormat.format(amount)}';
  }

  static String formatNumber(double number) {
    final format = NumberFormat('#,##,###.##', 'en_IN');
    return format.format(number);
  }

  /// Converts amount to Indian currency words e.g. "Rupees Forty Two Thousand Five Hundred and Twenty only"
  static String toWords(double amount) {
    int n = amount.round();
    if (n <= 0) return 'Rupees Zero only';

    const units = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen'
    ];
    const tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];

    String convertBelowThousand(int num) {
      if (num == 0) return '';
      if (num < 20) return units[num];
      if (num < 100) {
        final rem = num % 10;
        return '${tens[num ~/ 10]}${rem != 0 ? " ${units[rem]}" : ""}';
      }
      final rem = num % 100;
      return '${units[num ~/ 100]} Hundred${rem != 0 ? " and ${convertBelowThousand(rem)}" : ""}';
    }

    String result = '';
    if (n >= 10000000) {
      result += '${convertBelowThousand(n ~/ 10000000)} Crore ';
      n %= 10000000;
    }
    if (n >= 100000) {
      result += '${convertBelowThousand(n ~/ 100000)} Lakh ';
      n %= 100000;
    }
    if (n >= 1000) {
      result += '${convertBelowThousand(n ~/ 1000)} Thousand ';
      n %= 1000;
    }
    if (n > 0) {
      result += convertBelowThousand(n);
    }

    return 'Rupees ${result.trim()} only';
  }
}
