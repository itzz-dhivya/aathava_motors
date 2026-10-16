import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/customer_provider.dart';
import 'add_edit_customer_screen.dart';
import 'customer_detail_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final locale = context.watch<LocaleProvider>();
    final customers = customerProvider.filteredCustomers;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('customers_title')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
          );
        },
        icon: const Icon(Icons.person_add),
        label: Text(locale.translate('add_customer'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Total Outstanding Credit Banner
          if (customerProvider.totalCreditDue > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet, color: AppColors.danger, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Customer Credit Due',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.danger),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                CurrencyFormatter.format(customerProvider.totalCreditDue),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.danger),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${customerProvider.customersWithDues.length} customers',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => customerProvider.setSearchQuery(v),
              decoration: InputDecoration(
                hintText: 'Search customer name, phone, or vehicle #...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          customerProvider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          const Divider(height: 1),

          // Customers List
          Expanded(
            child: customerProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : customers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(locale.translate('no_data'), style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 6),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final cust = customers[index];

                          return Card(
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomerDetailScreen(customerId: cust.id),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                                child: Text(
                                  cust.name.isNotEmpty ? cust.name[0].toUpperCase() : 'C',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                              title: Text(
                                cust.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (cust.vehicleNumber.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.directions_car, size: 13, color: AppColors.textSecondaryLight),
                                        const SizedBox(width: 4),
                                        Text(
                                          cust.vehicleNumber,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentDark),
                                        ),
                                      ],
                                    ),
                                  Text('Phone: ${cust.phone}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (cust.pendingBalance > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.dangerLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Due: ${CurrencyFormatter.format(cust.pendingBalance)}',
                                        style: const TextStyle(
                                          color: AppColors.danger,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    )
                                  else
                                    const Text('No Dues', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${cust.invoiceCount} orders',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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
