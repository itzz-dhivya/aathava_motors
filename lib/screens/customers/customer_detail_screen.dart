import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/customer_model.dart';
import '../../models/invoice_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/whatsapp_service.dart';
import '../billing/invoice_preview_screen.dart';
import 'add_edit_customer_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  List<InvoiceModel> _customerInvoices = [];
  bool _isLoadingInvoices = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoadingInvoices = true);
    _customerInvoices = await context.read<CustomerProvider>().getCustomerInvoices(widget.customerId);
    setState(() => _isLoadingInvoices = false);
  }

  void _showReceivePaymentDialog(CustomerModel customer) {
    final amountController = TextEditingController(text: customer.pendingBalance > 0 ? customer.pendingBalance.toString() : '');
    final notesController = TextEditingController();
    String paymentMode = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Record Payment Received'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Due: ${CurrencyFormatter.format(customer.pendingBalance)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount Received (₹)',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: paymentMode,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Payment Mode'),
                  items: ['Cash', 'UPI', 'Card', 'Bank Transfer']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => paymentMode = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Reference / Note',
                    hintText: 'e.g. GPay ref 123456',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                  if (amount <= 0) return;

                  await context.read<CustomerProvider>().receivePayment(
                        customerId: customer.id,
                        amountReceived: amount,
                        paymentMode: paymentMode,
                        notes: notesController.text.trim(),
                      );

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment of ${CurrencyFormatter.format(amount)} recorded!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                child: const Text('Confirm Payment'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sendWhatsAppReminder(CustomerModel customer) async {
    final shop = context.read<SettingsProvider>().shop;
    final sent = await WhatsAppService.sendDuesReminder(customer: customer, shop: shop);
    if (!sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  void _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final locale = context.watch<LocaleProvider>();

    final customer = customerProvider.allCustomers.firstWhere(
      (c) => c.id == widget.customerId,
      orElse: () => CustomerModel(id: '', name: 'Not Found', phone: ''),
    );

    if (customer.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Customer Details')),
        body: const Center(child: Text('Customer not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: locale.translate('edit'),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditCustomerScreen(customer: customer)),
              );
            },
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
                // Profile & Balance Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  if (customer.vehicleNumber.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 3),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '🚗 ${customer.vehicleNumber}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentDark),
                                      ),
                                    ),
                                  Text('Mobile: ${customer.phone}', style: const TextStyle(color: Colors.grey)),
                                  if (customer.gstin.isNotEmpty)
                                    Text('GSTIN: ${customer.gstin}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Balance Due & Actions
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pending Credit Balance:',
                                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(customer.pendingBalance),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: customer.pendingBalance > 0 ? AppColors.danger : AppColors.success,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showReceivePaymentDialog(customer),
                              icon: const Icon(Icons.payment, size: 15),
                              label: const Text('Receive Payment', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Action Buttons: Call & WhatsApp
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _makePhoneCall(customer.phone),
                                icon: const Icon(Icons.phone, size: 16),
                                label: const Text('Call'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (customer.pendingBalance > 0)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _sendWhatsAppReminder(customer),
                                  icon: const Icon(Icons.send_rounded, size: 16),
                                  label: const Text('Remind Dues'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Customer Purchase History Invoices
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Purchase History (${_customerInvoices.length} Bills)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isLoadingInvoices)
                  const Center(child: CircularProgressIndicator())
                else if (_customerInvoices.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: const Text('No past invoices recorded for this customer.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _customerInvoices.length,
                    itemBuilder: (context, index) {
                      final inv = _customerInvoices[index];
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: inv)),
                            );
                          },
                          leading: const CircleAvatar(
                            child: Icon(Icons.receipt),
                          ),
                          title: Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${DateFormatter.formatShort(inv.date)} • ${inv.items.length} items • ${inv.paymentMode}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(CurrencyFormatter.format(inv.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (inv.balanceDue > 0)
                                Text('Due: ${CurrencyFormatter.format(inv.balanceDue)}', style: const TextStyle(color: AppColors.danger, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
