import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _vehicleController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstinController;
  String _selectedState = 'Tamil Nadu';

  final List<String> _states = [
    'Tamil Nadu',
    'Kerala',
    'Karnataka',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Gujarat',
    'Delhi',
    'Other State',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _vehicleController = TextEditingController(text: c?.vehicleNumber ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _gstinController = TextEditingController(text: c?.gstin ?? '');
    _selectedState = c?.state ?? 'Tamil Nadu';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CustomerProvider>();
    final customer = CustomerModel(
      id: widget.customer?.id ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      vehicleNumber: _vehicleController.text.trim().toUpperCase(),
      address: _addressController.text.trim(),
      state: _selectedState,
      gstin: _gstinController.text.trim().toUpperCase(),
      pendingBalance: widget.customer?.pendingBalance ?? 0.0,
      totalPurchases: widget.customer?.totalPurchases ?? 0.0,
      invoiceCount: widget.customer?.invoiceCount ?? 0,
      createdAt: widget.customer?.createdAt,
    );

    if (widget.customer == null) {
      await provider.addCustomer(customer);
    } else {
      await provider.updateCustomer(customer);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.customer == null ? 'Customer added successfully!' : 'Customer updated!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? locale.translate('edit_customer') : locale.translate('add_customer')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveCustomer,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '${locale.translate('customer_name')} *',
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: 'e.g. Suresh Auto Garage / Rajesh',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter customer name' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: '${locale.translate('customer_phone')} *',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      hintText: '9840123456',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _vehicleController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: locale.translate('vehicle_number'),
                      prefixIcon: const Icon(Icons.directions_car_outlined),
                      hintText: 'e.g. TN-07-CM-4589',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _gstinController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: locale.translate('customer_gstin'),
                      prefixIcon: const Icon(Icons.receipt_outlined),
                      hintText: 'Optional for B2B garage/fleets',
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: locale.translate('state'),
                      prefixIcon: const Icon(Icons.map_outlined),
                    ),
                    items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedState = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: locale.translate('customer_address'),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      hintText: 'Street, area or workshop address',
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _saveCustomer,
                    icon: const Icon(Icons.save),
                    label: Text(
                      isEditing ? 'Update Customer' : 'Save Customer',
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
