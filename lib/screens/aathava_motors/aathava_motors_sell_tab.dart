import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/enquiry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/enquiry_provider.dart';

class AathavaMotorsSellTab extends StatefulWidget {
  final VoidCallback? onValuationSuccess;

  const AathavaMotorsSellTab({super.key, this.onValuationSuccess});

  @override
  State<AathavaMotorsSellTab> createState() => _AathavaMotorsSellTabState();
}

class _AathavaMotorsSellTabState extends State<AathavaMotorsSellTab> {
  final _formKey = GlobalKey<FormState>();
  String _vehicleType = 'car';
  final _modelCtrl = TextEditingController(text: 'Hyundai Accent 1.6 SX');
  final _regNoCtrl = TextEditingController(text: 'TN 38 BK 9021');
  final _yearCtrl = TextEditingController(text: '2019');
  final _kmCtrl = TextEditingController(text: '52000');
  final _priceCtrl = TextEditingController(text: '475000');
  String _fuelType = 'Petrol';
  final _phoneCtrl = TextEditingController(text: '89517 77054');
  final _nameCtrl = TextEditingController(text: 'Mr. Sathish Kumar');

  @override
  void dispose() {
    _modelCtrl.dispose();
    _regNoCtrl.dispose();
    _yearCtrl.dispose();
    _kmCtrl.dispose();
    _priceCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  double get _estimatedMinPrice {
    final exp = double.tryParse(_priceCtrl.text) ?? 400000;
    return exp * 0.94;
  }

  double get _estimatedMaxPrice {
    final exp = double.tryParse(_priceCtrl.text) ?? 400000;
    return exp * 1.04;
  }

  void _submitValuation() {
    if (!_formKey.currentState!.validate()) return;

    final enquiry = EnquiryModel(
      id: 'val-${DateTime.now().millisecondsSinceEpoch}',
      enquiryType: 'sell_valuation',
      title: 'Free Valuation: ${_yearCtrl.text} ${_modelCtrl.text}',
      subtitle: '${_vehicleType == "car" ? "🚗 Car" : "🏍️ Bike"} • Reg: ${_regNoCtrl.text} • Exp: ₹${_priceCtrl.text}',
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      date: DateTime.now(),
      status: 'pending',
      notes: 'Fuel: $_fuelType, KM: ${_kmCtrl.text}. Est. Range: ${CurrencyFormatter.format(_estimatedMinPrice)} - ${CurrencyFormatter.format(_estimatedMaxPrice)}',
    );

    context.read<EnquiryProvider>().addEnquiry(enquiry);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(22),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 48),
              ),
              const SizedBox(height: 14),
              Text(
                'Valuation Request Sent!',
                style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Estimated Cash Offer Range:\n${CurrencyFormatter.format(_estimatedMinPrice)} - ${CurrencyFormatter.format(_estimatedMaxPrice)}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF059669),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Aathava Motors inspection team will call ${_phoneCtrl.text} within 30 minutes for doorstep evaluation & instant bank settlement.',
                style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF25D366),
                        side: const BorderSide(color: Color(0xFF25D366)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final msg = 'Hello Aathava Motors, I submitted my ${_modelCtrl.text} (${_regNoCtrl.text}) for free valuation. Here are the details!';
                        final uri = Uri.parse('https://wa.me/918951777054?text=${Uri.encodeComponent(msg)}');
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                      label: Text('Send Photos', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2B66),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onValuationSuccess?.call();
                      },
                      child: Text('OK', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (_nameCtrl.text.isEmpty && auth.currentUser?.name != null) {
      _nameCtrl.text = auth.currentUser!.name;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2B66),
        elevation: 0,
        title: Text(
          'Sell Your Car or Bike',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instant Cash Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.currency_rupee_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Instant Valuation & Spot Cash',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Free doorstep inspection & instant bank transfer at Aathava Motors.',
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              Text(
                'Vehicle Information',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),

              // Vehicle Category (Single Line Full Width)
              DropdownButtonFormField<String>(
                initialValue: _vehicleType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Vehicle Category *',
                  prefixIcon: const Icon(Icons.category_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'car', child: Text('🚗 Car')),
                  DropdownMenuItem(value: 'bike', child: Text('🏍️ Bike / Scooter')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _vehicleType = v);
                },
              ),
              const SizedBox(height: 12),

              // Brand & Model (Single Line Full Width)
              TextFormField(
                controller: _modelCtrl,
                decoration: InputDecoration(
                  labelText: 'Brand & Model *',
                  hintText: 'e.g. Maruti Swift VDi, Hyundai i20, Activa 6G',
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter vehicle model' : null,
              ),
              const SizedBox(height: 12),

              // Registration Number (Single Line Full Width)
              TextFormField(
                controller: _regNoCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Registration Number *',
                  hintText: 'e.g. TN 38 BK 9021',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter registration number' : null,
              ),
              const SizedBox(height: 12),

              // Year of Registration (Single Line Full Width)
              TextFormField(
                controller: _yearCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Registration Year *',
                  hintText: 'e.g. 2019',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter registration year' : null,
              ),
              const SizedBox(height: 12),

              // KM Driven (Single Line Full Width)
              TextFormField(
                controller: _kmCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kilometers Driven (km) *',
                  hintText: 'e.g. 45000',
                  prefixIcon: const Icon(Icons.speed_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter km driven' : null,
              ),
              const SizedBox(height: 12),

              // Fuel Type (Single Line Full Width)
              DropdownButtonFormField<String>(
                initialValue: _fuelType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Fuel Type *',
                  prefixIcon: const Icon(Icons.local_gas_station_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                  DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                  DropdownMenuItem(value: 'Electric', child: Text('Electric (EV)')),
                  DropdownMenuItem(value: 'CNG', child: Text('CNG / Hybrid')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _fuelType = v);
                },
              ),
              const SizedBox(height: 12),

              // Expected Selling Price (Single Line Full Width)
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Your Expected Selling Price (₹) *',
                  hintText: 'e.g. 450000',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter expected price' : null,
              ),
              const SizedBox(height: 18),

              Text(
                'Contact Details',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),

              // Name (Single Line Full Width)
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Owner Name *',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),

              // Phone (Single Line Full Width)
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter mobile number' : null,
              ),
              const SizedBox(height: 16),

              // Estimated Price Range Preview Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded, color: Color(0xFF2563EB), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Aathava Motors Valuation',
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${CurrencyFormatter.format(_estimatedMinPrice)} - ${CurrencyFormatter.format(_estimatedMaxPrice)}',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2B66),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _submitValuation,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    'Get Free Doorstep Valuation',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
