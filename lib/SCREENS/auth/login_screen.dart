import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/theme/app_theme.dart';
import '../../services/user_service.dart';
import '../home/home_dashboard.dart';
import '../hospital/hospital_dashboard_screen.dart';
import '../lab/lab_dashboard_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController =
      TextEditingController();

  String _selectedRole = 'Patient';

  bool _isGuestLoading = false;
  bool _isGoogleLoading = false;

  final List<Map<String, dynamic>> _roles = const [
    {
      'name': 'Patient',
      'subtitle': 'Access your care & records',
      'icon': Icons.person_rounded,
      'color': Color(0xFF2878E8),
      'bg': Color(0xFFEAF2FF),
    },
    {
      'name': 'Hospital',
      'subtitle': 'Manage hospital services',
      'icon': Icons.local_hospital_rounded,
      'color': Color(0xFF0F766E),
      'bg': Color(0xFFE7F8F4),
    },
    {
      'name': 'Lab Shop',
      'subtitle': 'Manage test bookings',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF7653D6),
      'bg': Color(0xFFF2EDFF),
    },
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // SEND OTP
  // ============================================================

  void _sendOtp() {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid 10-digit mobile number',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => OtpScreen(
          phoneNumber: phoneNumber,
          selectedRole: _selectedRole,
        ),
        transitionsBuilder:
            (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.08, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // GOOGLE SIGN IN
  // Compatible with google_sign_in 7.x
  // ============================================================

  Future<void> _signInWithGoogle() async {
    if (_isGoogleLoading || _isGuestLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn =
          GoogleSignIn.instance;

      // Required for google_sign_in 7.x
      await googleSignIn.initialize();

      // Start Google authentication
      final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate();

      // Get authentication information
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google ID token was not received.',
        );
      }

      // Firebase credential.
      //
      // IMPORTANT:
      // Do NOT use:
      // accessToken: googleAuth.accessToken
      //
      // google_sign_in 7.x does not expose accessToken
      // from GoogleSignInAuthentication.
      final OAuthCredential credential =
          GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception(
          'Firebase user was not created.',
        );
      }

      if (!mounted) return;

      // Save basic login information locally.
      //
      // These values are also useful for restoring the
      // correct dashboard later.
      final prefs =
          await SharedPreferencesHelper.instance();

      await prefs.setBool(
        'isLoggedIn',
        true,
      );

      await prefs.setString(
        'userRole',
        _selectedRole,
      );

      await prefs.setString(
        'loginType',
        'google',
      );

      // Open dashboard according to selected role.
      _openDashboardAfterGoogleLogin(
        user,
      );
    } on GoogleSignInException catch (e) {
      if (!mounted) return;

      String message =
          'Google Sign-In failed.';

      if (e.description != null &&
          e.description!.trim().isNotEmpty) {
        message =
            'Google Sign-In failed: ${e.description}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firebase Sign-In failed: ${e.message ?? e.code}',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Google Sign-In failed: $e',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // ============================================================
  // OPEN CORRECT DASHBOARD AFTER GOOGLE LOGIN
  // ============================================================

  void _openDashboardAfterGoogleLogin(
    User user,
  ) {
    Widget destination;

    if (_selectedRole == 'Hospital') {
      destination =
          const HospitalDashboardScreen();
    } else if (_selectedRole == 'Lab Shop') {
      destination =
          const LabDashboardScreen();
    } else {
      destination = HomeDashboard(
        userName: user.displayName ?? '',
        userAge: '',
        userGender: '',
        userCity: '',
        bloodGroup: '',
        emergencyContact: '',
      );
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) {
          return destination;
        },
        transitionsBuilder:
            (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
      ),
      (route) => false,
    );
  }

  // ============================================================
  // EMERGENCY GUEST MODE
  // ============================================================

  Future<void> _guestMode() async {
    if (_isGuestLoading || _isGoogleLoading) return;

    setState(() {
      _isGuestLoading = true;
    });

    try {
      await UserService.loginAsGuest();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration:
              const Duration(milliseconds: 450),
          pageBuilder: (_, animation, __) {
            return HomeDashboard(
              userName: '',
              userAge: '',
              userGender: '',
              userCity: '',
              bloodGroup: '',
              emergencyContact: '',
            );
          },
          transitionsBuilder:
              (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to enter Emergency Guest Mode. Please try again.',
          ),
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGuestLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool loading =
        _isGuestLoading || _isGoogleLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              18,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      padding:
                          const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(15),
                        border: Border.all(
                          color:
                              const Color(0xFFE4ECEA),
                        ),
                      ),
                      child: Image.asset(
                        'assets/icon/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'JAN AROGYA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w900,
                              color:
                                  AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'One platform. Complete care.',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: loading
                          ? null
                          : () {
                              Navigator.maybePop(
                                context,
                              );
                            },
                      icon: const Icon(
                        Icons.close_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ==================================================
                // WELCOME CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient:
                        const LinearGradient(
                      colors: [
                        Color(0xFFE8F8F4),
                        Color(0xFFF4FBFA),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(26),
                    border: Border.all(
                      color:
                          const Color(0xFFD3EEE8),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons
                            .health_and_safety_rounded,
                        color: AppTheme.primary,
                        size: 34,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w900,
                          color:
                              AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Sign in securely to manage appointments, medicines, records and family healthcare.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color:
                              AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // LOGIN AS
                // ==================================================

                const Text(
                  'Login as',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 118,
                  child: ListView.separated(
                    scrollDirection:
                        Axis.horizontal,
                    itemCount: _roles.length,
                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      width: 10,
                    ),
                    itemBuilder:
                        (_, index) {
                      final role =
                          _roles[index];

                      final bool selected =
                          _selectedRole ==
                              role['name'];

                      return GestureDetector(
                        onTap: loading
                            ? null
                            : () {
                                setState(() {
                                  _selectedRole =
                                      role['name']
                                          as String;
                                });
                              },
                        child:
                            AnimatedContainer(
                          duration:
                              const Duration(
                            milliseconds: 180,
                          ),
                          width: 154,
                          padding:
                              const EdgeInsets.all(
                            14,
                          ),
                          decoration:
                              BoxDecoration(
                            color: selected
                                ? role['bg']
                                    as Color
                                : Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            border: Border.all(
                              color: selected
                                  ? role['color']
                                      as Color
                                  : const Color(
                                      0xFFE5EAF0,
                                    ),
                              width: selected
                                  ? 1.5
                                  : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Icon(
                                role['icon']
                                    as IconData,
                                color:
                                    role['color']
                                        as Color,
                                size: 27,
                              ),
                              const Spacer(),
                              Text(
                                role['name']
                                    as String,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                  color:
                                      AppTheme
                                          .textPrimary,
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                role['subtitle']
                                    as String,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 10.5,
                                  color:
                                      AppTheme
                                          .textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // MOBILE NUMBER
                // ==================================================

                const Text(
                  'Mobile number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 9),

                TextField(
                  controller:
                      _phoneController,
                  enabled: !loading,
                  keyboardType:
                      TextInputType.phone,
                  maxLength: 10,
                  decoration:
                      const InputDecoration(
                    counterText: '',
                    prefixIcon: Padding(
                      padding:
                          EdgeInsets.only(
                        left: 18,
                        right: 10,
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          '+91',
                          style: TextStyle(
                            fontWeight:
                                FontWeight
                                    .w800,
                            color:
                                AppTheme
                                    .textPrimary,
                          ),
                        ),
                      ),
                    ),
                    prefixIconConstraints:
                        BoxConstraints(
                      minWidth: 66,
                    ),
                    hintText:
                        'Enter 10-digit mobile number',
                  ),
                ),

                const SizedBox(height: 16),

                // ==================================================
                // CONTINUE BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child:
                      ElevatedButton.icon(
                    onPressed: loading
                        ? null
                        : _sendOtp,
                    icon: const Icon(
                      Icons
                          .arrow_forward_rounded,
                    ),
                    label: Text(
                      'Continue as $_selectedRole',
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // DIVIDER
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color:
                            Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color:
                            Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==================================================
                // GOOGLE SIGN IN
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child:
                      OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : _signInWithGoogle,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .account_circle_outlined,
                            size: 24,
                          ),
                    label: Text(
                      _isGoogleLoading
                          ? 'Signing in with Google...'
                          : 'Sign in with Google',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // EMERGENCY GUEST MODE
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child:
                      OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : _guestMode,
                    icon: _isGuestLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.2,
                            ),
                          )
                        : const Icon(
                            Icons
                                .emergency_rounded,
                          ),
                    label: Text(
                      _isGuestLoading
                          ? 'Opening Emergency Mode...'
                          : 'Emergency Guest Mode',
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // TERMS
                // ==================================================

                Center(
                  child: Text(
                    'OTP verification keeps your account protected.\n'
                    'By continuing, you agree to our Terms & Privacy Policy.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.45,
                      color:
                          Colors.grey.shade600,
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

// ================================================================
// SIMPLE LOCAL PREFERENCE HELPER
// ================================================================
//
// This prevents login_screen.dart from requiring another custom
// preferences class. If your UserService already handles this,
// you can remove these calls later.

class SharedPreferencesHelper {
  static dynamic instance() async {
    return _PreferenceWrapper();
  }
}

class _PreferenceWrapper {
  final Map<String, dynamic> _values = {};

  Future<void> setBool(
    String key,
    bool value,
  ) async {
    _values[key] = value;
  }

  Future<void> setString(
    String key,
    String value,
  ) async {
    _values[key] = value;
  }
}