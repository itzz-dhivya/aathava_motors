import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/shop_profile_model.dart';
import '../models/customer_model.dart';
import '../providers/report_provider.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class PdfReportService {
  static Future<Uint8List> generateGstr1Pdf({
    required Gstr1Summary summary,
    required ShopProfileModel shop,
  }) async {
    final pdf = pw.Document();
    final primaryColor = PdfColor.fromHex('1E3A8A');
    final darkColor = PdfColor.fromHex('0F172A');
    final grayColor = PdfColor.fromHex('64748B');
    final lightBg = PdfColor.fromHex('F8FAFC');
    final borderColor = PdfColor.fromHex('CBD5E1');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        shop.shopName.toUpperCase(),
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor),
                      ),
                      pw.Text('GSTIN: ${shop.gstin}  |  State: ${shop.state}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('GSTR-1 TAX REPORT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Generated: ${DateFormatter.formatWithTime(DateTime.now())}', style: pw.TextStyle(fontSize: 8.5, color: grayColor)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: borderColor),
              pw.SizedBox(height: 12),

              // KPI Summary Boxes
              pw.Row(
                children: [
                  _statBox('Total Taxable Value', CurrencyFormatter.formatPdf(summary.totalTaxable), primaryColor),
                  pw.SizedBox(width: 8),
                  _statBox('Total GST Collected', CurrencyFormatter.formatPdf(summary.grandTotalTax), PdfColors.green800),
                  pw.SizedBox(width: 8),
                  _statBox('Total Gross Revenue', CurrencyFormatter.formatPdf(summary.totalSales), darkColor),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Text('1. B2B & B2C Breakdown', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      _cell('Sales Category', isHeader: true),
                      _cell('Invoices', isHeader: true, align: pw.TextAlign.center),
                      _cell('Taxable Value', isHeader: true, align: pw.TextAlign.right),
                      _cell('Total Tax', isHeader: true, align: pw.TextAlign.right),
                      _cell('Invoice Total', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBg),
                    children: [
                      _cell('B2B Sales (Registered GSTIN)'),
                      _cell('${summary.b2bInvoicesCount}', align: pw.TextAlign.center),
                      _cell(CurrencyFormatter.format(summary.b2bTaxable), align: pw.TextAlign.right),
                      _cell(CurrencyFormatter.format(summary.b2bTotalTax), align: pw.TextAlign.right),
                      _cell(CurrencyFormatter.format(summary.b2bGrandTotal), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cell('B2C Sales (Consumers & Retail)'),
                      _cell('${summary.b2cInvoicesCount}', align: pw.TextAlign.center),
                      _cell(CurrencyFormatter.format(summary.b2cTaxable), align: pw.TextAlign.right),
                      _cell(CurrencyFormatter.format(summary.b2cTotalTax), align: pw.TextAlign.right),
                      _cell(CurrencyFormatter.format(summary.b2cGrandTotal), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Text('2. Tax Component Split', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      _cell('Component', isHeader: true),
                      _cell('Type of Supply', isHeader: true),
                      _cell('Total Amount Collected', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBg),
                    children: [
                      _cell('CGST (Central Goods and Services Tax)'),
                      _cell('Intra-state (Inside ${shop.state})'),
                      _cell(CurrencyFormatter.formatPdf(summary.totalCgst), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _cell('SGST (State Goods and Services Tax)'),
                      _cell('Intra-state (Inside ${shop.state})'),
                      _cell(CurrencyFormatter.formatPdf(summary.totalSgst), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightBg),
                    children: [
                      _cell('IGST (Integrated Goods and Services Tax)'),
                      _cell('Inter-state (Other States)'),
                      _cell(CurrencyFormatter.formatPdf(summary.totalIgst), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.amber100),
                    children: [
                      _cell('TOTAL TAX COLLECTED', isBold: true),
                      _cell('All Supplies', isBold: true),
                      _cell(CurrencyFormatter.formatPdf(summary.grandTotalTax), align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),
              pw.Divider(color: borderColor),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('AutoSpare Pro GST Filing Assistant', style: pw.TextStyle(fontSize: 8, color: grayColor)),
                  pw.Text('Confidential & Business Proprietary', style: pw.TextStyle(fontSize: 8, color: grayColor)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateCustomerDuesPdf({
    required List<CustomerModel> customers,
    required ShopProfileModel shop,
  }) async {
    final pdf = pw.Document();
    final primaryColor = PdfColor.fromHex('1E3A8A');
    final darkColor = PdfColor.fromHex('0F172A');
    final grayColor = PdfColor.fromHex('64748B');
    final lightBg = PdfColor.fromHex('F8FAFC');
    final borderColor = PdfColor.fromHex('CBD5E1');

    final duesList = customers.where((c) => c.pendingBalance > 0.01).toList();
    final totalDues = duesList.fold(0.0, (sum, c) => sum + c.pendingBalance);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(shop.shopName.toUpperCase(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Phone: ${shop.phone}  |  GSTIN: ${shop.gstin}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('CUSTOMER CREDIT & DUES LEDGER', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                      pw.Text('As of ${DateFormatter.formatWithTime(DateTime.now())}', style: pw.TextStyle(fontSize: 8.5, color: grayColor)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: borderColor),
              pw.SizedBox(height: 8),

              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.red200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Outstanding Credit to Collect:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkColor)),
                    pw.Text(CurrencyFormatter.formatPdf(totalDues), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              pw.Table(
                border: pw.TableBorder.all(color: borderColor, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      _cell('#', isHeader: true, align: pw.TextAlign.center),
                      _cell('Customer Name', isHeader: true),
                      _cell('Vehicle #', isHeader: true),
                      _cell('Phone', isHeader: true),
                      _cell('Total Purchases', isHeader: true, align: pw.TextAlign.right),
                      _cell('Balance Due', isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  ...duesList.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final c = entry.value;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(color: idx % 2 == 0 ? lightBg : PdfColors.white),
                      children: [
                        _cell('$idx', align: pw.TextAlign.center),
                        _cell(c.name, isBold: true),
                        _cell(c.vehicleNumber),
                        _cell(c.phone),
                        _cell(CurrencyFormatter.formatPdf(c.totalPurchases), align: pw.TextAlign.right),
                        _cell(CurrencyFormatter.formatPdf(c.pendingBalance), align: pw.TextAlign.right, isBold: true, color: PdfColors.red800),
                      ],
                    );
                  }),
                ],
              ),

              pw.Spacer(),
              pw.Divider(color: borderColor),
              pw.Center(
                child: pw.Text('AutoSpare Pro • End of Dues Ledger', style: pw.TextStyle(fontSize: 8, color: grayColor)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            pw.SizedBox(height: 4),
            pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _cell(
    String text, {
    bool isHeader = false,
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 7.5,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : (color ?? PdfColors.black),
        ),
        textAlign: align,
      ),
    );
  }

  static Future<void> shareGstr1Pdf(Gstr1Summary summary, ShopProfileModel shop) async {
    final bytes = await generateGstr1Pdf(summary: summary, shop: shop);
    await Printing.sharePdf(bytes: bytes, filename: 'GSTR1_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  static Future<void> shareCustomerDuesPdf(List<CustomerModel> customers, ShopProfileModel shop) async {
    final bytes = await generateCustomerDuesPdf(customers: customers, shop: shop);
    await Printing.sharePdf(bytes: bytes, filename: 'Customer_Dues_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }
}
