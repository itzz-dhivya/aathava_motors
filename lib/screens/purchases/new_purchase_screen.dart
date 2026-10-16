import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/part_model.dart';
import '../../models/purchase_model.dart';
import '../../models/supplier_model.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/purchase_provider.dart';

class NewPurchaseScreen extends StatefulWidget {
  const NewPurchaseScreen({super.key});

  @override
  State<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumController = TextEditingController();
  final _notesController = TextEditingController();

  SupplierModel? _selectedSupplier;
  final List<PurchaseItemModel> _items = [];

  @override
  void dispose() {
    _invoiceNumController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    final inventory = context.read<InventoryProvider>();
    PartModel? selectedPart;
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Part to Purchase Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<PartModel>(
                    initialValue: selectedPart,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Select Spare Part'),
                    items: inventory.allParts.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text('${p.name} (${p.partNumber})', overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedPart = val;
                          priceCtrl.text = val.purchasePrice.toString();
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Purchase / Cost Price',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Received Quantity',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (selectedPart == null) return;
                  final price = double.tryParse(priceCtrl.text.trim()) ?? selectedPart!.purchasePrice;
                  final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1.0;
                  final total = price * qty;

                  setState(() {
                    _items.add(PurchaseItemModel(
                      id: 'pitem_${DateTime.now().millisecondsSinceEpoch}',
                      partId: selectedPart!.id,
                      partName: selectedPart!.name,
                      partNumber: selectedPart!.partNumber,
                      unit: selectedPart!.unit,
                      purchasePrice: price,
                      quantity: qty,
                      gstRate: selectedPart!.gstRate,
                      totalAmount: total,
                    ));
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Add to Entry'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one spare part')),
      );
      return;
    }

    final total = _items.fold(0.0, (sum, i) => sum + i.totalAmount);

    await context.read<PurchaseProvider>().addPurchaseEntry(
          purchaseInvoiceNumber: _invoiceNumController.text.trim(),
          supplier: _selectedSupplier!,
          items: _items,
          totalAmount: total,
          notes: _notesController.text.trim(),
        );

    // Reload inventory so new stock levels show up immediately
    if (!mounted) return;
    await context.read<InventoryProvider>().loadParts();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Purchase recorded! Stock quantities have been updated in inventory.'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = context.watch<PurchaseProvider>();
    final locale = context.watch<LocaleProvider>();
    final suppliers = purchaseProvider.suppliers;

    final totalAmount = _items.fold(0.0, (sum, i) => sum + i.totalAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('add_purchase')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _savePurchase,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Supplier & Bill Number
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Supplier Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<SupplierModel>(
                            initialValue: _selectedSupplier,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: '${locale.translate('supplier_name')} *',
                              prefixIcon: const Icon(Icons.business),
                            ),
                            items: suppliers.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(
                                  '${s.name} (${s.company})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedSupplier = val),
                            validator: (v) => v == null ? 'Please select a supplier' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _invoiceNumController,
                            decoration: InputDecoration(
                              labelText: '${locale.translate('purchase_bill_no')} *',
                              prefixIcon: const Icon(Icons.receipt),
                              hintText: 'e.g. TVS-PUR-8901',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter supplier invoice #' : null,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Items List Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Received Stock Items (${_items.length})',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _showAddItemDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Item'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (_items.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              alignment: Alignment.center,
                              child: const Text('No items added yet. Tap "+ Add Item" above.'),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, idx) {
                                final item = _items[idx];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    item.partName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text('${item.quantity} ${item.unit} @ ₹${item.purchasePrice}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(CurrencyFormatter.format(item.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                        onPressed: () => setState(() => _items.removeAt(idx)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          if (_items.isNotEmpty) ...[
                            const Divider(thickness: 1.5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Total Purchase Cost:',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  CurrencyFormatter.format(totalAmount),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Notes (Optional)',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      hintText: 'e.g. Batch #445 from Padi warehouse',
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _savePurchase,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Save Purchase & Update Stock (${CurrencyFormatter.format(totalAmount)})',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
