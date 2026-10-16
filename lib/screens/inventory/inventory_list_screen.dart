import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/category_model.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/billing_provider.dart';
import 'add_edit_part_screen.dart';
import 'part_detail_screen.dart';
import 'barcode_scanner_screen.dart';
import 'stock_history_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scanBarcode() async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scanned != null && scanned.isNotEmpty) {
      _searchController.text = scanned;
      if (mounted) {
        context.read<InventoryProvider>().setSearchQuery(scanned);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final locale = context.watch<LocaleProvider>();
    final billing = context.read<BillingProvider>();

    final parts = inventory.filteredParts;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('inventory_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: locale.translate('stock_history'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StockHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: locale.translate('scan_barcode'),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFFEA580C),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPartScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(locale.translate('add_part'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Scanner Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => inventory.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Search by part name, part #, brand...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                inventory.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),

          // Filters row: Category Chips + Low Stock Chip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                // Low Stock Filter Toggle Chip
                FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.danger),
                      const SizedBox(width: 4),
                      Text('Low Stock (${inventory.lowStockCount})'),
                    ],
                  ),
                  selected: inventory.showOnlyLowStock,
                  selectedColor: AppColors.dangerLight,
                  onSelected: (_) => inventory.toggleLowStockFilter(),
                ),
                const SizedBox(width: 8),

                // 'All' Category Chip
                ChoiceChip(
                  label: const Text('All'),
                  selected: inventory.selectedCategory == 'All',
                  onSelected: (sel) {
                    if (sel) inventory.setCategory('All');
                  },
                ),
                const SizedBox(width: 6),

                // Predefined Categories
                ...CategoryModel.defaultCategories.map((cat) {
                  final isSel = inventory.selectedCategory == cat.name;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      avatar: Icon(cat.icon, size: 14, color: isSel ? Colors.white : cat.color),
                      label: Text(locale.isTamil ? cat.nameTamil : cat.name),
                      selected: isSel,
                      onSelected: (sel) {
                        inventory.setCategory(sel ? cat.name : 'All');
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 12),

          // Parts List View
          Expanded(
            child: inventory.isLoading
                ? const Center(child: CircularProgressIndicator())
                : parts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 56, color: AppColors.textSecondaryLight),
                            const SizedBox(height: 12),
                            Text(locale.translate('no_data'), style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                inventory.setSearchQuery('');
                                inventory.setCategory('All');
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filters'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80, top: 4),
                        itemCount: parts.length,
                        itemBuilder: (context, index) {
                          final part = parts[index];
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PartDetailScreen(partId: part.id),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Stock & Category Indicator Badge
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: part.isOutOfStock
                                            ? AppColors.dangerLight
                                            : (part.isLowStock ? AppColors.warningLight : AppColors.primaryLight.withValues(alpha: 0.12)),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            part.isLowStock ? Icons.warning_amber : Icons.inventory_2,
                                            size: 20,
                                            color: part.isOutOfStock
                                                ? AppColors.danger
                                                : (part.isLowStock ? AppColors.accentDark : AppColors.primary),
                                          ),
                                          Text(
                                            '${part.stockQuantity.toInt()}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: part.isOutOfStock
                                                  ? AppColors.danger
                                                  : (part.isLowStock ? AppColors.accentDark : AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Part Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            part.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Part #: ${part.partNumber}  •  ${part.brand}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondaryLight,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceElevatedLight,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '${part.gstRate.toInt()}% GST',
                                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Stock: ${part.stockQuantity} ${part.unit}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: part.isLowStock ? AppColors.danger : AppColors.textSecondaryLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Price & Add to Bill Button
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          CurrencyFormatter.format(part.sellingPrice),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        IconButton.filledTonal(
                                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                                          tooltip: 'Add to Bill',
                                          style: IconButton.styleFrom(
                                            padding: const EdgeInsets.all(6),
                                          ),
                                          onPressed: () {
                                            billing.addToCart(part);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${part.name} added to cart!'),
                                                duration: const Duration(seconds: 1),
                                                backgroundColor: AppColors.primary,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
