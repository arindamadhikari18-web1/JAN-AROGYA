import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/user_service.dart';
import '../profile/patient_registration_screen.dart';
import '../home/home_dashboard.dart';
import '../hospital/hospital_dashboard_screen.dart';
import '../lab/lab_dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String selectedRole;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.selectedRole,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // =====================================================
  // OTP TIMER
  // =====================================================

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 0) {
          timer.cancel();
        } else {
          setState(() {
            _secondsRemaining--;
          });
        }
      },
    );
  }

  // =====================================================
  // GET ENTERED OTP
  // =====================================================

  String get _otp {
    return _controllers
        .map((controller) => controller.text)
        .join();
  }

  // =====================================================
  // VERIFY OTP + MAINTAIN SESSION
  // =====================================================

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the complete 6-digit OTP',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // =================================================
      // CURRENTLY THIS APP USES DEMO OTP VERIFICATION.
      // Any 6-digit OTP is accepted.
      // =================================================

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      // Check if user has already registered
      final userData = await UserService.getUser();

      if (!mounted) return;

      // =================================================
      // ROLE-BASED DASHBOARD
      // =================================================
      await UserService.setLoggedIn(true);

      if (!mounted) return;

      Widget destination;

      if (widget.selectedRole == 'Hospital') {
        destination = const HospitalDashboardScreen();
      } else if (widget.selectedRole == 'Lab Shop' || widget.selectedRole == 'Lab') {
        destination = const LabDashboardScreen();
      } else {
        final userData = await UserService.getUser();

        if (!mounted) return;

        if (userData != null) {
          destination = HomeDashboard(
            userName: userData['userName'] ?? '',
            userAge: userData['userAge'] ?? '',
            userGender: userData['userGender'] ?? '',
            userCity: userData['userCity'] ?? '',
            bloodGroup: userData['bloodGroup'] ?? '',
            emergencyContact: userData['emergencyContact'] ?? '',
          );
        } else {
          destination = const PatientRegistrationScreen();
        }
      }

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, animation, __) => destination,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          ),
        ),
        (route) => false,
      );

      return;

      // =================================================
      // NEW USER
      // =================================================
      // User registration screen par jayega.
      // Registration complete hone par UserService.saveUser()
      // automatically:
      //
      // isRegistered = true
      // isLoggedIn = true
      //
      // set kar raha hai.

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration:
              const Duration(milliseconds: 450),
          pageBuilder: (_, animation, __) =>
              const PatientRegistrationScreen(),
          transitionsBuilder:
              (_, animation, __, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        ),
      );
    } catch (e) {
      debugPrint('OTP verification error: $e');

      if (!mounted) return;

      setState(() {
        _isVerifying = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
          ),
        ),
      );
    }
  }

  // =====================================================
  // RESEND OTP
  // =====================================================

  void _resendOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {});

    _focusNodes.first.requestFocus();
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A new OTP has been sent successfully!',
        ),
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _timer?.cancel();

    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  // =====================================================
  // OTP INPUT BOX
  // =====================================================

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 58,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        enabled: !_isVerifying,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppTheme.primary,
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }

          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          setState(() {});
        },
      ),
    );
  }

  // =====================================================
  // MAIN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            28,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                onPressed:
                    _isVerifying
                        ? null
                        : () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                padding: EdgeInsets.zero,
              ),

              const SizedBox(height: 28),

              // OTP Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppTheme.primary,
                  size: 38,
                ),
              ),

              const SizedBox(height: 30),

              // Title
              Text(
                'Verify your\nmobile number',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      fontSize: 34,
                      height: 1.15,
                    ),
              ),

              const SizedBox(height: 14),

              Text(
                'We sent a 6-digit verification code to',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge,
              ),

              const SizedBox(height: 4),

              Text(
                '+91 ${widget.phoneNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 40),

              // OTP Boxes
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => _buildOtpBox(index),
                ),
              ),

              const SizedBox(height: 20),

              // Resend Timer
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      )
                    : TextButton(
                        onPressed:
                            _isVerifying
                                ? null
                                : _resendOtp,
                        child: const Text(
                          'Resend OTP',
                        ),
                      ),
              ),

              const SizedBox(height: 42),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _otp.length == 6 && !_isVerifying
                          ? _verifyOtp
                          : null,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify OTP',
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Change Number
              Center(
                child: TextButton(
                  onPressed:
                      _isVerifying
                          ? null
                          : () => Navigator.pop(context),
                  child: const Text(
                    'Change mobile number',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}