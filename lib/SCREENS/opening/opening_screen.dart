import 'package:flutter/material.dart';

import '../login/login_screen.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF00796B);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color emerald = Color(0xFF00A878);

  static const Color background = Color(0xFFF7FBFA);
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF62758A);

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // OPEN LOGIN
  // ============================================================

  void _openLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const LoginScreen();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND DECORATION
            // ==================================================

            Positioned(
              top: -100,
              right: -90,
              child: _circle(
                size: 260,
                color: emerald.withOpacity(0.08),
              ),
            ),

            Positioned(
              top: 170,
              left: -120,
              child: _circle(
                size: 240,
                color: primary.withOpacity(0.055),
              ),
            ),

            Positioned(
              bottom: -120,
              right: -60,
              child: _circle(
                size: 300,
                color: emerald.withOpacity(0.06),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.paddingOf(context).vertical,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    18,
                    24,
                    24,
                  ),
                  child: Column(
                    children: [
                      // ========================================
                      // TOP BRAND
                      // ========================================

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildBrandHeader(),
                      ),

                      const SizedBox(height: 28),

                      // ========================================
                      // HERO
                      // ========================================

                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildHeroIllustration(),
                      ),

                      const SizedBox(height: 28),

                      // ========================================
                      // TEXT
                      // ========================================

                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildWelcomeText(),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ========================================
                      // FEATURES
                      // ========================================

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFeatureRow(),
                      ),

                      const SizedBox(height: 30),

                      // ========================================
                      // GET STARTED
                      // ========================================

                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildGetStartedButton(),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ========================================
                      // FOOTER
                      // ========================================

                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFooter(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BRAND HEADER
  // ============================================================

  Widget _buildBrandHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary,
                emerald,
              ],
            ),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'JAN AROGYA',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Digital Healthcare',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE0ECE8),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_rounded,
                size: 14,
                color: emerald,
              ),
              SizedBox(width: 4),
              Text(
                'Trusted Care',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO ILLUSTRATION
  // ============================================================

  Widget _buildHeroIllustration() {
    return Container(
      width: double.infinity,
      height: 255,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEAFBF7),
            Color(0xFFD5F4EC),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFCBEDE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -55,
            top: -50,
            child: _circle(
              size: 190,
              color: emerald.withOpacity(0.08),
            ),
          ),

          Positioned(
            left: -70,
            bottom: -80,
            child: _circle(
              size: 180,
              color: primary.withOpacity(0.06),
            ),
          ),

          // Medical cross
          Positioned(
            left: 28,
            top: 28,
            child: _floatingIcon(
              Icons.add_rounded,
              Colors.white,
              primary,
            ),
          ),

          // Heart
          Positioned(
            right: 27,
            top: 34,
            child: _floatingIcon(
              Icons.favorite_rounded,
              Colors.white,
              emerald,
            ),
          ),

          // Calendar
          Positioned(
            left: 42,
            bottom: 28,
            child: _floatingIcon(
              Icons.calendar_month_rounded,
              Colors.white,
              const Color(0xFF2878E8),
            ),
          ),

          // Main medical illustration
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.75),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.08),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primary,
                          emerald,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      size: 62,
                      color: Colors.white,
                    ),
                  ),

                  Positioned(
                    right: 14,
                    bottom: 17,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: emerald,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 34,
            bottom: 27,
            child: _floatingIcon(
              Icons.medication_rounded,
              Colors.white,
              const Color(0xFFEF8B17),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WELCOME TEXT
  // ============================================================

  Widget _buildWelcomeText() {
    return Column(
      children: [
        const Text(
          'Your Health,',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 31,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: -1.0,
          ),
        ),

        const Text(
          'Our Priority.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 31,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: primary,
            letterSpacing: -1.0,
          ),
        ),

        const SizedBox(height: 12),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Access appointments, medicines, health records, '
            'emergency services and more — all in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FEATURE ROW
  // ============================================================

  Widget _buildFeatureRow() {
    return Row(
      children: [
        Expanded(
          child: _featureItem(
            Icons.local_hospital_outlined,
            'Hospitals',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _featureItem(
            Icons.video_call_outlined,
            'Consultation',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _featureItem(
            Icons.emergency_outlined,
            'Emergency',
          ),
        ),
      ],
    );
  }

  Widget _featureItem(
    IconData icon,
    String title,
  ) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE0ECE8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 22,
            color: primary,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GET STARTED BUTTON
  // ============================================================

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              primaryDark,
              primary,
              emerald,
            ],
          ),
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.23),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _openLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(19),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: textSecondary,
        ),
        SizedBox(width: 5),
        Text(
          'Your healthcare data stays secure',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CIRCLE
  // ============================================================

  Widget _circle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // ============================================================
  // FLOATING ICON
  // ============================================================

  Widget _floatingIcon(
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    return Container(
      width: 47,
      height: 47,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 23,
      ),
    );
  }
}