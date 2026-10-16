import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/billing_provider.dart';
import 'invoice_preview_screen.dart';
import 'new_bill_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final locale = context.watch<LocaleProvider>();

    final invoices = billing.allInvoices.where((inv) {
      if (_selectedStatus != 'All' && inv.status != _selectedStatus) {
        return false;
      }
      if (_searchController.text.trim().isNotEmpty) {
        final q = _searchController.text.toLowerCase().trim();
        final num = inv.invoiceNumber.toLowerCase();
        final name = inv.customerName.toLowerCase();
        final vehicle = inv.vehicleNumber.toLowerCase();
        final phone = inv.customerPhone.toLowerCase();
        return num.contains(q) || name.contains(q) || vehicle.contains(q) || phone.contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('invoice_list')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewBillScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(locale.translate('nav_billing')),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search invoice #, customer, vehicle...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['All', 'Completed', 'Returned'].map((status) {
                final isSel = _selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSel,
                    onSelected: (sel) {
                      if (sel) setState(() => _selectedStatus = status);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 12),

          // Invoices List
          Expanded(
            child: billing.isLoading
                ? const Center(child: CircularProgressIndicator())
                : invoices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_outlined, size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(locale.translate('no_data'), style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 4),
                        itemCount: invoices.length,
                        itemBuilder: (context, index) {
                          final inv = invoices[index];
                          final isReturned = inv.status == 'Returned';

                          return Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InvoicePreviewScreen(invoice: inv),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: isReturned
                                    ? AppColors.dangerLight
                                    : (inv.balanceDue > 0 ? AppColors.warningLight : AppColors.successLight),
                                child: Icon(
                                  isReturned ? Icons.undo : (inv.balanceDue > 0 ? Icons.credit_card : Icons.check),
                                  color: isReturned
                                      ? AppColors.danger
                                      : (inv.balanceDue > 0 ? AppColors.accentDark : AppColors.success),
                                ),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    inv.invoiceNumber,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(inv.grandTotal),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3),
                                  Text(
                                    '${inv.customerName} ${inv.vehicleNumber.isNotEmpty ? '• 🚗 ${inv.vehicleNumber}' : ''}',
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormatter.formatWithTime(inv.date),
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      if (inv.balanceDue > 0)
                                        Text(
                                          'Due: ${CurrencyFormatter.format(inv.balanceDue)}',
                                          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 11.5),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right, size: 20),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
