import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/enquiry_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/enquiry_provider.dart';
import '../auth/user_mode_screen.dart';

class AathavaMotorsEnquiriesTab extends StatefulWidget {
  const AathavaMotorsEnquiriesTab({super.key});

  @override
  State<AathavaMotorsEnquiriesTab> createState() => _AathavaMotorsEnquiriesTabState();
}

class _AathavaMotorsEnquiriesTabState extends State<AathavaMotorsEnquiriesTab> {
  String _selectedFilter = 'all'; // 'all', 'test_drive', 'sell_valuation', 'service_booking'

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String message) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final formattedPhone = cleanPhone.length == 10 ? '91$cleanPhone' : cleanPhone;
    final uri = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to switch to User Mode selection?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2B66)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserModeScreen()),
              );
            },
            child: const Text('Yes, Switch Mode', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final enquiryProv = context.watch<EnquiryProvider>();

    final customerName = auth.currentUser?.name ?? 'Mr. Sathish Kumar';
    final customerPhone = (auth.currentUser?.phone != null && auth.currentUser!.phone.isNotEmpty)
        ? auth.currentUser!.phone
        : '89517 77054';

    List<EnquiryModel> list = enquiryProv.allEnquiries;
    if (_selectedFilter != 'all') {
      list = list.where((e) => e.enquiryType == _selectedFilter).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2B66),
        elevation: 0,
        title: Text(
          'My Enquiries & Account',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFFFDE68A)),
            tooltip: 'Switch Mode',
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Customer Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2B66), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.softShadow,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFF59E0B),
                    child: Text(
                      customerName.isNotEmpty ? customerName[0] : 'S',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '📞 $customerPhone',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Active Vehicle: Hyundai Accent (TN 38 BK 9021)',
                            style: GoogleFonts.poppins(fontSize: 9.5, color: const Color(0xFFFDE68A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Enquiry Filter Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Enquiries & Leads',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${list.length} Records',
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('all', 'All (${enquiryProv.allEnquiries.length})'),
                  const SizedBox(width: 8),
                  _chip('test_drive', '🚗 Test Drives (${enquiryProv.testDrives.length})'),
                  const SizedBox(width: 8),
                  _chip('sell_valuation', '💰 Valuations (${enquiryProv.sellValuations.length})'),
                  const SizedBox(width: 8),
                  _chip('service_booking', '🛠️ Service (${enquiryProv.serviceBookings.length})'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Enquiry Cards List
            if (list.isEmpty)
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
                    const Icon(Icons.inbox_outlined, size: 44, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 8),
                    Text('No enquiries in this category', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
                    Text('Book a test drive or valuation to see updates here.', style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF94A3B8))),
                  ],
                ),
              )
            else
              ...list.map((enq) => _buildEnquiryCard(context, enq)),

            const SizedBox(height: 20),

            // 4. Quick Support & Dealer Contact Card
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
                      const Icon(Icons.support_agent_rounded, color: Color(0xFF0F2B66), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Aathava Motors Customer Desk',
                        style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Need assistance with pre-owned purchases, instant vehicle sale, or workshop status?',
                    style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF25D366),
                            side: const BorderSide(color: Color(0xFF25D366)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _openWhatsApp('8951777054', 'Hello Aathava Motors, I have a question regarding my enquiry.'),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                          label: Text('WhatsApp', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F2B66),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _makeCall('9442249149'),
                          icon: const Icon(Icons.phone_rounded, size: 16),
                          label: Text('Call Dealer', style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _chip(String filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F2B66) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F2B66) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildEnquiryCard(BuildContext context, EnquiryModel enq) {
    Color statusColor;
    Color statusBg;
    switch (enq.status) {
      case 'confirmed':
        statusColor = const Color(0xFF059669);
        statusBg = const Color(0xFFECFDF5);
        break;
      case 'completed':
        statusColor = const Color(0xFF2563EB);
        statusBg = const Color(0xFFEFF6FF);
        break;
      default:
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
    }

    IconData typeIcon;
    switch (enq.enquiryType) {
      case 'test_drive':
        typeIcon = Icons.directions_car_rounded;
        break;
      case 'sell_valuation':
        typeIcon = Icons.currency_rupee_rounded;
        break;
      default:
        typeIcon = Icons.car_repair_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2B66).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(typeIcon, color: const Color(0xFF0F2B66), size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        DateFormatter.format(enq.date),
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
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
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  enq.status.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            enq.title,
            style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          Text(
            enq.subtitle,
            style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
          ),
          if (enq.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Note: ${enq.notes}',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF475569)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
