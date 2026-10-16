import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/pdf_invoice_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/enquiry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/enquiry_provider.dart';
import '../../providers/settings_provider.dart';
import '../billing/invoice_preview_screen.dart';

class AathavaMotorsServiceTab extends StatefulWidget {
  const AathavaMotorsServiceTab({super.key});

  @override
  State<AathavaMotorsServiceTab> createState() => _AathavaMotorsServiceTabState();
}

class _AathavaMotorsServiceTabState extends State<AathavaMotorsServiceTab> {
  String _selectedServiceCategory = 'periodic'; // 'periodic', 'ac', 'brake', 'electrical', 'breakdown'
  DateTime _serviceDate = DateTime.now().add(const Duration(days: 1));
  bool _doorstepPickup = true;
  final _notesCtrl = TextEditingController();

  final List<Map<String, dynamic>> _serviceCategories = [
    {
      'id': 'periodic',
      'title': 'General Periodic Service',
      'price': 'From ₹1,999',
      'icon': Icons.car_repair_rounded,
      'color': Color(0xFF0F2B66),
    },
    {
      'id': 'ac',
      'title': 'Car AC & Climate Control',
      'price': 'From ₹1,299',
      'icon': Icons.ac_unit_rounded,
      'color': Color(0xFF0284C7),
    },
    {
      'id': 'brake',
      'title': 'Brakes, Suspension & Tyres',
      'price': 'From ₹899',
      'icon': Icons.circle_outlined,
      'color': Color(0xFFD97706),
    },
    {
      'id': 'electrical',
      'title': 'Battery & Electrical Diagnosis',
      'price': 'From ₹499',
      'icon': Icons.electric_bolt_rounded,
      'color': Color(0xFF7C3AED),
    },
    {
      'id': 'breakdown',
      'title': '24/7 Breakdown SOS Assistance',
      'price': 'Spot Response',
      'icon': Icons.emergency_rounded,
      'color': Color(0xFFDC2626),
    },
  ];

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _bookServiceAppointment() {
    final auth = context.read<AuthProvider>();
    final customerName = auth.currentUser?.name ?? 'Mr. Sathish Kumar';
    final customerPhone = (auth.currentUser?.phone != null && auth.currentUser!.phone.isNotEmpty)
        ? auth.currentUser!.phone
        : '89517 77054';

    final category = _serviceCategories.firstWhere((c) => c['id'] == _selectedServiceCategory);

    final enquiry = EnquiryModel(
      id: 'srv-${DateTime.now().millisecondsSinceEpoch}',
      enquiryType: 'service_booking',
      title: 'Service: ${category['title']}',
      subtitle: '${_doorstepPickup ? "Doorstep Pickup" : "Showroom Visit"} • ${DateFormatter.format(_serviceDate)}',
      customerName: customerName,
      customerPhone: customerPhone,
      date: _serviceDate,
      status: 'pending',
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : 'Customer booked via Aathava Motors app.',
    );

    context.read<EnquiryProvider>().addEnquiry(enquiry);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 48),
            const SizedBox(height: 12),
            Text(
              'Service Booked Successfully!',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
            ),
            const SizedBox(height: 6),
            Text(
              'Appointment scheduled for ${DateFormatter.format(_serviceDate)}.\nOur service advisor will call $customerPhone to confirm your slot.',
              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2B66),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final billing = context.watch<BillingProvider>();
    final invoices = billing.allInvoices;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2B66),
        elevation: 0,
        title: Text(
          'Vehicle Service & Workshop',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Emergency Breakdown Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
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
                    child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Roadside Assistance',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Flat tyre, battery jumpstart, towing & emergency breakdown in Coimbatore.',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _makeCall('9442249149'),
                    child: Text('SOS Call', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Live Service Status Tracker (Job #3168)
            Text(
              'Active Service Status',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hyundai Accent 1.6 SX',
                              style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Job Card #3168 • Reg: TN 38 BK 9021',
                              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          'READY FOR DELIVERY',
                          style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Status Stepper
                  Row(
                    children: [
                      _statusStep('Received', true),
                      _stepDivider(true),
                      _statusStep('Inspect', true),
                      _stepDivider(true),
                      _statusStep('Repair', true),
                      _stepDivider(true),
                      _statusStep('Testing', true),
                      _stepDivider(true),
                      _statusStep('Ready', true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Total Bill: ₹42,520 (Bill #081)',
                            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('Ready for Pickup', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF059669), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Book a Service Appointment
            Text(
              'Book Vehicle Service',
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.softShadow,
              ),
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Select Service Type *', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                  const SizedBox(height: 8),
                  // Dropdown (Single Line Full Width)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedServiceCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.build_rounded),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _serviceCategories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['id'] as String,
                        child: Text('${c["title"]} (${c["price"]})'),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedServiceCategory = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Date Picker Tile
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _serviceDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) setState(() => _serviceDate = picked);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: Color(0xFF0F2B66)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Preferred Service Date', style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B))),
                                Text(DateFormatter.format(_serviceDate), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                              ],
                            ),
                          ),
                          const Icon(Icons.edit_calendar_rounded, size: 18, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Doorstep Pickup Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Doorstep Pickup & Drop', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                    subtitle: Text('Complimentary valet pickup from your home / office in Coimbatore', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                    value: _doorstepPickup,
                    activeThumbColor: const Color(0xFF0F2B66),
                    onChanged: (val) => setState(() => _doorstepPickup = val),
                  ),
                  const SizedBox(height: 14),

                  // Submit Booking Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2B66),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _bookServiceAppointment,
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: Text('Confirm Service Booking', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
            const SizedBox(height: 24),

            // 4. Past Service Invoices & Bill Download
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Service Bills & Invoices',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Text(
                  '${invoices.length} Bills',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (invoices.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Text('No service bills yet.', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
              )
            else
              ...invoices.take(3).map((inv) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => InvoicePreviewScreen(invoice: inv)),
                        );
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2B66).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0F2B66), size: 20),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Bill No: ${inv.invoiceNumber}',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.format(inv.grandTotal),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF059669), fontSize: 13),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text('Vehicle: ${inv.vehicleNumber} • ${DateFormatter.format(inv.date)}', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                          Text('PAID (${inv.paymentMode.toUpperCase()})', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.download_rounded, color: Color(0xFF0F2B66)),
                        tooltip: 'Download Bill PDF',
                        onPressed: () {
                          final shop = context.read<SettingsProvider>().shop;
                          PdfInvoiceService.downloadInvoice(inv, shop);
                        },
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statusStep(String label, bool isDone) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 8.5,
          backgroundColor: isDone ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
          child: const Icon(Icons.check, size: 10, color: Colors.white),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 8, fontWeight: isDone ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF334155)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _stepDivider(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
      ),
    );
  }
}
