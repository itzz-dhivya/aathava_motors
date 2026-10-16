import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/part_model.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';
import 'add_edit_part_screen.dart';
import 'stock_history_screen.dart';

class PartDetailScreen extends StatelessWidget {
  final String partId;

  const PartDetailScreen({super.key, required this.partId});

  void _showAdjustStockDialog(BuildContext context, PartModel part) {
    final qtyController = TextEditingController();
    final reasonController = TextEditingController();
    bool isAddition = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Adjust Stock Quantity'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Add Stock (+)'),
                        selected: isAddition,
                        selectedColor: AppColors.successLight,
                        onSelected: (val) => setDialogState(() => isAddition = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Reduce (-)'),
                        selected: !isAddition,
                        selectedColor: AppColors.dangerLight,
                        onSelected: (val) => setDialogState(() => isAddition = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Quantity to ${isAddition ? 'Add' : 'Deduct'}',
                    prefixIcon: Icon(isAddition ? Icons.add_circle_outline : Icons.remove_circle_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason / Note',
                    hintText: 'e.g. Physical inventory check, Damaged, etc.',
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
                  final qty = double.tryParse(qtyController.text.trim()) ?? 0.0;
                  if (qty <= 0) return;

                  final delta = isAddition ? qty : -qty;
                  await context.read<InventoryProvider>().adjustStock(
                        partId: part.id,
                        quantityDelta: delta,
                        reason: reasonController.text.trim(),
                      );

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Confirm Adjustment'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, PartModel part) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Spare Part?'),
        content: Text('Are you sure you want to delete "${part.name}" from your catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              await context.read<InventoryProvider>().deletePart(part.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();

    final part = inventory.allParts.firstWhere(
      (p) => p.id == partId,
      orElse: () => PartModel(
        id: '',
        name: 'Not Found',
        partNumber: '',
        brand: '',
        hsnCode: '',
        category: '',
        purchasePrice: 0,
        sellingPrice: 0,
        stockQuantity: 0,
      ),
    );

    if (part.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Part Details')),
        body: const Center(child: Text('Spare part record not found')),
      );
    }

    final profitMargin = part.purchasePrice > 0
        ? (((part.sellingPrice - part.purchasePrice) / part.purchasePrice) * 100)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(part.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: locale.translate('edit'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddEditPartScreen(part: part)),
              );
            },
          ),
          if (auth.isOwner)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: locale.translate('delete'),
              onPressed: () => _confirmDelete(context, part),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Card with Part Identity & Stock Status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    part.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Part #: ${part.partNumber}  •  Brand: ${part.brand.isNotEmpty ? part.brand : 'Generic'}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                                  ),
                                  Text(
                                    'Category: ${part.category}  •  HSN: ${part.hsnCode}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                                  ),
                                ],
                              ),
                            ),
                            // Stock Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: part.isOutOfStock
                                    ? AppColors.dangerLight
                                    : (part.isLowStock ? AppColors.warningLight : AppColors.successLight),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                part.isOutOfStock
                                    ? 'Out of Stock'
                                    : (part.isLowStock ? 'Low Stock' : 'In Stock'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: part.isOutOfStock
                                      ? AppColors.danger
                                      : (part.isLowStock ? AppColors.accentDark : AppColors.success),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Stock Count Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Current In-Stock Quantity:', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                                Text(
                                  '${part.stockQuantity} ${part.unit}',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAdjustStockDialog(context, part),
                              icon: const Icon(Icons.sync_alt, size: 16),
                              label: const Text('Adjust Stock'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Pricing & Margin Breakdown Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Commercial & Tax Details',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _infoRow('Selling Price (Retail):', CurrencyFormatter.format(part.sellingPrice), isBold: true),
                        if (auth.isOwner)
                          _infoRow('Purchase Price (Cost):', CurrencyFormatter.format(part.purchasePrice)),
                        _infoRow('GST Rate Applied:', '${part.gstRate.toStringAsFixed(0)}% (${part.isGstInclusive ? 'Inclusive' : 'Exclusive'})'),
                        if (auth.isOwner)
                          _infoRow(
                            'Estimated Margin:',
                            '${profitMargin.toStringAsFixed(1)}% (₹ ${(part.sellingPrice - part.purchasePrice).toStringAsFixed(2)})',
                            color: profitMargin > 0 ? AppColors.success : AppColors.danger,
                          ),
                        if (part.barcode.isNotEmpty)
                          _infoRow('Barcode / QR Code:', part.barcode),
                        _infoRow('Low Stock Alert At:', '<= ${part.minStockAlert} ${part.unit}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // View Stock History Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StockHistoryScreen(partId: part.id, partName: part.name),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View Complete Stock Movement Log'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color ?? AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
