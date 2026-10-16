import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice_model.dart';
import '../models/part_model.dart';
import '../models/customer_model.dart';
import '../core/utils/date_formatter.dart';

class CsvExportService {
  static Future<void> exportInvoicesToCsv(List<InvoiceModel> invoices) async {
    final List<List<dynamic>> rows = [
      [
        'Invoice #',
        'Date',
        'Customer Name',
        'Customer Phone',
        'Vehicle Number',
        'Customer GSTIN',
        'State',
        'Taxable Amount',
        'CGST',
        'SGST',
        'IGST',
        'Total GST',
        'Discount',
        'Round Off',
        'Grand Total',
        'Payment Mode',
        'Paid Amount',
        'Balance Due',
        'Status',
      ],
      ...invoices.map((inv) => [
            inv.invoiceNumber,
            DateFormatter.formatWithTime(inv.date),
            inv.customerName,
            inv.customerPhone,
            inv.vehicleNumber,
            inv.customerGstin,
            inv.customerState,
            inv.subtotalTaxable,
            inv.cgstTotal,
            inv.sgstTotal,
            inv.igstTotal,
            inv.totalTax,
            inv.discountTotal,
            inv.roundOff,
            inv.grandTotal,
            inv.paymentMode,
            inv.paidAmount,
            inv.balanceDue,
            inv.status,
          ]),
    ];

    await _saveAndShareCsv(rows, 'Sales_Report_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  static Future<void> exportInventoryToCsv(List<PartModel> parts) async {
    final List<List<dynamic>> rows = [
      [
        'Part Name',
        'Part / SKU Number',
        'Brand',
        'Category',
        'HSN Code',
        'Purchase Price',
        'Selling Price',
        'GST Rate (%)',
        'Current Stock',
        'Unit',
        'Barcode',
        'Total Stock Value (Cost)',
        'Total Retail Value',
        'Low Stock Alert Threshold',
      ],
      ...parts.map((part) => [
            part.name,
            part.partNumber,
            part.brand,
            part.category,
            part.hsnCode,
            part.purchasePrice,
            part.sellingPrice,
            part.gstRate,
            part.stockQuantity,
            part.unit,
            part.barcode,
            (part.purchasePrice * part.stockQuantity).toStringAsFixed(2),
            (part.sellingPrice * part.stockQuantity).toStringAsFixed(2),
            part.minStockAlert,
          ]),
    ];

    await _saveAndShareCsv(rows, 'Inventory_Stock_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  static Future<void> exportCustomerDuesToCsv(List<CustomerModel> customers) async {
    final List<List<dynamic>> rows = [
      [
        'Customer Name',
        'Phone Number',
        'Vehicle Number',
        'GSTIN',
        'Address',
        'State',
        'Invoices Count',
        'Total Purchases',
        'Pending Credit Balance',
      ],
      ...customers.where((c) => c.pendingBalance > 0).map((c) => [
            c.name,
            c.phone,
            c.vehicleNumber,
            c.gstin,
            c.address,
            c.state,
            c.invoiceCount,
            c.totalPurchases,
            c.pendingBalance,
          ]),
    ];

    await _saveAndShareCsv(rows, 'Customer_Credit_Dues_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  static Future<void> exportGstr1SummaryToCsv(List<InvoiceModel> invoices) async {
    final List<List<dynamic>> rows = [
      [
        'GSTR-1 Ready Sales Report',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
      ],
      [
        'Invoice #',
        'Invoice Date',
        'Invoice Type',
        'Customer GSTIN',
        'Customer Name',
        'Place of Supply',
        'Taxable Value',
        'Integrated Tax (IGST)',
        'Central Tax (CGST)',
        'State Tax (SGST)',
        'Total Tax',
        'Invoice Total',
      ],
      ...invoices.where((inv) => inv.status == 'Completed').map((inv) => [
            inv.invoiceNumber,
            DateFormatter.formatShort(inv.date),
            inv.isB2B ? 'B2B (Regular)' : 'B2C (Small)',
            inv.customerGstin,
            inv.customerName,
            inv.customerState,
            inv.subtotalTaxable,
            inv.igstTotal,
            inv.cgstTotal,
            inv.sgstTotal,
            inv.totalTax,
            inv.grandTotal,
          ]),
    ];

    await _saveAndShareCsv(rows, 'GSTR1_Report_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  static Future<void> _saveAndShareCsv(List<List<dynamic>> rows, String fileName) async {
    final csvString = csv.encode(rows);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csvString);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: fileName,
      ),
    );
  }
}
