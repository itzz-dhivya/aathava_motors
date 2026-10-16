import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../models/part_model.dart';
import '../../models/category_model.dart';
import '../../providers/inventory_provider.dart';
import 'barcode_scanner_screen.dart';

class AddEditPartScreen extends StatefulWidget {
  final PartModel? part;

  const AddEditPartScreen({super.key, this.part});

  @override
  State<AddEditPartScreen> createState() => _AddEditPartScreenState();
}

class _AddEditPartScreenState extends State<AddEditPartScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _partNumberController;
  late final TextEditingController _brandController;
  late final TextEditingController _hsnCodeController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _minStockController;
  late final TextEditingController _barcodeController;

  late String _category;
  late double _gstRate;
  late String _unit;
  late bool _isGstInclusive;

  final List<double> _gstRates = [0.0, 5.0, 12.0, 18.0, 28.0];
  final List<String> _units = ['Pcs', 'Set', 'Kit', 'Box', 'Ltr', 'Can', 'Bottle', 'Pair', 'Meter'];

  @override
  void initState() {
    super.initState();
    final p = widget.part;
    _nameController = TextEditingController(text: p?.name ?? '');
    _partNumberController = TextEditingController(text: p?.partNumber ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _hsnCodeController = TextEditingController(text: p?.hsnCode ?? '8708');
    _purchasePriceController = TextEditingController(text: p != null ? p.purchasePrice.toString() : '');
    _sellingPriceController = TextEditingController(text: p != null ? p.sellingPrice.toString() : '');
    _stockController = TextEditingController(text: p != null ? p.stockQuantity.toString() : '10');
    _minStockController = TextEditingController(text: p != null ? p.minStockAlert.toString() : '5');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');

    _category = p?.category ?? CategoryModel.defaultCategories.first.name;
    _gstRate = p?.gstRate ?? 18.0;
    _unit = p?.unit ?? 'Pcs';
    _isGstInclusive = p?.isGstInclusive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _partNumberController.dispose();
    _brandController.dispose();
    _hsnCodeController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  void _scanBarcode() async {
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scanned != null && scanned.isNotEmpty) {
      setState(() {
        _barcodeController.text = scanned;
      });
    }
  }

  void _savePart() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<InventoryProvider>();

    final double purchasePrice = double.tryParse(_purchasePriceController.text.trim()) ?? 0.0;
    final double sellingPrice = double.tryParse(_sellingPriceController.text.trim()) ?? 0.0;
    final double stock = double.tryParse(_stockController.text.trim()) ?? 0.0;
    final double minStock = double.tryParse(_minStockController.text.trim()) ?? 5.0;

    final partModel = PartModel(
      id: widget.part?.id ?? '',
      name: _nameController.text.trim(),
      partNumber: _partNumberController.text.trim(),
      brand: _brandController.text.trim(),
      hsnCode: _hsnCodeController.text.trim(),
      category: _category,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      gstRate: _gstRate,
      stockQuantity: stock,
      minStockAlert: minStock,
      unit: _unit,
      barcode: _barcodeController.text.trim(),
      isGstInclusive: _isGstInclusive,
      createdAt: widget.part?.createdAt,
    );

    if (widget.part == null) {
      await provider.addPart(partModel);
    } else {
      await provider.updatePart(partModel);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.part == null ? 'Spare part added successfully!' : 'Part updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isEditing = widget.part != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? locale.translate('edit_part') : locale.translate('add_part')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: locale.translate('save'),
            onPressed: _savePart,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Part Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '${locale.translate('part_name')} *',
                      prefixIcon: const Icon(Icons.settings_suggest_outlined),
                      hintText: 'e.g. Front Brake Pads Ceramic',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter part name' : null,
                  ),
                  const SizedBox(height: 14),

                  // Part Number
                  TextFormField(
                    controller: _partNumberController,
                    decoration: InputDecoration(
                      labelText: '${locale.translate('part_number')} *',
                      prefixIcon: const Icon(Icons.tag),
                      hintText: 'e.g. BP-HYU-01',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter part number' : null,
                  ),
                  const SizedBox(height: 14),

                  // Brand
                  TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      labelText: locale.translate('brand'),
                      prefixIcon: const Icon(Icons.branding_watermark_outlined),
                      hintText: 'e.g. Bosch, TVS, Shell, Castrol',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Category
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: locale.translate('category'),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: CategoryModel.defaultCategories.map((c) {
                      return DropdownMenuItem(
                        value: c.name,
                        child: Text(c.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // HSN Code
                  TextFormField(
                    controller: _hsnCodeController,
                    decoration: InputDecoration(
                      labelText: locale.translate('hsn_code'),
                      prefixIcon: const Icon(Icons.numbers),
                      hintText: 'e.g. 8708',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pricing Section Card
                  Card(
                    color: AppColors.surfaceLight,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pricing & Taxes',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _purchasePriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: locale.translate('purchase_price'),
                              prefixIcon: const Icon(Icons.currency_rupee),
                              hintText: 'e.g. 1200',
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter cost price' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _sellingPriceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: '${locale.translate('selling_price')} *',
                              prefixIcon: const Icon(Icons.sell_outlined),
                              hintText: 'e.g. 1500',
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Enter selling price' : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<double>(
                            initialValue: _gstRate,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: locale.translate('gst_rate'),
                              prefixIcon: const Icon(Icons.percent),
                            ),
                            items: _gstRates.map((rate) {
                              return DropdownMenuItem(
                                value: rate,
                                child: Text('${rate.toStringAsFixed(0)}% GST'),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _gstRate = v);
                            },
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Price includes GST', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            value: _isGstInclusive,
                            activeThumbColor: AppColors.primary,
                            onChanged: (val) => setState(() => _isGstInclusive = val),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Stock Quantity
                  TextFormField(
                    controller: _stockController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: '${locale.translate('stock_qty')} *',
                      prefixIcon: const Icon(Icons.inventory_2_outlined),
                      hintText: 'e.g. 10',
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Enter current stock' : null,
                  ),
                  const SizedBox(height: 14),

                  // Unit
                  DropdownButtonFormField<String>(
                    initialValue: _unit,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: locale.translate('unit'),
                      prefixIcon: const Icon(Icons.straighten_outlined),
                    ),
                    items: _units.map((u) {
                      return DropdownMenuItem(value: u, child: Text(u));
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _unit = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Low Stock Alert Threshold
                  TextFormField(
                    controller: _minStockController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: locale.translate('min_stock_alert'),
                      prefixIcon: const Icon(Icons.warning_amber_outlined),
                      helperText: 'Alert badge shows when stock falls to this number or lower',
                      hintText: 'e.g. 2',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Barcode / QR Field with Scanner Icon
                  TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(
                      labelText: locale.translate('barcode'),
                      prefixIcon: const Icon(Icons.qr_code),
                      hintText: 'e.g. 8901234001',
                      suffixIcon: IconButton(
                        onPressed: _scanBarcode,
                        icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                        tooltip: locale.translate('scan_barcode'),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: _savePart,
                    icon: const Icon(Icons.save),
                    label: Text(
                      isEditing ? 'Update Spare Part' : 'Save Spare Part to Inventory',
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
