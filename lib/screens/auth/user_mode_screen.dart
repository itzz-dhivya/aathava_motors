import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class UserModeScreen extends StatelessWidget {
  const UserModeScreen({super.key});

  void _onSelectRole(BuildContext context, UserRole role) {
    final auth = context.read<AuthProvider>();
    auth.setSelectedRole(role);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(initialRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isTamil = locale.isTamil;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Clean white background
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Branding Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.navyGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F2B66).withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.car_repair_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AATHAVA MOTORS',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F2B66),
                                  letterSpacing: 0.8,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Buy • Sell • Rent • Service',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => locale.toggleLanguage(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language, size: 14, color: Color(0xFF0F2B66)),
                          const SizedBox(width: 4),
                          Text(
                            isTamil ? 'English' : 'தமிழ்',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F2B66),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTamil ? 'பயனர் முறை தேர்வு செய்க' : 'Select Access Portal',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth < 360 ? 20 : 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F2B66),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isTamil
                        ? 'உங்கள் பயன்பாட்டிற்குரிய முறையைத் தேர்ந்தெடுக்கவும்'
                        : 'Choose your role to launch tailored workspace & controls',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // 3 White Cards with Grey Shadows & Colorful Gradient Accents
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: [
                  // 1. ADMIN CONTAINER
                  _roleCard(
                    context: context,
                    role: UserRole.admin,
                    title: isTamil ? 'பணிமனை உரிமையாளர் / அட்மின்' : 'Garage Admin & Owner',
                    badge: isTamil ? 'முழு கட்டுப்பாடு' : 'MASTER CONTROL',
                    badgeColor: const Color(0xFF1E40AF),
                    badgeBg: const Color(0xFFDBEAFE),
                    accentColor: const Color(0xFF1E3A8A),
                    iconGradient: AppColors.adminGradient,
                    icon: Icons.admin_panel_settings_rounded,
                    description: isTamil
                        ? 'பில்லிங், உதிரிபாக இருப்பு, பணியாளர்கள் ஒதுக்கீடு, ஜிஎஸ்டி மற்றும் வரவு-செலவு கணக்குகள்.'
                        : 'Complete workshop management, smart GST billing, live inventory stock, staff jobs, & revenue analytics.',
                    features: [
                      '🧾 GST Billing & Quick Invoices',
                      '⚙️ Spare Parts Stock & Barcode',
                      '👨‍🔧 Mechanics Job Allocation',
                      '📊 Profit & Loss Reports',
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. USER / CUSTOMER CONTAINER
                  _roleCard(
                    context: context,
                    role: UserRole.user,
                    title: isTamil ? 'வாடிக்கையாளர் போர்டல்' : 'Customer & Vehicle Buyer/Seller',
                    badge: isTamil ? 'ஆதவா மோட்டார்ஸ்' : 'AATHAVA MOTORS HUB',
                    badgeColor: const Color(0xFF065F46),
                    badgeBg: const Color(0xFFD1FAE5),
                    accentColor: const Color(0xFF10B981),
                    iconGradient: AppColors.userGradient,
                    icon: Icons.directions_car_filled_rounded,
                    description: isTamil
                        ? 'செகண்ட்-ஹேண்ட் கார்கள்/பைக்கள் வாங்குதல், விற்பனை செய்தல், சர்வீஸ் முன்பதிவு மற்றும் லைவ் ஸ்டேட்டஸ்.'
                        : 'Buy certified pre-owned cars/bikes, get instant cash valuation to sell your vehicle, book garage service, & track enquiries.',
                    features: [
                      '🚗 Buy Certified Pre-Owned Cars & Bikes',
                      '💰 Sell Your Vehicle with Instant Valuation',
                      '🛠️ Book Garage Service & Doorstep Pickup',
                      '📋 My Enquiries & Test Drive Schedules',
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. WORKER / MECHANIC CONTAINER
                  _roleCard(
                    context: context,
                    role: UserRole.worker,
                    title: isTamil ? 'மெக்கானிக் / பணிமனை பணியாளர்' : 'Mechanic / Garage Technician',
                    badge: isTamil ? 'தொழில்நுட்ப தளம்' : 'WORKSHOP FLOOR',
                    badgeColor: const Color(0xFF9A3412),
                    badgeBg: const Color(0xFFFFEDD5),
                    accentColor: const Color(0xFFF97316),
                    iconGradient: AppColors.workerGradient,
                    icon: Icons.construction_rounded,
                    description: isTamil
                        ? 'இன்றைய பணி அட்டைகள் (Job Cards), 8-அம்ச வாகன பரிசோதனை மற்றும் உதிரிபாக கோரிக்கைகள்.'
                        : 'Today\'s assigned vehicle job cards, 8-point inspection checklist, status updater, & store parts lookup.',
                    features: [
                      '📋 Today\'s Assigned Job Cards',
                      '🔍 8-Point Vehicle Checklist',
                      '⚡ Quick Status (Start / Ready)',
                      '📦 Request Store Spares Directly',
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required Color accentColor,
    required LinearGradient iconGradient,
    required IconData icon,
    required String description,
    required List<String> features,
  }) {
    final isTamil = context.watch<LocaleProvider>().isTamil;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Crisp White Background
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: AppColors.softShadow, // Grey Shadow
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _onSelectRole(context, role),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Gradient Icon Badge, Role Name, Badge Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: iconGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Feature tags
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: features.map((feat) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        feat,
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Action Button: Full-width Enter Portal (No clipping, completely visible)
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2B66),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F2B66).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _onSelectRole(context, role),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.login_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? 'உள்நுழைக' : 'Enter Portal',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
