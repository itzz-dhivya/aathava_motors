import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/used_vehicle_model.dart';
import '../../providers/used_vehicle_provider.dart';

class AddEditUsedVehicleScreen extends StatefulWidget {
  final UsedVehicleModel? vehicle;

  const AddEditUsedVehicleScreen({super.key, this.vehicle});

  @override
  State<AddEditUsedVehicleScreen> createState() => _AddEditUsedVehicleScreenState();
}

class _AddEditUsedVehicleScreenState extends State<AddEditUsedVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _vehicleType;
  late TextEditingController _titleCtrl;
  late TextEditingController _brandCtrl;
  late TextEditingController _yearCtrl;
  late TextEditingController _regNoCtrl;
  late TextEditingController _kmCtrl;
  late String _fuelType;
  late String _transmission;
  late int _ownership;
  late TextEditingController _priceCtrl;
  late bool _isNegotiable;
  late TextEditingController _insuranceCtrl;
  late TextEditingController _inspectionScoreCtrl;
  late TextEditingController _featuresCtrl;
  late TextEditingController _descriptionCtrl;
  late String _status;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _vehicleType = v?.vehicleType ?? 'car';
    _titleCtrl = TextEditingController(text: v?.title ?? '');
    _brandCtrl = TextEditingController(text: v?.brand ?? '');
    _yearCtrl = TextEditingController(text: v != null ? '${v.year}' : '2021');
    _regNoCtrl = TextEditingController(text: v?.regNumber ?? '');
    _kmCtrl = TextEditingController(text: v != null ? '${v.kmDriven}' : '');
    _fuelType = v?.fuelType ?? 'Petrol';
    _transmission = v?.transmission ?? 'Manual';
    _ownership = v?.ownershipCount ?? 1;
    _priceCtrl = TextEditingController(text: v != null ? '${v.sellingPrice.toInt()}' : '');
    _isNegotiable = v?.isNegotiable ?? true;
    _insuranceCtrl = TextEditingController(text: v?.insuranceValidity ?? 'Comprehensive Insurance Valid');
    _inspectionScoreCtrl = TextEditingController(text: v?.inspectionScore ?? '95/100 (Aathava Certified)');
    _featuresCtrl = TextEditingController(text: v?.features.join(', ') ?? '');
    _descriptionCtrl = TextEditingController(text: v?.description ?? '');
    _status = v?.status ?? 'available';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _brandCtrl.dispose();
    _yearCtrl.dispose();
    _regNoCtrl.dispose();
    _kmCtrl.dispose();
    _priceCtrl.dispose();
    _insuranceCtrl.dispose();
    _inspectionScoreCtrl.dispose();
    _featuresCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    final parsedYear = int.tryParse(_yearCtrl.text.trim()) ?? DateTime.now().year;
    final parsedKm = int.tryParse(_kmCtrl.text.trim()) ?? 0;
    final parsedPrice = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final featuresList = _featuresCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final isEditing = widget.vehicle != null;
    final id = isEditing ? widget.vehicle!.id : 'veh_${DateTime.now().millisecondsSinceEpoch}';

    final vehicle = UsedVehicleModel(
      id: id,
      title: _titleCtrl.text.trim(),
      vehicleType: _vehicleType,
      brand: _brandCtrl.text.trim(),
      year: parsedYear,
      regNumber: _regNoCtrl.text.trim().toUpperCase(),
      kmDriven: parsedKm,
      fuelType: _fuelType,
      transmission: _transmission,
      ownershipCount: _ownership,
      sellingPrice: parsedPrice,
      isNegotiable: _isNegotiable,
      insuranceValidity: _insuranceCtrl.text.trim(),
      status: _status,
      inspectionScore: _inspectionScoreCtrl.text.trim(),
      features: featuresList,
      description: _descriptionCtrl.text.trim(),
    );

    final provider = context.read<UsedVehicleProvider>();
    bool success;
    if (isEditing) {
      success = await provider.updateVehicle(vehicle);
    } else {
      success = await provider.addVehicle(vehicle);
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Vehicle updated successfully!' : 'Vehicle added to Showroom!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.vehicle != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Vehicle Listing' : 'Add Vehicle for Sale',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
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
                  // Vehicle Type (Single Line Full Width)
                  DropdownButtonFormField<String>(
                    initialValue: _vehicleType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Category *',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'car', child: Text('🚗 Second-Hand Car')),
                      DropdownMenuItem(value: 'bike', child: Text('🏍️ Second-Hand Bike / Scooter')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _vehicleType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Vehicle Title / Model (Single Line Full Width)
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Title & Model *',
                      prefixIcon: Icon(Icons.drive_file_rename_outline),
                      hintText: 'e.g. Hyundai Accent 1.5 GLS / Pulsar 150',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter model title' : null,
                  ),
                  const SizedBox(height: 14),

                  // Brand (Single Line Full Width)
                  TextFormField(
                    controller: _brandCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Brand / Make *',
                      prefixIcon: Icon(Icons.branding_watermark_outlined),
                      hintText: 'e.g. Hyundai, Maruti Suzuki, Royal Enfield, Honda',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter vehicle brand' : null,
                  ),
                  const SizedBox(height: 14),

                  // Manufacturing Year (Single Line Full Width)
                  TextFormField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Year of Manufacture *',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      hintText: 'e.g. 2021',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter manufacturing year' : null,
                  ),
                  const SizedBox(height: 14),

                  // Registration Number (Single Line Full Width)
                  TextFormField(
                    controller: _regNoCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Registration Number *',
                      prefixIcon: Icon(Icons.tag_rounded),
                      hintText: 'e.g. TN 01 X 2943',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter registration number' : null,
                  ),
                  const SizedBox(height: 14),

                  // Kilometers Driven (Single Line Full Width)
                  TextFormField(
                    controller: _kmCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kilometers Driven (KM) *',
                      prefixIcon: Icon(Icons.speed_rounded),
                      hintText: 'e.g. 45000',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter odometer KM' : null,
                  ),
                  const SizedBox(height: 14),

                  // Fuel Type (Single Line Full Width)
                  DropdownButtonFormField<String>(
                    initialValue: _fuelType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Type *',
                      prefixIcon: Icon(Icons.local_gas_station_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                      DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                      DropdownMenuItem(value: 'Electric', child: Text('Electric (EV)')),
                      DropdownMenuItem(value: 'CNG', child: Text('CNG / Hybrid')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _fuelType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Transmission (Single Line Full Width)
                  DropdownButtonFormField<String>(
                    initialValue: _transmission,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Transmission *',
                      prefixIcon: Icon(Icons.settings_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                      DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _transmission = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Ownership Count (Single Line Full Width)
                  DropdownButtonFormField<int>(
                    initialValue: _ownership,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Number of Owners *',
                      prefixIcon: Icon(Icons.person_pin_circle_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1st Owner')),
                      DropdownMenuItem(value: 2, child: Text('2nd Owner')),
                      DropdownMenuItem(value: 3, child: Text('3rd Owner')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _ownership = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Expected Selling Price (Single Line Full Width)
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Expected Selling Price *',
                      prefixIcon: Icon(Icons.currency_rupee),
                      hintText: 'e.g. 385000',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter selling price' : null,
                  ),
                  const SizedBox(height: 10),

                  // Price Negotiable Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Price is Negotiable', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: const Text('Allow buyers to make counter offers', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    value: _isNegotiable,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isNegotiable = v),
                  ),
                  const SizedBox(height: 10),

                  // Insurance Validity (Single Line Full Width)
                  TextFormField(
                    controller: _insuranceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Insurance Validity',
                      prefixIcon: Icon(Icons.security_rounded),
                      hintText: 'e.g. Comprehensive Valid till Dec 2026',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Inspection Rating / Score (Single Line Full Width)
                  TextFormField(
                    controller: _inspectionScoreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Aathava Inspection Rating',
                      prefixIcon: Icon(Icons.verified_outlined),
                      hintText: 'e.g. 96/100 (Aathava Certified)',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Features (Single Line Full Width)
                  TextFormField(
                    controller: _featuresCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Key Features (Comma separated)',
                      prefixIcon: Icon(Icons.featured_play_list_outlined),
                      hintText: 'e.g. Power Steering, Chill AC, New Tyres, Fog Lamps',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description / Notes (Single Line Full Width)
                  TextFormField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description & Vehicle History',
                      prefixIcon: Icon(Icons.notes_rounded),
                      hintText: 'Single owner, clean maintenance record, recently serviced at Aathava Motors...',
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Inventory Status (Single Line Full Width)
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Listing Status *',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('🟢 Available for Sale')),
                      DropdownMenuItem(value: 'booked', child: Text('🟡 Token Booked')),
                      DropdownMenuItem(value: 'sold', child: Text('🔴 Sold Out')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveVehicle,
                      icon: const Icon(Icons.save),
                      label: Text(
                        isEditing ? 'Update Vehicle in Showroom' : 'Publish Vehicle for Sale',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
