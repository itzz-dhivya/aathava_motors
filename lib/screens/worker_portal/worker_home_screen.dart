import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../auth/user_mode_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  String _activeJobStatus = 'In Progress (Bay #2)';
  int _completedChecks = 5;

  final List<Map<String, dynamic>> _checklist = [
    {'name': 'Engine Oil & Filter Check', 'checked': true, 'notes': 'Fresh Castrol 5W30 added'},
    {'name': 'Front Brake Pad Wear Inspection', 'checked': true, 'notes': 'Bosch ceramic pads installed'},
    {'name': 'Rear Brake Drum & Liners', 'checked': true, 'notes': 'Cleaned with brake degreaser'},
    {'name': 'Battery Voltage & Terminal Check', 'checked': true, 'notes': '12.8V Healthy (Exide)'},
    {'name': 'Coolant Level & Radiator Hoses', 'checked': true, 'notes': 'Topped up 500ml green coolant'},
    {'name': 'Air Filter & Cabin AC Filter', 'checked': false, 'notes': 'Inspect during final assembly'},
    {'name': 'Suspension Bushings & Tie Rods', 'checked': false, 'notes': 'Check on lift test'},
    {'name': 'Tyre Pressure & Tread Depth', 'checked': false, 'notes': 'Target 33 PSI all 4 wheels'},
  ];

  void _showRequestPartModal() {
    final inventory = context.read<InventoryProvider>();
    final parts = inventory.allParts;
    String search = '';

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
            final filtered = parts.where((p) {
              return p.name.toLowerCase().contains(search.toLowerCase()) ||
                     p.partNumber.toLowerCase().contains(search.toLowerCase());
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Store Spares Requisition',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
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
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (val) => setModalState(() => search = val),
                      style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search spare part name or code...',
                        hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
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
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No matching parts in workshop inventory',
                                style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 12),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, idx) {
                                final p = filtered[idx];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    boxShadow: AppColors.softShadow,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    child: ListTile(
                                      title: Text(
                                        p.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        'Code: ${p.partNumber} • Stock: ${p.stockQuantity.toInt()} ${p.unit}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: p.isLowStock ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Requisition sent to store for: ${p.name}',
                                                style: GoogleFonts.poppins(),
                                              ),
                                              backgroundColor: const Color(0xFFEA580C),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFEA580C),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'Request Part',
                                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

  void _showUpdateJobStatusModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Job Card Status',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
            ),
            const SizedBox(height: 14),
            _statusOption('In Progress (Bay #2)', 'Currently dismantling & fitting parts', const Color(0xFFD97706)),
            _statusOption('Waiting for Store Spares', 'Awaiting parts delivery from counter', const Color(0xFFDC2626)),
            _statusOption('Sent to Washing Bay', 'Repairs done, queued for foam wash', const Color(0xFF2563EB)),
            _statusOption('Completed & Ready for QC', 'All items checked, ready for gate pass', const Color(0xFF059669)),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(String title, String desc, Color color) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          setState(() => _activeJobStatus = title);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Job status updated to: $title', style: GoogleFonts.poppins()),
              backgroundColor: color,
            ),
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(Icons.circle, color: color, size: 14),
        ),
        title: Text(title, style: GoogleFonts.poppins(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(desc, style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 11)),
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
    final inventory = context.watch<InventoryProvider>();
    final locale = context.watch<LocaleProvider>();
    final isTamil = locale.isTamil;

    final mechanicName = auth.currentUser?.name ?? 'Muthu (Senior Mechanic)';
    final specialty = auth.currentUser?.specialty ?? 'Engine & Brake Diagnostics';

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
              child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mechanic Bay #2',
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
          // Mechanic Hero Station Card (Gradient with Grey Shadow)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F2B66), Color(0xFF1E3A8A), Color(0xFFC2410C)],
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
                          const Icon(Icons.verified, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            'GARAGE MECHANIC FLOOR',
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '🟢 ON DUTY',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  mechanicName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Specialty: $specialty • Shift 09:00 AM - 07:00 PM',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _workerStat('Jobs Assigned', '4 Vehicles', 'Today'),
                    const SizedBox(width: 8),
                    _workerStat('Active Repair', '1 in Bay #2', 'Hyundai'),
                    const SizedBox(width: 8),
                    _workerStat('Completed', '2 Delivered', 'On Time ✅'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Active Job Card: High Priority Repair (White Container with Grey Shadow)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, // Crisp White
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'HIGH PRIORITY JOB #JC-8842',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFDC2626),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showUpdateJobStatusModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDD5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFED7AA)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.edit_note_rounded, color: Color(0xFFC2410C), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Change Status',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFC2410C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vehicle & Customer Info (Overflow Proof)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2B66).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_car_filled, color: Color(0xFF0F2B66), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TN 01 X 2943 • Hyundai Accent (Job #3168)',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Customer: Mr. Sathish Kumar • Phone: 89517 77054',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Job #3168 | KM: 1,03,559 | Overhaul, Struts, Brakes, AC & Tinkering (Bill #081: ₹42,520)',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Status Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Stage:',
                        style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _activeJobStatus,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFC2410C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Job Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showRequestPartModal,
                        icon: const Icon(Icons.add_shopping_cart, size: 15),
                        label: Text(
                          'Request Spares',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _activeJobStatus = 'Completed & Ready for QC');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Job card marked as Completed! Sent for Quality Check.', style: GoogleFonts.poppins()),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 15, color: Color(0xFF059669)),
                        label: Text(
                          'Mark Ready',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF059669), width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 8-Point Vehicle Inspection Checklist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '8-Point Vehicle Inspection Checklist',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F2B66),
                  ),
                  overflow: TextOverflow.ellipsis,
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
                  '$_completedChecks / 8 Done',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: AppColors.softShadow,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _checklist.length,
                separatorBuilder: (context, index) => const Divider(color: Color(0xFFF1F5F9), height: 1),
                itemBuilder: (context, idx) {
                  final item = _checklist[idx];
                  final isChecked = item['checked'] as bool;

                  return CheckboxListTile(
                    value: isChecked,
                    activeColor: const Color(0xFF10B981),
                    checkColor: Colors.white,
                    onChanged: (val) {
                      setState(() {
                        item['checked'] = val ?? false;
                        _completedChecks = _checklist.where((c) => c['checked'] == true).length;
                      });
                    },
                    title: Text(
                      item['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isChecked ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                        decoration: isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      item['notes'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Workshop Spares Inventory Quick Lookup
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Store Spares Stock Lookup',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F2B66),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${inventory.allParts.length} Parts Available',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...inventory.allParts.take(4).map((p) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Part #: ${p.partNumber} • Brand: ${p.brand}',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.isLowStock
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${p.stockQuantity.toInt()} in stock',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: p.isLowStock ? const Color(0xFFDC2626) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _workerStat(String label, String value, String sub) {
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
}
