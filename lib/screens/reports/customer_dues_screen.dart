import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pdf_report_service.dart';
import '../../services/csv_export_service.dart';
import '../../services/whatsapp_service.dart';
import '../customers/customer_detail_screen.dart';

class CustomerDuesScreen extends StatelessWidget {
  const CustomerDuesScreen({super.key});

  void _sendReminder(BuildContext context, CustomerModel customer) async {
    final shop = context.read<SettingsProvider>().shop;
    final sent = await WhatsAppService.sendDuesReminder(customer: customer, shop: shop);
    if (!sent && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  void _callCustomer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final shop = context.watch<SettingsProvider>().shop;
    final locale = context.watch<LocaleProvider>();

    final duesList = customerProvider.customersWithDues;
    final totalDues = customerProvider.totalCreditDue;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('dues_ledger')),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: locale.translate('export_pdf'),
            onPressed: () => PdfReportService.shareCustomerDuesPdf(customerProvider.allCustomers, shop),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            tooltip: locale.translate('export_csv'),
            onPressed: () => CsvExportService.exportCustomerDuesToCsv(customerProvider.allCustomers),
          ),
        ],
      ),
      body: Column(
        children: [
          // Total Dues Header Card
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Outstanding Credit to Collect',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(totalDues),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.danger),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${duesList.length} customers with pending balance',
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => PdfReportService.shareCustomerDuesPdf(customerProvider.allCustomers, shop),
                  icon: const Icon(Icons.picture_as_pdf, size: 15),
                  label: const Text('Export PDF', style: TextStyle(fontSize: 11.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ],
            ),
          ),

          // List of Customers with dues
          Expanded(
            child: duesList.isEmpty
                ? const Center(
                    child: Text('🎉 Awesome! No customers have pending credit dues.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    itemCount: duesList.length,
                    itemBuilder: (context, index) {
                      final c = duesList[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.dangerLight,
                                    child: const Icon(Icons.credit_card, color: AppColors.danger),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                                        if (c.vehicleNumber.isNotEmpty)
                                          Text('🚗 ${c.vehicleNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentDark, fontSize: 12)),
                                        Text('Ph: ${c.phone}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Balance Due', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                                      Text(
                                        CurrencyFormatter.format(c.pendingBalance),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.danger),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _callCustomer(c.phone),
                                    icon: const Icon(Icons.phone, size: 14),
                                    label: const Text('Call', style: TextStyle(fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _sendReminder(context, c),
                                    icon: const Icon(Icons.send_rounded, size: 14),
                                    label: const Text('Remind WhatsApp', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF25D366),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    tooltip: 'View Details',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CustomerDetailScreen(customerId: c.id),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
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
