import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/used_vehicle_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/used_vehicle_provider.dart';
import '../used_vehicles/used_vehicle_detail_screen.dart';

class AathavaMotorsHomeTab extends StatefulWidget {
  final Function(int tabIndex) onNavigateTab;

  const AathavaMotorsHomeTab({super.key, required this.onNavigateTab});

  @override
  State<AathavaMotorsHomeTab> createState() => _AathavaMotorsHomeTabState();
}

class _AathavaMotorsHomeTabState extends State<AathavaMotorsHomeTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _activeHeroIndex = 0;

  final List<Map<String, dynamic>> _heroBanners = [
    {
      'tag': 'PRE-OWNED SHOWROOM',
      'title': 'Certified Pre-Owned\nCars & Bikes with Warranty',
      'desc': '120-Point Inspection • 6 Months Engine Warranty • Instant RC Transfer',
      'gradient': const [Color(0xFF0F2B66), Color(0xFF1E40AF)],
      'icon': Icons.verified_rounded,
      'cta': 'Explore Showroom',
      'tab': 1,
    },
    {
      'tag': 'INSTANT VALUATION',
      'title': 'Sell Your Car or Bike\nin 30 Minutes',
      'desc': 'Free Doorstep Inspection • Best Market Price • Spot Bank Transfer',
      'gradient': const [Color(0xFF065F46), Color(0xFF047857)],
      'icon': Icons.currency_rupee_rounded,
      'cta': 'Get Free Valuation',
      'tab': 2,
    },
    {
      'tag': 'GARAGE & SERVICE',
      'title': 'Periodic Maintenance &\nEmergency Breakdown',
      'desc': 'Expert Mechanics • Genuine Spares • Live Tracking & Digital Bills',
      'gradient': const [Color(0xFF7C2D12), Color(0xFFC2410C)],
      'icon': Icons.car_repair_rounded,
      'cta': 'Book Service',
      'tab': 3,
    },
  ];

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final vehicleProv = context.watch<UsedVehicleProvider>();
    final customerName = auth.currentUser?.name ?? 'Mr. Sathish Kumar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Location Header & Top Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFFEA580C), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Coimbatore, TN',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Welcome, $customerName 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F2B66),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366), size: 19),
                        tooltip: 'WhatsApp Help',
                        onPressed: () => _openWhatsApp('8951777054', 'Hello Aathava Motors, I need information on vehicles & service.'),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        icon: const Icon(Icons.settings_outlined, color: Color(0xFF0F2B66), size: 20),
                        tooltip: 'Settings & Profile',
                        onPressed: () => widget.onNavigateTab(5),
                      ),
                      const SizedBox(width: 5),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF0F2B66),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
                        tooltip: 'Call Aathava Motors',
                        onPressed: () => _makeCall('9442249149'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: AppColors.softShadow,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (q) => vehicleProv.setSearchQuery(q),
                  decoration: InputDecoration(
                    hintText: 'Search cars, bikes, services or spare parts...',
                    hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F2B66)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              vehicleProv.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Hero Promotional Banners
              _buildHeroCarousel(),
              const SizedBox(height: 20),

              // 4. Aathava Motors 4 Core Gateways
              Text(
                'Everything For Your Vehicle',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _serviceTile(
                    title: 'Buy Vehicles',
                    subtitle: 'Cars & Bikes',
                    icon: Icons.directions_car_filled_rounded,
                    gradient: const [Color(0xFF0F2B66), Color(0xFF1E40AF)],
                    onTap: () => widget.onNavigateTab(1),
                  ),
                  const SizedBox(width: 10),
                  _serviceTile(
                    title: 'Sell Vehicle',
                    subtitle: 'Instant Cash',
                    icon: Icons.currency_rupee_rounded,
                    gradient: const [Color(0xFF059669), Color(0xFF10B981)],
                    onTap: () => widget.onNavigateTab(2),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _serviceTile(
                    title: 'Book Service',
                    subtitle: 'Maintenance',
                    icon: Icons.build_circle_rounded,
                    gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
                    onTap: () => widget.onNavigateTab(3),
                  ),
                  const SizedBox(width: 10),
                  _serviceTile(
                    title: 'My Enquiries',
                    subtitle: 'Track Status',
                    icon: Icons.assignment_turned_in_rounded,
                    gradient: const [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
                    onTap: () => widget.onNavigateTab(4),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Featured Pre-Owned Inventory Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2B66).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.star_rounded, color: Color(0xFF0F2B66), size: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Featured Vehicles',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '120-Point Multi-stage certified',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(1),
                    child: Text(
                      'View All (${vehicleProv.totalCount}) →',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F2B66)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Horizontal Featured Carousel
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vehicleProv.allVehicles.length,
                  itemBuilder: (context, idx) {
                    final v = vehicleProv.allVehicles[idx];
                    return _buildFeaturedVehicleCard(context, v);
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 6. Sell In 3 Steps Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
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
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SELL IN 3 STEPS',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selling Your Car or Bike?\nGet Best Value & Spot Cash!',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _stepPill('1', 'Enter Details'),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white30, size: 12),
                        _stepPill('2', 'Free Valuation'),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white30, size: 12),
                        _stepPill('3', 'Spot Payment'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => widget.onNavigateTab(2),
                        child: Text(
                          'Start Free Valuation Now',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 7. Why Aathava Motors? Trust Factors
              Text(
                'Why Choose Aathava Motors?',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
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
                  children: [
                    _trustItem(
                      Icons.verified_rounded,
                      const Color(0xFF059669),
                      '120-Point Multi-Stage Inspection',
                      'Comprehensive check covering engine, transmission, electricals and frame.',
                    ),
                    const Divider(height: 20),
                    _trustItem(
                      Icons.shield_rounded,
                      const Color(0xFF0F2B66),
                      '6 Months Engine Warranty',
                      'Peace of mind protection with complimentary towing and garage support.',
                    ),
                    const Divider(height: 20),
                    _trustItem(
                      Icons.assignment_turned_in_rounded,
                      const Color(0xFFD97706),
                      'Hassle-Free RC Transfer',
                      '100% verified documents and end-to-end RTO name transfer handling.',
                    ),
                    const Divider(height: 20),
                    _trustItem(
                      Icons.handshake_rounded,
                      const Color(0xFF7C3AED),
                      'Transparent Pricing & Fair Deals',
                      'No hidden fees, honest evaluations, and direct bank spot settlement.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCarousel() {
    final banner = _heroBanners[_activeHeroIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: banner['gradient'] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (banner['gradient'][0] as Color).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  banner['tag'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Row(
                children: List.generate(_heroBanners.length, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _activeHeroIndex = i),
                    child: Container(
                      width: _activeHeroIndex == i ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: _activeHeroIndex == i ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            banner['title'] as String,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            banner['desc'] as String,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.9)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F2B66),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => widget.onNavigateTab(banner['tab'] as int),
                  icon: Icon(banner['icon'] as IconData, size: 15),
                  label: Text(
                    banner['cta'] as String,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 13, color: Colors.white70),
                    onPressed: () {
                      setState(() {
                        _activeHeroIndex = (_activeHeroIndex - 1 + _heroBanners.length) % _heroBanners.length;
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white70),
                    onPressed: () {
                      setState(() {
                        _activeHeroIndex = (_activeHeroIndex + 1) % _heroBanners.length;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedVehicleCard(BuildContext context, UsedVehicleModel v) {
    final isCar = v.isCar;
    // Estimate monthly EMI (48 months @ 10.5%)
    final estEmi = (v.sellingPrice * 0.8 * 0.026).round();

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppColors.softShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UsedVehicleDetailScreen(vehicle: v)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Preview / Badge Header
            Container(
              height: 95,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCar ? const Color(0xFFEFF6FF) : const Color(0xFFFFF7ED),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      isCar ? Icons.directions_car_rounded : Icons.two_wheeler_rounded,
                      size: 50,
                      color: isCar ? const Color(0xFF3B82F6) : const Color(0xFFF97316),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CERTIFIED',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${v.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${v.kmDriven} km • ${v.fuelType} • ${v.transmission}',
                    style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          CurrencyFormatter.format(v.sellingPrice),
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F2B66),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'EMI ₹$estEmi/m',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F2B66),
                        side: const BorderSide(color: Color(0xFF0F2B66)),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => UsedVehicleDetailScreen(vehicle: v)),
                        );
                      },
                      child: Text(
                        'View & Test Drive',
                        style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepPill(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFFF59E0B),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 9.5, color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, Color color, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
