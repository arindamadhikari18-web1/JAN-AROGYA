import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'services/user_service.dart';
import 'services/notification_service.dart';

import 'SCREENS/auth/login_screen.dart';
import 'SCREENS/home/home_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.initialize();

  runApp(const JanArogyaApp());
}

// =====================================================
// MAIN APP + LANGUAGE MANAGEMENT
// =====================================================

class JanArogyaApp extends StatefulWidget {
  const JanArogyaApp({super.key});

  static _JanArogyaAppState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LanguageProvider>()
        ?.appState;
  }

  @override
  State<JanArogyaApp> createState() => _JanArogyaAppState();
}

class _JanArogyaAppState extends State<JanArogyaApp> {
  String _currentLanguageCode = 'en';

  bool _isLanguageLoaded = false;

  String get currentLanguageCode => _currentLanguageCode;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  // =====================================================
  // LOAD SAVED LANGUAGE
  // =====================================================

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedLanguage =
          prefs.getString('app_language') ?? 'en';

      // Allow only supported languages
      const supportedLanguages = [
        'en',
        'hi',
        'bn',
      ];

      final validLanguage =
          supportedLanguages.contains(savedLanguage)
              ? savedLanguage
              : 'en';

      if (!mounted) return;

      setState(() {
        _currentLanguageCode = validLanguage;
        _isLanguageLoaded = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _currentLanguageCode = 'en';
        _isLanguageLoaded = true;
      });
    }
  }

  // =====================================================
  // CHANGE + SAVE LANGUAGE PERMANENTLY
  // =====================================================

  Future<void> changeLanguage(
    String languageCode,
  ) async {
    const supportedLanguages = [
      'en',
      'hi',
      'bn',
    ];

    if (!supportedLanguages.contains(languageCode)) {
      return;
    }

    // Update UI immediately
    if (mounted) {
      setState(() {
        _currentLanguageCode = languageCode;
      });
    }

    // Save permanently
    try {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'app_language',
        languageCode,
      );
    } catch (e) {
      // Language still changes for current session
      // even if SharedPreferences fails.
    }
  }

  // =====================================================
  // BUILD APP
  // =====================================================

  @override
  Widget build(BuildContext context) {
    // Wait until saved language is loaded.
    if (!_isLanguageLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _LanguageLoadingScreen(),
      );
    }

    return _LanguageProvider(
      languageCode: _currentLanguageCode,
      appState: this,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'JAN AROGYA',
        theme: AppTheme.lightTheme,

        // This key helps Flutter rebuild the app
        // when the selected language changes.
        key: ValueKey(_currentLanguageCode),

        home: const SplashScreen(),
      ),
    );
  }
}

// =====================================================
// LANGUAGE PROVIDER
// =====================================================

class _LanguageProvider extends InheritedWidget {
  final String languageCode;
  final _JanArogyaAppState appState;

  const _LanguageProvider({
    required this.languageCode,
    required this.appState,
    required super.child,
  });

  @override
  bool updateShouldNotify(
    _LanguageProvider oldWidget,
  ) {
    return oldWidget.languageCode != languageCode;
  }
}

// =====================================================
// LANGUAGE LOADING SCREEN
// =====================================================

class _LanguageLoadingScreen extends StatelessWidget {
  const _LanguageLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}

// =====================================================
// SPLASH SCREEN
// =====================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // =====================================================
  // TRANSLATION HELPER
  // =====================================================

  String get _languageCode =>
      JanArogyaApp.of(context)?.currentLanguageCode ??
          'en';

  String _t(
    String english,
    String hindi,
    String bengali,
  ) {
    switch (_languageCode) {
      case 'hi':
        return hindi;

      case 'bn':
        return bengali;

      default:
        return english;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    _checkUserAndNavigate();
  }

  // =====================================================
  // CHECK SESSION AND NAVIGATE
  // =====================================================

  Future<void> _checkUserAndNavigate() async {
    // Splash screen visible for 3 seconds
    await Future.delayed(
      const Duration(seconds: 3),
    );

    // Check registration status
    final bool isRegistered =
        await UserService.isUserRegistered();

    // Check login session status
    final bool isLoggedIn =
        await UserService.isLoggedIn();

    // Get saved user data
    final userData =
        await UserService.getUser();

    if (!mounted) return;

    // =====================================================
    // CASE 1:
    // USER REGISTERED + SESSION ACTIVE
    // DIRECTLY OPEN HOME DASHBOARD
    // =====================================================

    if (isRegistered &&
        isLoggedIn &&
        userData != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration:
              const Duration(milliseconds: 600),
          pageBuilder: (_, animation, __) {
            return HomeDashboard(
              userName:
                  userData['userName']?.toString() ?? '',
              userAge:
                  userData['userAge']?.toString() ?? '',
              userGender:
                  userData['userGender']?.toString() ?? '',
              userCity:
                  userData['userCity']?.toString() ?? '',
              bloodGroup:
                  userData['bloodGroup']?.toString() ?? '',
              emergencyContact:
                  userData['emergencyContact']
                          ?.toString() ??
                      '',
            );
          },
          transitionsBuilder:
              (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );

      return;
    }

    // =====================================================
    // CASE 2:
    // USER REGISTERED BUT LOGGED OUT
    // OPEN LOGIN SCREEN
    // =====================================================

    if (isRegistered && !isLoggedIn) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration:
              const Duration(milliseconds: 600),
          pageBuilder: (_, animation, __) {
            return const LoginScreen();
          },
          transitionsBuilder:
              (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );

      return;
    }

    // =====================================================
    // CASE 3:
    // NEW USER
    // OPEN WELCOME SCREEN
    // =====================================================

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) {
          return const WelcomeScreen();
        },
        transitionsBuilder:
            (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =====================================================
  // SPLASH UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Health Logo
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.12,
                      ),
                      borderRadius:
                          BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          0.25,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Name
                  const Text(
                    'JAN AROGYA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Text(
                      _t(
                        'Healthcare that stays connected\n'
                        'with every step of your journey.',
                        'स्वास्थ्य सेवा जो आपकी यात्रा के\n'
                        'हर कदम पर आपके साथ जुड़ी रहे।',
                        'স্বাস্থ্যসেবা যা আপনার যাত্রার\n'
                        'প্রতিটি ধাপে আপনার সঙ্গে থাকে।',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Bottom Security Badge
                  Container(
                    margin: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(
                        0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          0.15,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white70,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _t(
                            'Secure • Connected • Trusted',
                            'सुरक्षित • जुड़ा हुआ • विश्वसनीय',
                            'নিরাপদ • সংযুক্ত • বিশ্বস্ত',
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// WELCOME SCREEN
// =====================================================

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // =====================================================
  // LANGUAGE
  // =====================================================

  String _getLanguageCode(
    BuildContext context,
  ) {
    return JanArogyaApp.of(context)
            ?.currentLanguageCode ??
        'en';
  }

  String _t(
    BuildContext context,
    String english,
    String hindi,
    String bengali,
  ) {
    switch (_getLanguageCode(context)) {
      case 'hi':
        return hindi;

      case 'bn':
        return bengali;

      default:
        return english;
    }
  }

  // =====================================================
  // OPEN LOGIN
  // =====================================================

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 450),
        reverseTransitionDuration:
            const Duration(milliseconds: 350),
        pageBuilder: (_, animation, __) {
          return const LoginScreen();
        },
        transitionsBuilder:
            (_, animation, __, child) {
          final slideAnimation =
              Tween<Offset>(
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
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // WELCOME UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24,
            40,
            24,
            28,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.primary,
                  size: 36,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                _t(
                  context,
                  'Your health,\ncloser to you.',
                  'आपका स्वास्थ्य,\nआपके और करीब।',
                  'আপনার স্বাস্থ্য,\nআপনার আরও কাছে।',
                ),
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(
                      fontSize: 38,
                      height: 1.12,
                    ),
              ),

              const SizedBox(height: 16),

              Text(
                _t(
                  context,
                  'Book appointments, access health records, '
                  'find nearby healthcare facilities and stay '
                  'connected throughout your healthcare journey.',
                  'अपॉइंटमेंट बुक करें, स्वास्थ्य रिकॉर्ड देखें, '
                  'नजदीकी स्वास्थ्य सुविधाएँ खोजें और अपनी पूरी '
                  'स्वास्थ्य यात्रा में जुड़े रहें।',
                  'অ্যাপয়েন্টমেন্ট বুক করুন, স্বাস্থ্য রেকর্ড দেখুন, '
                  'কাছাকাছি স্বাস্থ্যসেবা কেন্দ্র খুঁজুন এবং আপনার '
                  'সম্পূর্ণ স্বাস্থ্য যাত্রায় সংযুক্ত থাকুন।',
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      height: 1.5,
                    ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () =>
                      _openLogin(context),
                  child: Text(
                    _t(
                      context,
                      'Get Started',
                      'शुरू करें',
                      'শুরু করুন',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: Text(
                  _t(
                    context,
                    'Secure healthcare access for everyone',
                    'सभी के लिए सुरक्षित स्वास्थ्य सेवा',
                    'সবার জন্য নিরাপদ স্বাস্থ্যসেবা',
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        fontSize: 13,
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