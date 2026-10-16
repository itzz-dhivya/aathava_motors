import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../home/home_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedState = 'Tamil Nadu';

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
    'Rajasthan',
    'West Bengal',
    'Other State',
  ];

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.registerShop(
      shopName: _shopNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gstin: _gstinController.text.trim().toUpperCase(),
      address: _addressController.text.trim(),
      state: _selectedState,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shop registered successfully! Welcome to AutoSpare Pro.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
        (route) => false,
      );
    } else if (auth.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(locale.translate('register')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Setup Your Spare Parts Shop',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure your business details for GST billing and inventory management.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),

                    // Shop Name
                    TextFormField(
                      controller: _shopNameController,
                      decoration: InputDecoration(
                        labelText: '${locale.translate('shop_name')} *',
                        prefixIcon: const Icon(Icons.storefront_outlined),
                        hintText: 'e.g. Royal Auto Spares & Accessories',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter shop name' : null,
                    ),
                    const SizedBox(height: 14),

                    // Owner Name
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(
                        labelText: '${locale.translate('owner_name')} *',
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: 'e.g. R. Rajesh',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter owner name' : null,
                    ),
                    const SizedBox(height: 14),

                    // Phone and Email Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: '${locale.translate('phone')} *',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              hintText: '9840012345',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter phone number' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: '${locale.translate('email')} *',
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (v) => (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: '${locale.translate('password')} *',
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 14),

                    // GSTIN
                    TextFormField(
                      controller: _gstinController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: '${locale.translate('gstin')} *',
                        prefixIcon: const Icon(Icons.receipt_long_outlined),
                        hintText: 'e.g. 33AABCA1234F1Z8',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter GSTIN' : null,
                    ),
                    const SizedBox(height: 14),

                    // State Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedState,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: '${locale.translate('state')} *',
                        prefixIcon: const Icon(Icons.map_outlined),
                      ),
                      items: _indianStates.map((state) {
                        return DropdownMenuItem(
                          value: state,
                          child: Text(state, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedState = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: '${locale.translate('address')} *',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        hintText: 'Shop street, locality, city and pincode',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter shop address' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              locale.translate('register'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
