import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/billing_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../inventory/barcode_scanner_screen.dart';
import 'invoice_preview_screen.dart';

class NewBillScreen extends StatefulWidget {
  const NewBillScreen({super.key});

  @override
  State<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends State<NewBillScreen> {
  final TextEditingController _itemSearchController = TextEditingController();
  final TextEditingController _walkInNameController = TextEditingController(text: 'Walk-in Customer');
  final TextEditingController _walkInPhoneController = TextEditingController();
  final TextEditingController _walkInVehicleController = TextEditingController();
  final TextEditingController _billDiscountController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _itemSearchController.dispose();
    _walkInNameController.dispose();
    _walkInPhoneController.dispose();
    _walkInVehicleController.dispose();
    _billDiscountController.dispose();
    _paidAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _scanBarcodeToAdd() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || barcode == null || barcode.isEmpty) return;

    final part = await context.read<InventoryProvider>().findByBarcode(barcode);
    if (!mounted) return;

    if (part != null) {
      context.read<BillingProvider>().addToCart(part);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ${part.name} to cart!'), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No spare part found with barcode: $barcode'), backgroundColor: AppColors.warning),
      );
    }
  }

  void _showAddItemPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final parts = ctx.watch<InventoryProvider>().allParts.where((p) {
              if (filter.isEmpty) return true;
              final q = filter.toLowerCase();
              return p.name.toLowerCase().contains(q) ||
                  p.partNumber.toLowerCase().contains(q) ||
                  p.brand.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Spare Part',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search by part name or part #...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) => setModalState(() => filter = val),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: parts.length,
                          itemBuilder: (context, idx) {
                            final part = parts[idx];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                                child: Text('${part.stockQuantity.toInt()}'),
                              ),
                              title: Text(part.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${part.partNumber} • ${part.brand} • ${part.gstRate}% GST'),
                              trailing: Text(
                                CurrencyFormatter.format(part.sellingPrice),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onTap: () {
                                ctx.read<BillingProvider>().addToCart(part);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCustomerPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final customers = ctx.watch<CustomerProvider>().allCustomers.where((c) {
              if (filter.isEmpty) return true;
              final q = filter.toLowerCase();
              return c.name.toLowerCase().contains(q) ||
                  c.phone.toLowerCase().contains(q) ||
                  c.vehicleNumber.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Select Customer',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search by customer name, phone, or vehicle #...',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) => setModalState(() => filter = val),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: customers.length,
                          itemBuilder: (context, idx) {
                            final cust = customers[idx];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Vehicle: ${cust.vehicleNumber}  •  Ph: ${cust.phone}'),
                              trailing: cust.pendingBalance > 0
                                  ? Text(
                                      'Due: ${CurrencyFormatter.format(cust.pendingBalance)}',
                                      style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                                    )
                                  : null,
                              onTap: () {
                                ctx.read<BillingProvider>().selectCustomer(cust);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showItemEditDialog(int index, CartItem item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(text: item.price.toString());
    final discCtrl = TextEditingController(text: item.discount.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit: ${item.part.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Quantity (${item.part.unit})',
                prefixIcon: const Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Selling Price',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: discCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Item Discount',
                prefixText: '₹ ',
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
            onPressed: () {
              final billing = context.read<BillingProvider>();
              final q = double.tryParse(qtyCtrl.text.trim()) ?? item.quantity;
              final p = double.tryParse(priceCtrl.text.trim()) ?? item.price;
              final d = double.tryParse(discCtrl.text.trim()) ?? item.discount;

              billing.updateCartItemQty(index, q);
              billing.updateCartItemPrice(index, p);
              billing.updateCartItemDiscount(index, d);
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleCheckout() async {
    final billing = context.read<BillingProvider>();
    final shop = context.read<SettingsProvider>().shop;
    final auth = context.read<AuthProvider>();

    if (billing.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one spare part to create bill!')),
      );
      return;
    }

    // Save walk-in details if walk-in
    if (billing.selectedCustomer == null) {
      billing.setWalkInDetails(
        name: _walkInNameController.text.trim(),
        phone: _walkInPhoneController.text.trim(),
        vehicle: _walkInVehicleController.text.trim(),
      );
    }

    final invoice = await billing.checkout(
      shop: shop,
      createdBy: auth.currentUser?.name ?? 'Staff',
    );

    if (invoice != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice ${invoice.invoiceNumber} created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InvoicePreviewScreen(invoice: invoice),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final locale = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('new_bill')),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: locale.translate('scan_barcode'),
            onPressed: _scanBarcodeToAdd,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Cart',
            onPressed: billing.cartItems.isNotEmpty ? () => billing.clearCart() : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Customer Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Customer Information',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showCustomerPicker,
                              icon: const Icon(Icons.person_search, size: 18),
                              label: Text(billing.selectedCustomer == null ? 'Select Customer' : 'Change'),
                            ),
                          ],
                        ),
                        if (billing.selectedCustomer != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevatedLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  child: Icon(Icons.person),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        billing.selectedCustomer!.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text('Vehicle: ${billing.selectedCustomer!.vehicleNumber}  •  Ph: ${billing.selectedCustomer!.phone}'),
                                      if (billing.selectedCustomer!.gstin.isNotEmpty)
                                        Text('GSTIN: ${billing.selectedCustomer!.gstin}', style: const TextStyle(color: AppColors.primary)),
                                      if (billing.selectedCustomer!.pendingBalance > 0)
                                        Text(
                                          'Previous Balance Due: ${CurrencyFormatter.format(billing.selectedCustomer!.pendingBalance)}',
                                          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => billing.selectCustomer(null),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Walk-in Inputs: 1 Line Per Input, Big and Clear with Detailed Hint Text
                          TextField(
                            controller: _walkInNameController,
                            style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              labelText: 'Customer / Client Name',
                              hintText: 'Enter customer name (e.g. Suresh Kumar / Sri Motors)',
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.person, color: Color(0xFF0F2B66)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F2B66), width: 1.8)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _walkInPhoneController,
                            keyboardType: TextInputType.phone,
                            style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              labelText: 'Customer Mobile Number',
                              hintText: 'Enter 10-digit mobile number (e.g. 94422 49149)',
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.phone, color: Color(0xFF0F2B66)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F2B66), width: 1.8)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _walkInVehicleController,
                            textCapitalization: TextCapitalization.characters,
                            style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              labelText: 'Vehicle Number & Model',
                              hintText: 'Enter vehicle number (e.g. TN-01-X-2943 - Hyundai Accent)',
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.directions_car, color: Color(0xFF0F2B66)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F2B66), width: 1.8)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Cart Items Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Bill Items (${billing.cartItems.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showAddItemPicker,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Part'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (billing.cartItems.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(30),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                const Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                const Text('Cart is empty', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text(
                                  'Tap "+ Add Part" or scan barcode to add spare parts.',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: billing.cartItems.length,
                            separatorBuilder: (context, index) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final item = billing.cartItems[index];
                              final lineTotal = item.price * item.quantity - item.discount;

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Quantity Stepper
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.borderLight),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () => billing.updateCartItemQty(index, item.quantity - 1),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.remove, size: 16),
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity.toInt()}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        InkWell(
                                          onTap: () => billing.updateCartItemQty(index, item.quantity + 1),
                                          child: const Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Icon(Icons.add, size: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Item Name & Details
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => _showItemEditDialog(index, item),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.part.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                          ),
                                          Text(
                                            'Part#: ${item.part.partNumber} • Rate: ₹${item.price} • GST: ${item.gstRate}%',
                                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                                          ),
                                          if (item.discount > 0)
                                            Text(
                                              'Disc: -₹${item.discount}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.success),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Line Total & Delete
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(lineTotal),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => billing.removeFromCart(index),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 3. GST Calculation & Pricing Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // Pricing Mode Switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text('Pricing Mode:', style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  billing.isGstInclusive ? 'GST Included' : 'GST Added (+ Tax)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: billing.isGstInclusive ? AppColors.primary : AppColors.accentDark,
                                  ),
                                ),
                                Switch(
                                  value: billing.isGstInclusive,
                                  onChanged: (val) => billing.toggleGstInclusive(val),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),

                        // Subtotal
                        _summaryRow('Taxable Amount:', CurrencyFormatter.format(billing.subtotalTaxable)),

                        // GST Split
                        if (!billing.isInterState) ...[
                          _summaryRow('CGST:', CurrencyFormatter.format(billing.cgstTotal)),
                          _summaryRow('SGST:', CurrencyFormatter.format(billing.sgstTotal)),
                        ] else ...[
                          _summaryRow('IGST (Inter-state):', CurrencyFormatter.format(billing.igstTotal)),
                        ],

                        _summaryRow('Total GST Tax:', CurrencyFormatter.format(billing.totalTax)),

                        // Discount: Full-width line with Big Input and Clear Hint
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TextField(
                            controller: _billDiscountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            decoration: InputDecoration(
                              labelText: 'Special Bill Discount (Optional)',
                              hintText: 'Enter discount in ₹ (e.g. 500)',
                              hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.discount_outlined, color: Color(0xFFD97706)),
                              prefixText: '₹ ',
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F2B66), width: 1.8)),
                            ),
                            onChanged: (v) {
                              final d = double.tryParse(v.trim()) ?? 0.0;
                              billing.setBillDiscount(d);
                            },
                          ),
                        ),

                        if (billing.roundOff != 0)
                          _summaryRow('Round Off:', billing.roundOff > 0 ? '+₹${billing.roundOff}' : '₹${billing.roundOff}'),

                        const Divider(thickness: 1.5),

                        // Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                locale.translate('grand_total'),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(billing.grandTotal),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Payment Mode & Partial Payment (Credit)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          children: ['Cash', 'UPI', 'Card', 'Credit'].map((mode) {
                            final isSel = billing.paymentMode == mode;
                            return ChoiceChip(
                              label: Text(mode),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (_) => billing.setPaymentMode(mode),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 12),

                        // Amount Received Input: Big Full-Width Input
                        TextField(
                          controller: _paidAmountController..text = billing.amountPaid > 0 ? billing.amountPaid.toString() : '',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            labelText: 'Actual Amount Received Today',
                            hintText: 'Enter amount paid (e.g. ${billing.grandTotal.toInt()})',
                            hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.payments_outlined, color: Color(0xFF059669)),
                            prefixText: '₹ ',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0F2B66), width: 1.8)),
                            helperText: 'Cash / UPI amount collected from customer now',
                            helperStyle: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                          ),
                          onChanged: (v) {
                            final paid = double.tryParse(v.trim()) ?? 0.0;
                            billing.setAmountPaid(paid);
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: billing.balanceDue > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: billing.balanceDue > 0 ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      billing.balanceDue > 0 ? 'Balance (Credit Due)' : 'Payment Status: Full Paid',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: billing.balanceDue > 0 ? AppColors.danger : AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      billing.balanceDue > 0 ? 'Added to customer credit ledger' : 'No balance due on this invoice',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                CurrencyFormatter.format(billing.balanceDue),
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: billing.balanceDue > 0 ? AppColors.danger : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (billing.balanceDue > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '⚠️ ${CurrencyFormatter.format(billing.balanceDue)} will be recorded under customer credit ledger.',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.accentDark, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Checkout Button
                ElevatedButton.icon(
                  onPressed: billing.cartItems.isEmpty ? null : _handleCheckout,
                  icon: const Icon(Icons.receipt_long),
                  label: Text(
                    'Generate Invoice (${CurrencyFormatter.format(billing.grandTotal)})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
