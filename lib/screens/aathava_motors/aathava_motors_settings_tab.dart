import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/user_mode_screen.dart';

class AathavaMotorsSettingsTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const AathavaMotorsSettingsTab({super.key, this.onNavigateTab});

  @override
  State<AathavaMotorsSettingsTab> createState() => _AathavaMotorsSettingsTabState();
}

class _AathavaMotorsSettingsTabState extends State<AathavaMotorsSettingsTab> {
  bool _smsAlerts = true;
  bool _whatsappUpdates = true;
  bool _inspectionReminders = true;

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

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final nameCtrl = TextEditingController(text: auth.currentUser?.name ?? 'Mr. Sathish Kumar');
    final phoneCtrl = TextEditingController(text: auth.currentUser?.phone ?? '89517 77054');
    final isTamil = context.read<LocaleProvider>().isTamil;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isTamil ? 'விவரங்களை மாற்று' : 'Edit Profile Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF0F2B66)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: isTamil ? 'பெயர்' : 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: isTamil ? 'தொலைபேசி எண்' : 'Mobile Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isTamil ? 'ரத்து' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F2B66),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isTamil ? 'விவரங்கள் புதுப்பிக்கப்பட்டன!' : 'Profile updated successfully!'),
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
            child: Text(isTamil ? 'சேமி' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final isTamil = context.read<LocaleProvider>().isTamil;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isTamil ? 'வெளியேற உறுதிப்படுத்தவும்' : 'Confirm Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF0F2B66)),
              ),
            ),
          ],
        ),
        content: Text(
          isTamil
              ? 'நீங்கள் ஆதவா மோட்டார்ஸ் வாடிக்கையாளர் தளத்திலிருந்து வெளியேற விரும்புகிறீர்களா?'
              : 'Are you sure you want to log out from Aathava Motors Customer & Vehicle Portal?',
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF475569)),
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isTamil ? 'ரத்து' : 'Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final auth = context.read<AuthProvider>();
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const UserModeScreen()),
                (route) => false,
              );
            },
            child: Text(isTamil ? 'வெளியேறு' : 'Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();
    final isTamil = locale.isTamil;
    final customerName = auth.currentUser?.name ?? 'Mr. Sathish Kumar';
    final customerPhone = (auth.currentUser?.phone != null && auth.currentUser!.phone.isNotEmpty)
        ? auth.currentUser!.phone
        : '89517 77054';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2B66),
        elevation: 0,
        title: Text(
          isTamil ? 'அமைப்பு & சுயவிவரம்' : 'Settings & Profile',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => locale.toggleLanguage(),
            icon: const Icon(Icons.language_rounded, size: 16),
            label: Text(
              isTamil ? 'English' : 'தமிழ்',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Customer Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2B66), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    customerName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified_rounded, color: Color(0xFF34D399), size: 16),
                              ],
                            ),
                            Text(
                              customerPhone,
                              style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                isTamil ? 'வாகனம் வாங்குவோர் & விற்பனையாளர்' : 'Vehicle Buyer & Seller',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFA7F3D0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                        ),
                        icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                        tooltip: 'Edit Profile',
                        onPressed: () => _showEditProfileDialog(context, auth),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Quick Activity Navigation
            Text(
              isTamil ? 'எனது செயல்பாடுகள்' : 'My Activity & Enquiries',
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                children: [
                  _menuItem(
                    icon: Icons.assignment_outlined,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                    title: isTamil ? 'எனது விசாரணைகள் & முன்பதிவுகள்' : 'My Enquiries & Test Drives',
                    subtitle: isTamil ? 'விலை மதிப்பீடு மற்றும் சர்வீஸ் நிலை' : 'Track live status & valuation offers',
                    onTap: () => widget.onNavigateTab?.call(4),
                  ),
                  const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),
                  _menuItem(
                    icon: Icons.currency_rupee_rounded,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFECFDF5),
                    title: isTamil ? 'வாகன விற்பனை கோரிக்கை' : 'Sell My Vehicle Valuation',
                    subtitle: isTamil ? '30 நிமிடங்களில் உடனடி வங்கி பரிமாற்றம்' : 'Instant doorstep inspection & cash offer',
                    onTap: () => widget.onNavigateTab?.call(2),
                  ),
                  const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),
                  _menuItem(
                    icon: Icons.car_repair_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFFFBEB),
                    title: isTamil ? 'பணிமனை சர்வீஸ் முன்பதிவு' : 'Book Vehicle Service',
                    subtitle: isTamil ? 'இலவச பிக்-அப் மற்றும் டிராப்' : 'Doorstep pickup & expert multi-brand service',
                    onTap: () => widget.onNavigateTab?.call(3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. Garage & Showroom Location Info
            Text(
              isTamil ? 'ஆதவா மோட்டார்ஸ் தகவல்' : 'Aathava Motors Hub Info',
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2B66).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Color(0xFF0F2B66), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aathava Motors Showroom & Garage',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
                            ),
                            Text(
                              'Certified Pre-Owned Cars & Bikes Hub',
                              style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFFEA580C), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '142/3, Trichy Road, Singanallur, Coimbatore, Tamil Nadu - 641005',
                          style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Mon - Sat: 9:00 AM - 8:30 PM | Sun: 10:00 AM - 4:00 PM',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF25D366),
                            side: const BorderSide(color: Color(0xFF25D366)),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _openWhatsApp('8951777054', 'Hello Aathava Motors, I have a query about vehicle valuation and service.'),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                          label: Text('WhatsApp', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F2B66),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _makeCall('9442249149'),
                          icon: const Icon(Icons.phone_rounded, size: 16),
                          label: Text(isTamil ? 'அழைக்க' : 'Call Hub', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 4. Notifications & Preferences
            Text(
              isTamil ? 'அறிவிப்பு விருப்பங்கள்' : 'Notification Preferences',
              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
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
                child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      isTamil ? 'வாட்ஸ்அப் நிலை தகவல்கள்' : 'WhatsApp Status Alerts',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                    subtitle: Text(
                      isTamil ? 'டெஸ்ட் டிரைவ் & சர்வீஸ் நிலை அறிவிப்புகள்' : 'Instant updates on test drive & live service card',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    value: _whatsappUpdates,
                    activeThumbColor: const Color(0xFF0F2B66),
                    onChanged: (v) => setState(() => _whatsappUpdates = v),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  SwitchListTile(
                    title: Text(
                      isTamil ? 'எஸ்எம்எஸ் பில்லிங் விவரங்கள்' : 'SMS Invoice Alerts',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                    subtitle: Text(
                      isTamil ? 'பில் ரசீதுகள் மற்றும் கட்டண தகவல்' : 'Receive PDF invoice download link via SMS',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    value: _smsAlerts,
                    activeThumbColor: const Color(0xFF0F2B66),
                    onChanged: (v) => setState(() => _smsAlerts = v),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  SwitchListTile(
                    title: Text(
                      isTamil ? 'வாகன நினைவூட்டல்கள்' : 'Periodic Service Reminders',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                    ),
                    subtitle: Text(
                      isTamil ? 'இன்சூரன்ஸ் மற்றும் சர்வீஸ் எச்சரிக்கைகள்' : 'Oil change and insurance renewal reminders',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                    value: _inspectionReminders,
                    activeThumbColor: const Color(0xFF0F2B66),
                    onChanged: (v) => setState(() => _inspectionReminders = v),
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 22),

            // 5. PROMINENT LOGOUT BUTTON
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
                boxShadow: AppColors.softShadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _confirmLogout(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isTamil ? 'கணக்கிலிருந்து வெளியேறு' : 'Logout from Aathava Motors',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                              Text(
                                isTamil ? 'வேறு கணக்கில் உள்நுழைய அல்லது முறை மாற்ற' : 'Switch role or sign in with another phone number',
                                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFDC2626), size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Version info
            Center(
              child: Text(
                'Aathava Motors v2.4.0 • Coimbatore, TN',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
