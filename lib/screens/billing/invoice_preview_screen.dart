import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/invoice_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/billing_provider.dart';
import '../../services/pdf_invoice_service.dart';
import '../../services/whatsapp_service.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final InvoiceModel invoice;

  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  late InvoiceModel _currentInvoice;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
  }

  void _printPdf() async {
    final shop = context.read<SettingsProvider>().shop;
    await PdfInvoiceService.printInvoice(_currentInvoice, shop);
  }

  void _sharePdf() async {
    final shop = context.read<SettingsProvider>().shop;
    await PdfInvoiceService.shareInvoice(_currentInvoice, shop);
  }

  void _shareWhatsApp() async {
    final shop = context.read<SettingsProvider>().shop;
    final sent = await WhatsAppService.sendInvoiceToCustomer(
      invoice: _currentInvoice,
      shop: shop,
    );
    if (!sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp. Ensure it is installed.')),
      );
    }
  }

  void _showReturnDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Return / Cancel Invoice?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will cancel invoice ${_currentInvoice.invoiceNumber}, restore all items back into inventory, and remove any pending credit balance from customer ledger.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Return Reason',
                hintText: 'e.g. Customer returned items, wrong part',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<BillingProvider>().processInvoiceReturn(
                    invoice: _currentInvoice,
                    reason: reasonController.text.trim(),
                  );
              if (success && mounted) {
                setState(() {
                  _currentInvoice = _currentInvoice.copyWith(status: 'Returned');
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice marked as Returned. Stock has been restored!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Confirm Return'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<SettingsProvider>().shop;
    final locale = context.watch<LocaleProvider>();
    final isReturned = _currentInvoice.isReturned;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bill: ${_currentInvoice.invoiceNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download PDF',
            onPressed: _sharePdf,
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: locale.translate('print'),
            onPressed: _printPdf,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: locale.translate('share'),
            onPressed: _sharePdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sharePdf,
                        icon: const Icon(Icons.download_rounded, size: 17),
                        label: const Text('Download PDF', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareWhatsApp,
                        icon: const Icon(Icons.send_rounded, size: 17),
                        label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _printPdf,
                        icon: const Icon(Icons.print, size: 17),
                        label: const Text('Print', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Bill Invoice Card Preview
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Shop Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.shopName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(shop.address, style: const TextStyle(fontSize: 12)),
                                  Text('Phone: ${shop.phone}  •  Email: ${shop.email}', style: const TextStyle(fontSize: 11)),
                                  Text('GSTIN: ${shop.gstin}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isReturned ? AppColors.dangerLight : AppColors.successLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _currentInvoice.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isReturned ? AppColors.danger : AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Bill To Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CUSTOMER:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  Text(
                                    _currentInvoice.customerName,
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_currentInvoice.customerPhone.isNotEmpty)
                                    Text('Phone: ${_currentInvoice.customerPhone}', style: const TextStyle(fontSize: 11.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  if (_currentInvoice.vehicleNumber.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '🚗 ${_currentInvoice.vehicleNumber}',
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.accentDark),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Invoice #: ${_currentInvoice.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Date: ${DateFormatter.formatWithTime(_currentInvoice.date)}', style: const TextStyle(fontSize: 10.5, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Payment: ${_currentInvoice.paymentMode}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Items Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 4, child: Text('Item & Part #', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Qty x Rate', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Taxable', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),

                        // Item Rows
                        ..._currentInvoice.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.partName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                      Text('${item.partNumber} • HSN: ${item.hsnCode} • ${item.gstRate.toInt()}% GST', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text('${item.quantity} ${item.unit} x ₹${item.price}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(CurrencyFormatter.format(item.taxableAmount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 11)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(CurrencyFormatter.format(item.totalAmount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Divider(),

                        // Summary Calculations
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 250,
                            child: Column(
                              children: [
                                _row('Taxable Subtotal:', CurrencyFormatter.format(_currentInvoice.subtotalTaxable)),
                                if (!_currentInvoice.isInterState) ...[
                                  _row('CGST:', CurrencyFormatter.format(_currentInvoice.cgstTotal)),
                                  _row('SGST:', CurrencyFormatter.format(_currentInvoice.sgstTotal)),
                                ] else ...[
                                  _row('IGST:', CurrencyFormatter.format(_currentInvoice.igstTotal)),
                                ],
                                _row('Total GST:', CurrencyFormatter.format(_currentInvoice.totalTax)),
                                if (_currentInvoice.discountTotal > 0)
                                  _row('Discount:', '- ${CurrencyFormatter.format(_currentInvoice.discountTotal)}', color: AppColors.success),
                                if (_currentInvoice.roundOff != 0)
                                  _row('Round Off:', _currentInvoice.roundOff > 0 ? '+${_currentInvoice.roundOff}' : '${_currentInvoice.roundOff}'),
                                const Divider(thickness: 1.5),
                                _row(
                                  'Grand Total:',
                                  CurrencyFormatter.format(_currentInvoice.grandTotal),
                                  isBold: true,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                                  child: Text(
                                    CurrencyFormatter.toWords(_currentInvoice.grandTotal),
                                    style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: AppColors.primary, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _row('Amount Paid:', CurrencyFormatter.format(_currentInvoice.paidAmount), color: AppColors.success),
                                if (_currentInvoice.balanceDue > 0)
                                  _row('Balance Due (Credit):', CurrencyFormatter.format(_currentInvoice.balanceDue), isBold: true, color: AppColors.danger),
                              ],
                            ),
                          ),
                        ),

                        if (_currentInvoice.notes.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Notes: ${_currentInvoice.notes}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Return or Cancel Bill Button
                if (!isReturned)
                  Center(
                    child: TextButton.icon(
                      onPressed: _showReturnDialog,
                      icon: const Icon(Icons.undo, color: AppColors.danger),
                      label: const Text('Return / Cancel this Bill', style: TextStyle(color: AppColors.danger)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, double fontSize = 12, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, color: Colors.grey.shade700)),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
