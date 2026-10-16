import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../models/supplier_model.dart';
import '../../providers/purchase_provider.dart';

class SupplierListScreen extends StatelessWidget {
  const SupplierListScreen({super.key});

  void _showAddEditSupplierDialog(BuildContext context, [SupplierModel? supplier]) {
    final nameCtrl = TextEditingController(text: supplier?.name ?? '');
    final companyCtrl = TextEditingController(text: supplier?.company ?? '');
    final phoneCtrl = TextEditingController(text: supplier?.phone ?? '');
    final emailCtrl = TextEditingController(text: supplier?.email ?? '');
    final gstinCtrl = TextEditingController(text: supplier?.gstin ?? '');
    final addressCtrl = TextEditingController(text: supplier?.address ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(supplier == null ? 'Add New Supplier' : 'Edit Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Contact Person Name *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: companyCtrl,
                decoration: const InputDecoration(labelText: 'Company / Business Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: gstinCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Supplier GSTIN'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(labelText: 'City / Address'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;

              final sup = SupplierModel(
                id: supplier?.id ?? '',
                name: nameCtrl.text.trim(),
                company: companyCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                gstin: gstinCtrl.text.trim().toUpperCase(),
                address: addressCtrl.text.trim(),
                createdAt: supplier?.createdAt,
              );

              final provider = context.read<PurchaseProvider>();
              if (supplier == null) {
                await provider.addSupplier(sup);
              } else {
                await provider.updateSupplier(sup);
              }

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Supplier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseProvider = context.watch<PurchaseProvider>();
    final locale = context.watch<LocaleProvider>();
    final suppliers = purchaseProvider.suppliers;

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('suppliers')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAddEditSupplierDialog(context),
        icon: const Icon(Icons.add),
        label: Text(locale.translate('add_supplier')),
      ),
      body: suppliers.isEmpty
          ? const Center(child: Text('No suppliers added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final sup = suppliers[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.business, color: Colors.white),
                    ),
                    title: Text(sup.company.isNotEmpty ? sup.company : sup.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact: ${sup.name}  •  Ph: ${sup.phone}'),
                        if (sup.gstin.isNotEmpty)
                          Text('GSTIN: ${sup.gstin}', style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                        if (sup.address.isNotEmpty)
                          Text(sup.address, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _showAddEditSupplierDialog(context, sup),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
