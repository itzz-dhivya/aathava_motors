import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/purchase_provider.dart';
import 'new_purchase_screen.dart';
import 'supplier_list_screen.dart';

class PurchaseListScreen extends StatelessWidget {
  const PurchaseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = context.watch<PurchaseProvider>();
    final locale = context.watch<LocaleProvider>();
    final purchases = purchaseProvider.purchases;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('purchases_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: locale.translate('suppliers'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupplierListScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewPurchaseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(locale.translate('add_purchase')),
      ),
      body: Column(
        children: [
          // Total Purchases Banner
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Purchase Outlay', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(purchaseProvider.totalPurchasesAmount),
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupplierListScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('Suppliers Hub'),
                ),
              ],
            ),
          ),

          // Purchases List
          Expanded(
            child: purchaseProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : purchases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 56, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('No purchase entries yet.'),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "+ New Purchase Entry" to receive spare parts stock.',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 4),
                        itemCount: purchases.length,
                        itemBuilder: (context, index) {
                          final p = purchases[index];

                          return Card(
                            child: ExpansionTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Bill: ${p.purchaseInvoiceNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    CurrencyFormatter.format(p.totalAmount),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Supplier: ${p.supplierName}'),
                                  Text(DateFormatter.formatWithTime(p.date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              children: [
                                const Divider(height: 1),
                                ...p.items.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${item.partName} (${item.quantity} ${item.unit})',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            CurrencyFormatter.format(item.totalAmount),
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    )),
                                if (p.notes.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Notes: ${p.notes}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Colors.grey)),
                                    ),
                                  ),
                              ],
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
