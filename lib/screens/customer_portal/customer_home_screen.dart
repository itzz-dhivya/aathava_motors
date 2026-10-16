import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/pdf_invoice_service.dart';
import '../auth/user_mode_screen.dart';
import '../billing/invoice_preview_screen.dart';
import '../../models/used_vehicle_model.dart';
import '../../providers/used_vehicle_provider.dart';
import '../used_vehicles/used_vehicle_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _activeSection = 0; // 0: Garage Service, 1: Used Cars & Bikes Sales

  void _showSellVehicleModal() {
    final typeCtrl = ValueNotifier<String>('car');
    final modelCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final kmCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '89517 77054');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Sell Your Car or Bike',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F2B66),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    Text(
                      'Get best valuation & instant token from AATHAVA MOTORS!',
                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: typeCtrl.value,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Category *',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'car', child: Text('🚗 Car')),
                        DropdownMenuItem(value: 'bike', child: Text('🏍️ Bike / Scooter')),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => typeCtrl.value = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: modelCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Brand & Model *',
                        prefixIcon: Icon(Icons.drive_file_rename_outline),
                        hintText: 'e.g. Maruti Swift / Royal Enfield',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: yearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Manufacturing Year *',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        hintText: 'e.g. 2020',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: kmCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kilometers Driven (KM) *',
                        prefixIcon: Icon(Icons.speed_rounded),
                        hintText: 'e.g. 45000',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Your Expected Price (₹) *',
                        prefixIcon: Icon(Icons.currency_rupee),
                        hintText: 'e.g. 420000',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Your Mobile Number *',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Thank you! AATHAVA MOTORS evaluation team will inspect your vehicle and contact you shortly with the best valuation.',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: const Color(0xFF059669),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F2B66),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Submit for Free Valuation',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBookServiceModal() {
    final vehicleCtrl = TextEditingController(text: 'TN 01 X 2943 (Hyundai Accent)');
    String serviceType = 'Periodic Maintenance & Oil Change';
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Book Garage Service',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F2B66),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vehicle Details',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: vehicleCtrl,
                    style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontSize: 13.5),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0F2B66), width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Select Service Required',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: serviceType,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontSize: 13),
                        items: [
                          'Periodic Maintenance & Oil Change',
                          'Brake Inspection & Pad Replacement',
                          'Suspension & Wheel Alignment',
                          'AC Gas Refill & Cooling Diagnostics',
                          'Battery Check & Electrical Repair',
                          'Full Vehicle Water Wash & Detailing',
                        ].map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => serviceType = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Complaints / Symptoms (Optional)',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. slight braking noise, oil topup needed',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF0F2B66), width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Service appointment requested! Garage booking token #BK-9021 confirmed.',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2B66),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Appointment Booking',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showBreakdownModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emergency_rounded, color: Color(0xFFEF4444), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '24/7 Breakdown Help',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66), fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need immediate towing or on-spot roadside assistance?',
              style: GoogleFonts.poppins(color: const Color(0xFF475569), fontSize: 13),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.support_agent_rounded, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AATHAVA Helpline: 94437 25988',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'AATHAVA MOTORS Quick Towing & Mechanic Response Unit (Peelamedu, Coimbatore)',
                    style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 10.5),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins(color: const Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling Garage Helpline: 94422 49149', style: GoogleFonts.poppins()),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            icon: const Icon(Icons.phone, size: 16),
            label: Text('Call Now', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final isTamil = context.read<LocaleProvider>().isTamil;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.danger, size: 24),
            const SizedBox(width: 8),
            Text(
              isTamil ? 'வெளியேறவா?' : 'Confirm Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          isTamil
              ? 'உங்கள் கணக்கிலிருந்து வெளியேற விரும்புகிறீர்களா?'
              : 'Are you sure you want to logout and return to user mode selection?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isTamil ? 'இல்லை (No)' : 'No',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const UserModeScreen()),
                (r) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isTamil ? 'ஆம் (Yes)' : 'Yes',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final billing = context.watch<BillingProvider>();
    final locale = context.watch<LocaleProvider>();
    final isTamil = locale.isTamil;

    final customerName = auth.currentUser?.name ?? 'Mr. Sathish Kumar';
    final customerPhone = (auth.currentUser?.phone != null && auth.currentUser!.phone.isNotEmpty) ? auth.currentUser!.phone : '89517 77054';
    final vehicleNo = auth.currentUser?.vehicleNumber ?? 'TN 01 X 2943';
    final invoices = billing.allInvoices;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // White Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2B66), // Navy Blue Header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserModeScreen()),
              );
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'My Garage Hub',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Switch Mode Button
          TextButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserModeScreen()),
              );
            },
            icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: Color(0xFFFDE68A)),
            label: Text(
              isTamil ? 'முறை மாற்று' : 'Switch Mode',
              style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFFFDE68A)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white70),
            tooltip: 'Logout',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // Customer Welcome Hero Card with Colorful Navy Gradient
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2B66), Color(0xFF1E40AF), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_user, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'VEHICLE OWNER',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'AATHAVA MOTORS • Coimbatore',
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome, $customerName 👋',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '📞 $customerPhone • Primary: $vehicleNo • Hyundai Accent (Job #3168)',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _heroStat('Job Card', '#3168', 'Hyundai Accent'),
                    const SizedBox(width: 8),
                    _heroStat('Last Bill', '₹42,520', 'Bill No. 081 ✅'),
                    const SizedBox(width: 8),
                    _heroStat('Next Service', '15 Nov 26', 'Due in 30d'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sales & Service Section Selector Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _activeSection = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeSection == 0 ? const Color(0xFF0F2B66) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeSection == 0 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.car_repair_rounded,
                            size: 16,
                            color: _activeSection == 0 ? Colors.white : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Garage Service',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: _activeSection == 0 ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _activeSection = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeSection == 1 ? const Color(0xFF0F2B66) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeSection == 1 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sell_rounded,
                            size: 16,
                            color: _activeSection == 1 ? const Color(0xFFFDE68A) : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cars & Bikes Sales',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: _activeSection == 1 ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_activeSection == 0) ...[
          // Live Vehicle Service Tracker (Feature Highlight - White Card with Grey Shadow)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // Crisp White
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.softShadow, // Grey Shadow
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tracker Header (Overflow Proof)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'LIVE SERVICE TRACKER',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: const Color(0xFF065F46),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '70% Completed',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF065F46),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '$vehicleNo (Hyundai Accent) is currently on Service Bay #2',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Lead Mechanic: Muthu • Estimated Delivery: Today 5:30 PM',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Stepper Timeline
                _serviceStep(
                  step: 1,
                  title: 'Vehicle Received & Check-in',
                  subtitle: 'Checked in at 09:30 AM by Supervisor',
                  isCompleted: true,
                ),
                _serviceStep(
                  step: 2,
                  title: 'Diagnostics & 8-Point Inspection',
                  subtitle: 'Brakes & Engine oil diagnosed at 10:15 AM',
                  isCompleted: true,
                ),
                _serviceStep(
                  step: 3,
                  title: 'Brake Pad & Oil Filter Replacement',
                  subtitle: 'Technician Muthu replacing front Bosch ceramic pads',
                  isCompleted: false,
                  isActive: true,
                ),
                _serviceStep(
                  step: 4,
                  title: 'Foam Wash & Interior Cleaning',
                  subtitle: 'Queued next for washing bay',
                  isCompleted: false,
                ),
                _serviceStep(
                  step: 5,
                  title: 'Ready for Gate Pass & Delivery',
                  subtitle: 'Final inspection & invoice generation',
                  isCompleted: false,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Customer Actions
          Text(
            'Quick Customer Actions',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F2B66),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Book Service Slot',
                  color: const Color(0xFF2563EB),
                  bgLight: const Color(0xFFEFF6FF),
                  onTap: _showBookServiceModal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionCard(
                  icon: Icons.emergency_rounded,
                  label: '24/7 Breakdown',
                  color: const Color(0xFFDC2626),
                  bgLight: const Color(0xFFFEF2F2),
                  onTap: _showBreakdownModal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'My Garage Bills',
                  color: const Color(0xFFD97706),
                  bgLight: const Color(0xFFFFFBEB),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // My Registered Vehicles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Garage Vehicles',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F2B66),
                ),
              ),
              Text(
                '2 Vehicles Registered',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _vehicleCard(
            model: 'Hyundai Accent (Job #3168)',
            regNo: 'TN 01 X 2943',
            fuel: 'Petrol • KM: 1,03,559',
            status: 'Serviced • Bill No. 081 (₹42,520 Paid) ✅',
            statusColor: const Color(0xFF059669),
            icon: Icons.directions_car_rounded,
          ),
          const SizedBox(height: 10),

          _vehicleCard(
            model: 'Hyundai Creta SX(O)',
            regNo: 'TN 09 BK 7890',
            fuel: 'Diesel • Automatic',
            status: 'Healthy (Next service in 45 days)',
            statusColor: const Color(0xFF2563EB),
            icon: Icons.directions_car_rounded,
          ),
          const SizedBox(height: 22),

          // Invoices & Service History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Service Bills & Invoices',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F2B66),
                ),
              ),
              Text(
                '${invoices.length} Invoices',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (invoices.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppColors.softShadow,
              ),
              alignment: Alignment.center,
              child: Text(
                'No past service bills yet. Visit the garage for your next maintenance!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 12),
              ),
            )
          else
            ...invoices.take(3).map((inv) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: AppColors.softShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoicePreviewScreen(invoice: inv),
                        ),
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
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(inv.grandTotal),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(
                          'Vehicle: ${inv.vehicleNumber.isNotEmpty ? inv.vehicleNumber : vehicleNo} • ${DateFormatter.format(inv.date)}',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Status: ${inv.status.toUpperCase()} (${inv.paymentMode.toUpperCase()})',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: inv.status == 'paid' ? const Color(0xFF059669) : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download_rounded, color: Color(0xFF0F2B66), size: 22),
                          tooltip: 'Download Bill PDF',
                          onPressed: () {
                            final shop = context.read<SettingsProvider>().shop;
                            PdfInvoiceService.downloadInvoice(inv, shop);
                          },
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 30),
        ] else ...[
          // ================= PRE-OWNED CARS & BIKES SHOWROOM SECTION =================
          // 1. Sell / Exchange Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2B66), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F2B66).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.currency_rupee_rounded, color: Color(0xFFFBBF24), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'SELL OR EXCHANGE',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Want to Sell Your Car or Bike?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Instant valuation & spot payment at Aathava Motors',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBBF24),
                    foregroundColor: const Color(0xFF0F2B66),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showSellVehicleModal(),
                  child: Text(
                    'Sell Now',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Filter Pills & Section Title
          Consumer<UsedVehicleProvider>(
            builder: (context, vProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F2B66).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.verified_rounded, color: Color(0xFF0F2B66), size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pre-Owned Showroom',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          '${vProvider.filteredVehicles.length} Available',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterChip('all', 'All Vehicles (${vProvider.totalCount})', vProvider),
                        const SizedBox(width: 8),
                        _filterChip('car', '🚗 Cars (${vProvider.carsCount})', vProvider),
                        const SizedBox(width: 8),
                        _filterChip('bike', '🏍️ Bikes (${vProvider.bikesCount})', vProvider),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Vehicles List
                  if (vProvider.filteredVehicles.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.directions_car_outlined, size: 48, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 10),
                          Text(
                            'No vehicles available in this category',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF475569)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap "Sell Now" above to list your car or bike with us!',
                            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...vProvider.filteredVehicles.map((vehicle) {
                      return _buildCustomerVehicleCard(context, vehicle);
                    }),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // 4. Assurance Guarantee Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF059669), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Aathava Motors Assurance',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _assuranceRow(Icons.check_circle_rounded, '120-Point Multi-Stage Inspection Certified'),
                _assuranceRow(Icons.check_circle_rounded, 'Non-Accidental & Clean RTO Documents Guarantee'),
                _assuranceRow(Icons.check_circle_rounded, '6 Months Free Engine & Gearbox Assistance'),
                _assuranceRow(Icons.check_circle_rounded, 'Doorstep Test Drive & Easy Financing Available'),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ],
    ),
  );
}

  Widget _heroStat(String label, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(sub, style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFFFDE68A)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _serviceStep({
    required int step,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
    bool isLast = false,
  }) {
    Color iconColor;
    IconData iconData;
    if (isCompleted) {
      iconColor = const Color(0xFF10B981);
      iconData = Icons.check_circle_rounded;
    } else if (isActive) {
      iconColor = const Color(0xFFD97706);
      iconData = Icons.autorenew_rounded;
    } else {
      iconColor = const Color(0xFFCBD5E1);
      iconData = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(iconData, color: iconColor, size: 20),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
                    color: isActive
                        ? const Color(0xFFD97706)
                        : isCompleted
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgLight,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleCard({
    required String model,
    required String regNo,
    required String fuel,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        model,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2B66),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        regNo,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(fuel, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B))),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filter, String label, UsedVehicleProvider provider) {
    final isSelected = provider.selectedTypeFilter == filter;
    return GestureDetector(
      onTap: () => provider.setTypeFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F2B66) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F2B66) : const Color(0xFFCBD5E1),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F2B66).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerVehicleCard(BuildContext context, UsedVehicleModel vehicle) {
    final isCar = vehicle.vehicleType == 'car';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Badge bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF059669)),
                      const SizedBox(width: 4),
                      Text(
                        'AATHAVA CERTIFIED • ${vehicle.inspectionScore}',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: vehicle.status == 'available'
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    vehicle.status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: vehicle.status == 'available'
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isCar ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCar ? const Color(0xFFBFDBFE) : const Color(0xFFFED7AA),
                        ),
                      ),
                      child: Icon(
                        isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                        color: isCar ? const Color(0xFF1E40AF) : const Color(0xFFC2410C),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.year} ${vehicle.title}',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Reg: ${vehicle.regNumber} • ${vehicle.ownershipCount == 1 ? "1st Owner" : "${vehicle.ownershipCount} Owners"}',
                            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Spec Pills (Wrap to avoid overflow)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _vehicleSpecPill(Icons.speed_rounded, '${vehicle.kmDriven} km'),
                    _vehicleSpecPill(Icons.local_gas_station_rounded, vehicle.fuelType),
                    _vehicleSpecPill(Icons.settings_rounded, vehicle.transmission),
                    _vehicleSpecPill(Icons.shield_outlined, 'Ins: ${vehicle.insuranceValidity}'),
                  ],
                ),
                const SizedBox(height: 14),

                // Price and CTAs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${vehicle.sellingPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F2B66),
                          ),
                        ),
                        Text(
                          vehicle.isNegotiable ? 'Negotiable' : 'Fixed Price',
                          style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F2B66),
                            side: const BorderSide(color: Color(0xFF0F2B66)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UsedVehicleDetailScreen(vehicle: vehicle),
                              ),
                            );
                          },
                          child: Text(
                            'Inspect / Details',
                            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UsedVehicleDetailScreen(vehicle: vehicle),
                              ),
                            );
                          },
                          child: Text(
                            'Test Drive',
                            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleSpecPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF334155), fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assuranceRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: const Color(0xFF059669)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }
}

