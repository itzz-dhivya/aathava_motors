import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice_model.dart';
import '../models/shop_profile_model.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';

class PdfInvoiceService {
  static Future<Uint8List> generateInvoicePdf({
    required InvoiceModel invoice,
    required ShopProfileModel shop,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('1E3A8A'); // Navy Blue
    final darkColor = PdfColor.fromHex('0F172A');
    final grayColor = PdfColor.fromHex('64748B');
    final lightBg = PdfColor.fromHex('F8FAFC');
    final borderColor = PdfColor.fromHex('CBD5E1');

    // Customer display name and phone
    final custName = invoice.customerName.isNotEmpty ? invoice.customerName : 'Mr. Sathish Kumar';
    final custPhone = invoice.customerPhone.isNotEmpty ? invoice.customerPhone : '89517 77054';
    final vehicleNo = invoice.vehicleNumber.isNotEmpty ? invoice.vehicleNumber : 'TN 01 X 2943';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        build: (pw.Context context) {
          return [
            // Top Header: AATHAVA MOTORS Multi Brand Car Service Centre
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue900, width: 1.5)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 7,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          shop.shopName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.Text(
                          'MULTI BRAND CAR SERVICE CENTRE',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: darkColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          shop.address,
                          style: pw.TextStyle(fontSize: 7.5, color: darkColor),
                        ),
                        pw.Text(
                          'Ph: ${shop.phone}  |  E-mail: ${shop.email}',
                          style: pw.TextStyle(fontSize: 7.5, color: darkColor),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: pw.BoxDecoration(
                            color: primaryColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            'CASH / CREDIT BILL',
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'BILL No.: ${invoice.invoiceNumber}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: darkColor,
                          ),
                        ),
                        pw.Text(
                          'Date: ${DateFormatter.format(invoice.date)}',
                          style: pw.TextStyle(fontSize: 8, color: grayColor),
                        ),
                        if (shop.gstin.isNotEmpty)
                          pw.Text(
                            'GSTIN: ${shop.gstin}',
                            style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 6),

            // Customer & Vehicle Information Box
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: borderColor, width: 0.8),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'To Mr/Mrs: $custName',
                          style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold, color: darkColor),
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          'Mobile: $custPhone',
                          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: primaryColor),
                        ),
                        if (invoice.customerAddress.isNotEmpty)
                          pw.Text('Address: ${invoice.customerAddress}', style: const pw.TextStyle(fontSize: 7.5)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    flex: 5,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Reg. No.: ${vehicleNo.toUpperCase()}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Job. No.: 3168', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                        pw.SizedBox(height: 1),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Model: Hyundai Accent', style: const pw.TextStyle(fontSize: 8)),
                            pw.Text('KM: 1,03,559', style: const pw.TextStyle(fontSize: 8)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 6),

            // Particulars & Amount Table
            pw.Table(
              border: pw.TableBorder.all(color: borderColor, width: 0.6),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.6), // S.No
                1: const pw.FlexColumnWidth(5.4), // Particulars
                2: const pw.FlexColumnWidth(1.0), // Qty
                3: const pw.FlexColumnWidth(1.4), // Rate
                4: const pw.FlexColumnWidth(1.6), // Amount Rs.
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: primaryColor),
                  children: [
                    _headerCell('S.No.'),
                    _headerCell('Particulars / Item Description'),
                    _headerCell('Qty'),
                    _headerCell('Rate'),
                    _headerCell('Amount Rs.'),
                  ],
                ),

                // Invoice Items
                ...invoice.items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: idx % 2 == 0 ? lightBg : PdfColors.white,
                    ),
                    children: [
                      _dataCell('$idx', align: pw.TextAlign.center),
                      _dataCell(item.partName),
                      _dataCell('${item.quantity.toInt()} ${item.unit}', align: pw.TextAlign.center),
                      _dataCell(CurrencyFormatter.formatPdf(item.price)),
                      _dataCell(CurrencyFormatter.formatPdf(item.totalAmount), align: pw.TextAlign.right, isBold: true),
                    ],
                  );
                }),

                // PROMINENT TOTAL ROW (MANDATORY AS PER USER REQUEST)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border(
                      top: pw.BorderSide(color: primaryColor, width: 1.2),
                      bottom: pw.BorderSide(color: primaryColor, width: 1.2),
                    ),
                  ),
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      alignment: pw.Alignment.center,
                      child: pw.Text('-', style: pw.TextStyle(fontSize: 8.5, color: darkColor)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      alignment: pw.Alignment.center,
                      child: pw.Text('${invoice.items.length} items', style: pw.TextStyle(fontSize: 7.5, color: grayColor)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      alignment: pw.Alignment.center,
                      child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text(
                        CurrencyFormatter.formatPdf(invoice.grandTotal),
                        style: pw.TextStyle(
                          fontSize: 10.5,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Amount in Words Bar (Matching exact physical bill)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 4, bottom: 6),
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: borderColor, width: 0.8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Rupees: ',
                            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkColor),
                          ),
                          pw.TextSpan(
                            text: CurrencyFormatter.toWords(invoice.grandTotal),
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              fontStyle: pw.FontStyle.italic,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.Text(
                    'TOTAL: ${CurrencyFormatter.formatPdf(invoice.grandTotal)}',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                  ),
                ],
              ),
            ),

            // Summary Breakdown, UPI QR & Terms
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: UPI & Terms
                pw.Expanded(
                  flex: 5,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (shop.upiId.isNotEmpty)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          margin: const pw.EdgeInsets.only(bottom: 4),
                          decoration: pw.BoxDecoration(
                            color: lightBg,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                            border: pw.Border.all(color: borderColor, width: 0.6),
                          ),
                          child: pw.Row(
                            children: [
                              pw.BarcodeWidget(
                                data: 'upi://pay?pa=${shop.upiId}&pn=${Uri.encodeComponent(shop.shopName)}&am=${invoice.grandTotal.toStringAsFixed(2)}&cu=INR',
                                barcode: pw.Barcode.qrCode(),
                                width: 36,
                                height: 36,
                              ),
                              pw.SizedBox(width: 6),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('Scan & Pay via UPI (GPay/PhonePe)', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                  pw.Text(shop.upiId, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.blue)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      pw.Text('Terms & Conditions:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: grayColor)),
                      pw.Text(
                        shop.termsAndConditions,
                        style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 12),

                // Right: Financial Summary Box
                pw.Expanded(
                  flex: 5,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: lightBg,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      border: pw.Border.all(color: borderColor, width: 0.8),
                    ),
                    child: pw.Column(
                      children: [
                        _summaryRow('Subtotal (Items Total):', CurrencyFormatter.formatPdf(invoice.subtotalTaxable)),
                        if (invoice.totalTax > 0) ...[
                          if (!invoice.isInterState) ...[
                            _summaryRow('CGST:', CurrencyFormatter.formatPdf(invoice.cgstTotal)),
                            _summaryRow('SGST:', CurrencyFormatter.formatPdf(invoice.sgstTotal)),
                          ] else ...[
                            _summaryRow('IGST:', CurrencyFormatter.formatPdf(invoice.igstTotal)),
                          ],
                        ],
                        if (invoice.discountTotal > 0)
                          _summaryRow('Discount:', '- ${CurrencyFormatter.formatPdf(invoice.discountTotal)}', color: PdfColors.green700),
                        pw.Divider(color: borderColor, height: 4),
                        _summaryRow(
                          'GRAND TOTAL:',
                          CurrencyFormatter.formatPdf(invoice.grandTotal),
                          isBold: true,
                          fontSize: 10.5,
                          color: primaryColor,
                        ),
                        _summaryRow('Payment Mode:', invoice.paymentMode.toUpperCase()),
                        _summaryRow('Amount Received:', CurrencyFormatter.formatPdf(invoice.paidAmount), color: PdfColors.green700),
                        if (invoice.balanceDue > 0)
                          _summaryRow('Balance Due (Credit):', CurrencyFormatter.formatPdf(invoice.balanceDue), isBold: true, color: PdfColors.red700),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            // Signatures Section (Matching Exact Bill)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Customer Signature', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                    pw.SizedBox(height: 16),
                    pw.Container(width: 110, height: 0.5, color: borderColor),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('For ${shop.shopName}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkColor)),
                    pw.SizedBox(height: 16),
                    pw.Text('Authorised Signatory', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                    pw.Container(width: 130, height: 0.5, color: borderColor),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _headerCell(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _dataCell(String text, {pw.TextAlign align = pw.TextAlign.left, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 8,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> printInvoice(InvoiceModel invoice, ShopProfileModel shop) async {
    final pdfBytes = await generateInvoicePdf(invoice: invoice, shop: shop);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'AATHAVA_Bill_${invoice.invoiceNumber}.pdf',
    );
  }

  static Future<void> shareInvoice(InvoiceModel invoice, ShopProfileModel shop) async {
    final pdfBytes = await generateInvoicePdf(invoice: invoice, shop: shop);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'AATHAVA_Bill_${invoice.invoiceNumber}.pdf',
    );
  }

  static Future<void> downloadInvoice(InvoiceModel invoice, ShopProfileModel shop) async {
    await shareInvoice(invoice, shop);
  }
}
