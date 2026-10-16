import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import 'aathava_motors_home_tab.dart';
import 'aathava_motors_buy_tab.dart';
import 'aathava_motors_sell_tab.dart';
import 'aathava_motors_service_tab.dart';
import 'aathava_motors_enquiries_tab.dart';
import 'aathava_motors_settings_tab.dart';

class AathavaMotorsMainShell extends StatefulWidget {
  final int initialTab;

  const AathavaMotorsMainShell({super.key, this.initialTab = 0});

  @override
  State<AathavaMotorsMainShell> createState() => _AathavaMotorsMainShellState();
}

class _AathavaMotorsMainShellState extends State<AathavaMotorsMainShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isTamil = context.watch<LocaleProvider>().isTamil;

    final List<Widget> tabs = [
      AathavaMotorsHomeTab(onNavigateTab: _onTabSelected),
      const AathavaMotorsBuyTab(),
      AathavaMotorsSellTab(
        onValuationSuccess: () {
          _onTabSelected(4); // Switch to My Enquiries tab
        },
      ),
      const AathavaMotorsServiceTab(),
      const AathavaMotorsEnquiriesTab(),
      AathavaMotorsSettingsTab(onNavigateTab: _onTabSelected),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0F2B66),
          unselectedItemColor: const Color(0xFF94A3B8),
          iconSize: 20,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home_rounded),
              label: isTamil ? 'முகப்பு' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.directions_car_outlined),
              activeIcon: const Icon(Icons.directions_car_rounded),
              label: isTamil ? 'வாங்கு' : 'Buy',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.currency_rupee_rounded),
              activeIcon: const Icon(Icons.currency_rupee_rounded),
              label: isTamil ? 'விற்பனை' : 'Sell',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.build_outlined),
              activeIcon: const Icon(Icons.build_rounded),
              label: isTamil ? 'சர்வீஸ்' : 'Service',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment_rounded),
              label: isTamil ? 'விசாரணை' : 'Enquiries',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings_rounded),
              label: isTamil ? 'அமைப்பு' : 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
