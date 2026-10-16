import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _ownerNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _gstinCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _upiIdCtrl;
  late final TextEditingController _termsCtrl;
  late String _state;

  final List<String> _indianStates = [
    'Tamil Nadu',
    'Kerala',
    'Karnataka',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Gujarat',
    'Delhi',
    'Uttar Pradesh',
    'West Bengal',
    'Other State',
  ];

  @override
  void initState() {
    super.initState();
    final shop = context.read<SettingsProvider>().shop;
    _shopNameCtrl = TextEditingController(text: shop.shopName);
    _ownerNameCtrl = TextEditingController(text: shop.ownerName);
    _phoneCtrl = TextEditingController(text: shop.phone);
    _emailCtrl = TextEditingController(text: shop.email);
    _gstinCtrl = TextEditingController(text: shop.gstin);
    _addressCtrl = TextEditingController(text: shop.address);
    _upiIdCtrl = TextEditingController(text: shop.upiId);
    _termsCtrl = TextEditingController(text: shop.termsAndConditions);
    _state = shop.state;
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _gstinCtrl.dispose();
    _addressCtrl.dispose();
    _upiIdCtrl.dispose();
    _termsCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<SettingsProvider>();
    final current = provider.shop;

    final updated = current.copyWith(
      shopName: _shopNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gstin: _gstinCtrl.text.trim().toUpperCase(),
      address: _addressCtrl.text.trim(),
      state: _state,
      upiId: _upiIdCtrl.text.trim(),
      termsAndConditions: _termsCtrl.text.trim(),
    );

    await provider.updateShopProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('shop_profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _shopNameCtrl,
                    decoration: InputDecoration(
                      labelText: '${locale.translate('shop_name')} *',
                      prefixIcon: const Icon(Icons.storefront),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _ownerNameCtrl,
                    decoration: InputDecoration(
                      labelText: '${locale.translate('owner_name')} *',
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: '${locale.translate('phone')} *',
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: locale.translate('email'),
                            prefixIcon: const Icon(Icons.email),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _gstinCtrl,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: '${locale.translate('gstin')} *',
                            prefixIcon: const Icon(Icons.receipt_long),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _state,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: locale.translate('state'),
                            prefixIcon: const Icon(Icons.map),
                          ),
                          items: _indianStates.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _state = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _addressCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: '${locale.translate('address')} *',
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _upiIdCtrl,
                    decoration: InputDecoration(
                      labelText: locale.translate('upi_id'),
                      prefixIcon: const Icon(Icons.qr_code_2),
                      hintText: 'e.g. autozonespares@okaxis',
                      helperText: 'Enables instant UPI QR code on printed and shared invoices',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _termsCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: locale.translate('terms_conditions'),
                      prefixIcon: const Icon(Icons.rule),
                      helperText: 'Printed at the bottom of all customer invoices',
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Shop Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
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
