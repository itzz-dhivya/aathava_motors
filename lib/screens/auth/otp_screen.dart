import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/localization/app_locale.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../home/home_dashboard_screen.dart';
import '../worker_portal/worker_home_screen.dart';
import '../aathava_motors/aathava_motors_main_shell.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final UserRole role;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.role,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendCountdown = 30;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendCountdown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
        setState(() => _resendCountdown = 0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _quickFillDemoOtp() {
    const demo = '123456';
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = demo[i];
    }
    _verifyOtp();
  }

  void _verifyOtp() async {
    final otpCode = _otp;
    if (otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 6-digit OTP code'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.loginWithPhoneOtp(
      widget.phone,
      otpCode,
      targetRole: widget.role,
    );
    setState(() => _isVerifying = false);

    if (success && mounted) {
      Widget nextScreen;
      switch (widget.role) {
        case UserRole.admin:
          nextScreen = const HomeDashboardScreen();
          break;
        case UserRole.user:
          nextScreen = const AathavaMotorsMainShell();
          break;
        case UserRole.worker:
          nextScreen = const WorkerHomeScreen();
          break;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    } else if (auth.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isTamil = locale.isTamil;

    Color themeColor;
    LinearGradient headerGradient;
    String roleLabel;

    switch (widget.role) {
      case UserRole.admin:
        themeColor = const Color(0xFF0F2B66);
        headerGradient = AppColors.adminGradient;
        roleLabel = isTamil ? 'அட்மின் போர்டல்' : 'Garage Admin Mode';
        break;
      case UserRole.user:
        themeColor = const Color(0xFF059669);
        headerGradient = AppColors.userGradient;
        roleLabel = isTamil ? 'வாடிக்கையாளர் போர்டல்' : 'Customer Portal';
        break;
      case UserRole.worker:
        themeColor = const Color(0xFFEA580C);
        headerGradient = AppColors.workerGradient;
        roleLabel = isTamil ? 'மெக்கானிக் தளம்' : 'Mechanic Workshop Floor';
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // White Background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F2B66), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: headerGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              roleLabel,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // Shield Icon with Pulse Ring
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: themeColor.withValues(alpha: 0.1),
                  border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Center(
                  child: Icon(Icons.mark_email_read_rounded, size: 38, color: themeColor),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isTamil ? 'OTP குறியீட்டு சரிபார்ப்பு' : 'Verification Code',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F2B66),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                isTamil
                    ? 'உங்கள் மொபைல் எண்ணிற்கு 6 இலக்க OTP அனுப்பப்பட்டுள்ளது'
                    : 'We have sent a 6-digit verification code to',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '+91 ${widget.phone}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      isTamil ? 'மாற்று' : 'Edit',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // White Card for OTP input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: AppColors.softShadow,
                ),
                child: Column(
                  children: [
                    // 6 Individual OTP Input Boxes (Auto-scaling with zero overflow)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = ((constraints.maxWidth - 30) / 6).clamp(38.0, 48.0);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: itemWidth,
                              height: 56,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                      width: 2.2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  if (val.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else if (val.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                  if (_otp.length == 6) {
                                    _verifyOtp();
                                  }
                                },
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Quick Fill Demo OTP Chip
                    InkWell(
                      onTap: _quickFillDemoOtp,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on_rounded, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isTamil ? 'சோதனை குறியீடு (123456) நிரப்பு' : 'Auto-fill Demo OTP: 123456',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFB45309),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F2B66),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isVerifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                isTamil ? 'சரிபார்த்து தொடர்க' : 'Verify & Enter Garage',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Resend Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isTamil ? 'குறியீடு கிடைக்கவில்லையா? ' : "Didn't receive the code? ",
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  if (_resendCountdown > 0)
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _startCountdown,
                      child: Text(
                        isTamil ? 'மீண்டும் அனுப்பு' : 'Resend OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
