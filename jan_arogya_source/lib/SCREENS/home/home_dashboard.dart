import 'package:flutter/material.dart';

import '../../services/appointment_service.dart';
import '../../services/medicine_service.dart';

import '../ai_chatbot/ai_chatbot_screen.dart';
import '../appointments/book_appointment_screen.dart';
import '../appointments/my_appointments_screen.dart';
import '../emergency/emergency_screen.dart';
import '../family/family_profiles_screen.dart';
import '../medicine/medicine_reminder_screen.dart';
import '../profile/profile_screen.dart';
import '../records/health_records_screen.dart';

class HomeDashboard extends StatefulWidget {
  final String userName;
  final String userAge;
  final String userGender;
  final String userCity;
  final String bloodGroup;
  final String emergencyContact;

  const HomeDashboard({
    super.key,
    required this.userName,
    required this.userAge,
    required this.userGender,
    required this.userCity,
    required this.bloodGroup,
    required this.emergencyContact,
  });

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primary = Color(0xFF00796B);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color emerald = Color(0xFF00A878);

  static const Color background = Color(0xFFF7FAF9);
  static const Color white = Colors.white;

  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF62758A);
  static const Color border = Color(0xFFE0ECE8);

  static const Color blue = Color(0xFF2878E8);
  static const Color blueLight = Color(0xFFEAF2FF);

  static const Color orange = Color(0xFFEF8B17);
  static const Color orangeLight = Color(0xFFFFF3E1);

  static const Color purple = Color(0xFF7653D6);
  static const Color purpleLight = Color(0xFFF2EDFF);

  static const Color red = Color(0xFFD94A42);
  static const Color redLight = Color(0xFFFFEEEE);

  static const Color mint = Color(0xFFE8F8F4);
  static const Color mintStrong = Color(0xFFD2F1E9);

  // ============================================================
  // DASHBOARD DATA
  // ============================================================

  int upcomingAppointments = 0;
  int totalMedicines = 0;
  int medicinesTaken = 0;
  int pendingMedicines = 0;

  bool isLoading = true;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

  Future<void> _loadDashboard() async {
    try {
      final appointments =
          await AppointmentService.getUpcomingAppointments();

      final medicines =
          await MedicineService.getMedicines();

      final taken =
          await MedicineService.getTakenMedicines();

      final pending =
          await MedicineService.getPendingMedicines();

      if (!mounted) return;

      setState(() {
        upcomingAppointments = appointments.length;
        totalMedicines = medicines.length;
        medicinesTaken = taken.length;
        pendingMedicines = pending.length;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // LOCALIZATION
  // ============================================================

  String t(
    String english,
    String hindi,
    String bengali,
  ) {
    final language =
        Localizations.localeOf(context).languageCode;

    if (language == 'hi') {
      return hindi;
    }

    if (language == 'bn') {
      return bengali;
    }

    return english;
  }

  // ============================================================
  // GREETING
  // ============================================================

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return t(
        'Good Morning 👋',
        'सुप्रभात 👋',
        'সুপ্রভাত 👋',
      );
    }

    if (hour < 17) {
      return t(
        'Good Afternoon 👋',
        'शुभ दोपहर 👋',
        'শুভ অপরাহ্ন 👋',
      );
    }

    return t(
      'Good Evening 👋',
      'शुभ संध्या 👋',
      'শুভ সন্ধ্যা 👋',
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _openScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration:
            const Duration(milliseconds: 280),
        reverseTransitionDuration:
            const Duration(milliseconds: 220),
        pageBuilder:
            (context, animation, secondaryAnimation) {
          return screen;
        },
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
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
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: background,
        colorScheme:
            ColorScheme.fromSeed(
          seedColor: primary,
        ),
      ),
      child: Scaffold(
        backgroundColor: background,

        // ======================================================
        // APP BAR
        // ======================================================

        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: background,
          elevation: 0,
          surfaceTintColor:
              Colors.transparent,
          toolbarHeight: 92,
          titleSpacing: 0,
          title: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              22,
              8,
              22,
              0,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style:
                      const TextStyle(
                    fontSize: 14.5,
                    fontWeight:
                        FontWeight.w500,
                    color:
                        textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Welcome, ${widget.userName}',
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 25,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        textPrimary,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ======================================================
        // BODY
        // ======================================================

        body: SafeArea(
          top: false,
          child:
              SingleChildScrollView(
            physics:
                const BouncingScrollPhysics(),
            padding:
                const EdgeInsets.only(
              bottom: 25,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                _buildHeroCard(),

                const SizedBox(height: 28),

                _sectionTitle(
                  t(
                    'Health Overview',
                    'स्वास्थ्य अवलोकन',
                    'স্বাস্থ্য সংক্ষিপ্তসার',
                  ),
                ),

                const SizedBox(height: 14),

                _buildHealthOverview(),

                const SizedBox(height: 24),

                _buildMedicineProgress(),

                const SizedBox(height: 27),

                _sectionTitle(
                  t(
                    'Upcoming Appointment',
                    'आगामी अपॉइंटमेंट',
                    'আসন্ন অ্যাপয়েন্টমেন্ট',
                  ),
                ),

                const SizedBox(height: 14),

                _buildNextAppointment(),

                const SizedBox(height: 28),

                _sectionTitle(
                  t(
                    'Quick Services',
                    'त्वरित सेवाएं',
                    'দ্রুত পরিষেবা',
                  ),
                ),

                const SizedBox(height: 14),

                _buildServices(),

                const SizedBox(height: 28),

                _buildHealthTip(),
              ],
            ),
          ),
        ),

        // ======================================================
        // BOTTOM NAVIGATION
        // ======================================================

        bottomNavigationBar:
            NavigationBar(
          height: 76,
          backgroundColor:
              Colors.white,
          elevation: 8,
          selectedIndex: 0,
          indicatorColor:
              mintStrong,
          onDestinationSelected:
              (index) {
            if (index == 0) return;

            if (index == 1) {
              _openScreen(
                const MyAppointmentsScreen(),
              );
            }

            if (index == 2) {
              _openScreen(
                const HealthRecordsScreen(),
              );
            }

            if (index == 3) {
              _openScreen(
                ProfileScreen(
                  userName:
                      widget.userName,
                  userAge:
                      widget.userAge,
                  userGender:
                      widget.userGender,
                  userCity:
                      widget.userCity,
                  bloodGroup:
                      widget.bloodGroup,
                  emergencyContact:
                      widget.emergencyContact,
                ),
              );
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(
                Icons.home_outlined,
              ),
              selectedIcon:
                  const Icon(
                Icons.home,
              ),
              label: t(
                'Home',
                'होम',
                'হোম',
              ),
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.calendar_month_outlined,
              ),
              selectedIcon:
                  const Icon(
                Icons.calendar_month,
              ),
              label: t(
                'Appointments',
                'अपॉइंटमेंट',
                'অ্যাপয়েন্টমেন্ট',
              ),
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.folder_copy_outlined,
              ),
              selectedIcon:
                  const Icon(
                Icons.folder_copy,
              ),
              label: t(
                'Records',
                'रिकॉर्ड',
                'রেকর্ড',
              ),
            ),
            NavigationDestination(
              icon: const Icon(
                Icons.person_outline,
              ),
              selectedIcon:
                  const Icon(
                Icons.person,
              ),
              label: t(
                'Profile',
                'प्रोफाइल',
                'প্রোফাইল',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: Text(
        title,
        style:
            const TextStyle(
          fontSize: 22,
          fontWeight:
              FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  // ============================================================
  // HERO CARD
  // ============================================================

  Widget _buildHeroCard() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      height: 275,
      clipBehavior:
          Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(28),
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFFEAFBF7),
            Color(0xFFD4F3EB),
          ],
        ),
        border:
            Border.all(
          color:
              Color(0xFFC7ECE3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.055,
            ),
            blurRadius: 22,
            offset:
                const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        clipBehavior:
            Clip.none,
        children: [
          // ======================================================
          // BACKGROUND DECORATION
          // ======================================================

          Positioned(
            right: -80,
            top: -35,
            child: Container(
              width: 245,
              height: 245,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color:
                    emerald.withOpacity(
                  0.08,
                ),
              ),
            ),
          ),

          Positioned(
            right: 30,
            bottom: -105,
            child: Container(
              width: 230,
              height: 230,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color:
                    primary.withOpacity(
                  0.06,
                ),
              ),
            ),
          ),

          // ======================================================
          // LEFT CONTENT
          // ======================================================

          Positioned(
            left: 21,
            top: 20,
            bottom: 18,
            right: 150,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(
                          0.045,
                        ),
                        blurRadius: 10,
                        offset:
                            const Offset(
                          0,
                          4,
                        ),
                      ),
                    ],
                  ),
                  child:
                      const Icon(
                    Icons.favorite,
                    color: emerald,
                    size: 27,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                Text(
                  t(
                    'Your Health,',
                    'आपका स्वास्थ्य,',
                    'আপনার স্বাস্থ্য,',
                  ),
                  style:
                      const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        textPrimary,
                    height: 1.02,
                    letterSpacing:
                        -0.8,
                  ),
                ),

                Text(
                  t(
                    'Our Priority.',
                    'हमारी प्राथमिकता।',
                    'আমাদের অগ্রাধিকার।',
                  ),
                  style:
                      const TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        primary,
                    height: 1.05,
                    letterSpacing:
                        -0.8,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  t(
                    'Manage appointments, medicines\nand healthcare services from one place.',
                    'अपॉइंटमेंट, दवाइयां और स्वास्थ्य\nसेवाएं एक ही जगह से प्रबंधित करें।',
                    'অ্যাপয়েন্টমেন্ট, ওষুধ এবং স্বাস্থ্যসেবা\nএক জায়গা থেকে পরিচালনা করুন।',
                  ),
                  maxLines: 3,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color:
                        textSecondary,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    _heroChip(
                      Icons
                          .calendar_month_outlined,
                      t(
                        'Appointments',
                        'अपॉइंटमेंट',
                        'অ্যাপয়েন্টমেন্ট',
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    _heroChip(
                      Icons
                          .medication_outlined,
                      t(
                        'Medicines',
                        'दवाइयां',
                        'ওষুধ',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ======================================================
          // DOCTOR IMAGE — FIXED
          // ======================================================

        Positioned(
           right: -10,
           bottom: 0,
           child: SizedBox(
           width: 195,
           height: 258,
           child: Image.asset(
          'assets/images/doctor.png',
           fit: BoxFit.contain,
           alignment: Alignment.bottomCenter,
         ),
       ),
     ),
          // ======================================================
          // IMAGE LIGHT OVERLAY
          // ======================================================

          Positioned(
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                width: 75,
                height: 275,
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.centerLeft,
                    end:
                        Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      Color(0x08FFFFFF),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ======================================================
          // BLOOD GROUP
          // ======================================================

          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color: primary,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        primary.withOpacity(
                      0.18,
                    ),
                    blurRadius: 10,
                    offset:
                        const Offset(
                      0,
                      4,
                    ),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons
                        .water_drop_outlined,
                    color:
                        Colors.white,
                    size: 16,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Blood: ${widget.bloodGroup.isEmpty ? '—' : widget.bloodGroup}',
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 11.5,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FALLBACK
  // ============================================================

  Widget _doctorFallback() {
    return Align(
      alignment:
          Alignment.bottomRight,
      child: Container(
        width: 150,
        height: 205,
        decoration:
            BoxDecoration(
          color:
              Colors.white.withOpacity(
            0.55,
          ),
          borderRadius:
              const BorderRadius.only(
            topLeft:
                Radius.circular(75),
            topRight:
                Radius.circular(75),
          ),
        ),
        child:
            const Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor:
                  Color(0xFFE5F4F0),
              child: Icon(
                Icons.person_outline,
                size: 43,
                color:
                    Color(0xFF00796B),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Icon(
              Icons
                  .medical_services_outlined,
              size: 42,
              color:
                  Color(0xFF00796B),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HERO CHIP
  // ============================================================

  Widget _heroChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.88,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: primary,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            text,
            style:
                const TextStyle(
              fontSize: 9,
              fontWeight:
                  FontWeight.w700,
              color:
                  textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEALTH OVERVIEW
  // ============================================================

  Widget _buildHealthOverview() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 190,
        ),
        itemBuilder:
            (context, index) {
          if (index == 0) {
            return _buildStatCard(
              icon:
                  Icons.calendar_month_outlined,
              value:
                  upcomingAppointments,
              label:
                  t(
                'Upcoming\nAppointments',
                'आगामी\nअपॉइंटमेंट',
                'আসন্ন\nঅ্যাপয়েন্টমেন্ট',
              ),
              iconColor: blue,
              cardColor: blueLight,
            );
          }

          if (index == 1) {
            return _buildStatCard(
              icon:
                  Icons.medication_outlined,
              value:
                  totalMedicines,
              label:
                  t(
                'Total\nMedicines',
                'कुल\nदवाइयां',
                'মোট\nওষুধ',
              ),
              iconColor: orange,
              cardColor: orangeLight,
            );
          }

          if (index == 2) {
            return _buildStatCard(
              icon:
                  Icons.check_circle_outline,
              value:
                  medicinesTaken,
              label:
                  t(
                'Medicines\nTaken',
                'ली गई\nदवाइयां',
                'খাওয়া\nওষুধ',
              ),
              iconColor: emerald,
              cardColor: mint,
            );
          }

          return _buildStatCard(
            icon:
                Icons.assignment_late_outlined,
            value:
                pendingMedicines,
            label:
                t(
              'Pending\nMedicines',
              'बाकी\nदवाइयां',
              'বাকি\nওষুধ',
            ),
            iconColor: red,
            cardColor: redLight,
          );
        },
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _buildStatCard({
    required IconData icon,
    required int value,
    required String label,
    required Color iconColor,
    required Color cardColor,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(22),
        border:
            Border.all(
          color:
              iconColor.withOpacity(
            0.15,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.03,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.82,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Text(
            value.toString(),
            style:
                const TextStyle(
              fontSize: 27,
              height: 1,
              fontWeight:
                  FontWeight.w800,
              color: textPrimary,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Expanded(
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontSize: 12.5,
                      height: 1.18,
                      fontWeight:
                          FontWeight.w500,
                      color:
                          textSecondary,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 3,
                ),

                Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                      textSecondary
                          .withOpacity(
                    0.55,
                  ),
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MEDICINE PROGRESS
  // ============================================================

  Widget _buildMedicineProgress() {
    double progress = 0;

    if (totalMedicines > 0) {
      progress =
          medicinesTaken /
              totalMedicines;

      progress =
          progress.clamp(
        0.0,
        1.0,
      );
    }

    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: white,
        borderRadius:
            BorderRadius.circular(22),
        border:
            Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color: mint,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                    const Icon(
                  Icons
                      .trending_up_rounded,
                  color: emerald,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  t(
                    'Medicine Progress',
                    'दवा प्रगति',
                    'ওষুধের অগ্রগতি',
                  ),
                  style:
                      const TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        textPrimary,
                  ),
                ),
              ),

              Text(
                '${(progress * 100).round()}%',
                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w800,
                  color: emerald,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor:
                  const Color(
                0xFFDDF2ED,
              ),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                emerald,
              ),
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              totalMedicines == 0
                  ? t(
                      'No medicines added yet.',
                      'अभी तक कोई दवा नहीं जोड़ी गई है।',
                      'এখনও কোনো ওষুধ যোগ করা হয়নি।',
                    )
                  : '$medicinesTaken of $totalMedicines medicines taken.',
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.w500,
                color:
                    textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // UPCOMING APPOINTMENT
  // ============================================================

  Widget _buildNextAppointment() {
    if (upcomingAppointments == 0) {
      return Container(
        margin:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        padding:
            const EdgeInsets.all(18),
        decoration:
            BoxDecoration(
          color: white,
          borderRadius:
              BorderRadius.circular(22),
          border:
              Border.all(
            color: border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration:
                  BoxDecoration(
                color: blueLight,
                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .event_available_outlined,
                color: blue,
                size: 27,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    t(
                      'No upcoming appointments',
                      'कोई आगामी अपॉइंटमेंट नहीं',
                      'কোনো আসন্ন অ্যাপয়েন্টমেন্ট নেই',
                    ),
                    style:
                        const TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          textPrimary,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    t(
                      'Book an appointment when needed.',
                      'जरूरत पड़ने पर अपॉइंटमेंट बुक करें।',
                      'প্রয়োজন হলে অ্যাপয়েন্টমেন্ট বুক করুন।',
                    ),
                    style:
                        const TextStyle(
                      fontSize: 11.5,
                      color:
                          textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {
                _openScreen(
                  const BookAppointmentScreen(),
                );
              },
              icon:
                  const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 16,
                color: primary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: white,
        borderRadius:
            BorderRadius.circular(22),
        border:
            Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration:
                BoxDecoration(
              color: mint,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child:
                const Icon(
              Icons
                  .event_available_outlined,
              color: primary,
              size: 27,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  t(
                    'Upcoming appointments',
                    'आगामी अपॉइंटमेंट',
                    'আসন্ন অ্যাপয়েন্টমেন্ট',
                  ),
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  '$upcomingAppointments appointment(s) scheduled',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        textSecondary,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _openScreen(
                const MyAppointmentsScreen(),
              );
            },
            icon:
                const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              size: 16,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK SERVICES
  // ============================================================

  Widget _buildServices() {
    final services = [
      {
        'title': t(
          'Book Appointment',
          'अपॉइंटमेंट बुक करें',
          'অ্যাপয়েন্টমেন্ট বুক করুন',
        ),
        'icon':
            Icons.calendar_month_outlined,
        'color': blue,
        'background': blueLight,
        'screen':
            const BookAppointmentScreen(),
      },
      {
        'title': t(
          'My Appointments',
          'मेरे अपॉइंटमेंट',
          'আমার অ্যাপয়েন্টমেন্ট',
        ),
        'icon':
            Icons.event_available_outlined,
        'color': primary,
        'background': mint,
        'screen':
            const MyAppointmentsScreen(),
      },
      {
        'title': t(
          'Health Records',
          'स्वास्थ्य रिकॉर्ड',
          'স্বাস্থ্য রেকর্ড',
        ),
        'icon':
            Icons.folder_copy_outlined,
        'color': purple,
        'background': purpleLight,
        'screen':
            const HealthRecordsScreen(),
      },
      {
        'title': t(
          'Medicines',
          'दवाइयां',
          'ওষুধ',
        ),
        'icon':
            Icons.medication_outlined,
        'color': orange,
        'background': orangeLight,
        'screen':
            const MedicineReminderScreen(),
      },
      {
        'title': t(
          'AI Health Assistant',
          'AI स्वास्थ्य सहायक',
          'AI স্বাস্থ্য সহকারী',
        ),
        'icon':
            Icons.auto_awesome_outlined,
        'color': emerald,
        'background': mint,
        'screen':
            const AiChatbotScreen(),
      },
      {
        'title': t(
          'Family Profiles',
          'परिवार प्रोफाइल',
          'পরিবারের প্রোফাইল',
        ),
        'icon':
            Icons.groups_outlined,
        'color': blue,
        'background': blueLight,
        'screen':
            const FamilyProfilesScreen(),
      },
      {
        'title': t(
          'Emergency Help',
          'आपातकालीन सहायता',
          'জরুরি সহায়তা',
        ),
        'icon':
            Icons.emergency_outlined,
        'color': red,
        'background': redLight,
        'screen':
            EmergencyScreen(
          emergencyContact:
              widget.emergencyContact,
        ),
      },
      {
        'title': t(
          'My Profile',
          'मेरी प्रोफाइल',
          'আমার প্রোফাইল',
        ),
        'icon':
            Icons.account_circle_outlined,
        'color': purple,
        'background': purpleLight,
        'screen':
            ProfileScreen(
          userName:
              widget.userName,
          userAge:
              widget.userAge,
          userGender:
              widget.userGender,
          userCity:
              widget.userCity,
          bloodGroup:
              widget.bloodGroup,
          emergencyContact:
              widget.emergencyContact,
        ),
      },
    ];

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child:
          GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount:
            services.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 150,
        ),
        itemBuilder:
            (context, index) {
          final service =
              services[index];

          return _buildServiceCard(
            title:
                service['title']
                    as String,
            icon:
                service['icon']
                    as IconData,
            iconColor:
                service['color']
                    as Color,
            backgroundColor:
                service['background']
                    as Color,
            onTap: () {
              _openScreen(
                service['screen']
                    as Widget,
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // SERVICE CARD
  // ============================================================

  Widget _buildServiceCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(21),
        child: Container(
          padding:
              const EdgeInsets.all(15),
          decoration:
              BoxDecoration(
            color: white,
            borderRadius:
                BorderRadius.circular(21),
            border:
                Border.all(
              color: border,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.025,
                ),
                blurRadius: 12,
                offset:
                    const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color:
                      backgroundColor,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style:
                    const TextStyle(
                  fontSize: 12.5,
                  height: 1.18,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      textPrimary,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Row(
                children: [
                  Text(
                    t(
                      'Open',
                      'खोलें',
                      'খুলুন',
                    ),
                    style:
                        TextStyle(
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          iconColor,
                    ),
                  ),

                  const SizedBox(
                    width: 3,
                  ),

                  Icon(
                    Icons
                        .arrow_forward_rounded,
                    size: 13,
                    color:
                        iconColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEALTH TIP
  // ============================================================

  Widget _buildHealthTip() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF00695C),
            Color(0xFF008F78),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                primary.withOpacity(
              0.15,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.15,
              ),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child:
                const Icon(
              Icons
                  .lightbulb_outline_rounded,
              color:
                  Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  t(
                    'Daily Health Tip',
                    'दैनिक स्वास्थ्य सुझाव',
                    'দৈনিক স্বাস্থ্য টিপস',
                  ),
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        Colors.white,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  t(
                    'Stay hydrated, eat balanced meals, stay active and keep your health records updated.',
                    'पर्याप्त पानी पिएं, संतुलित भोजन करें, सक्रिय रहें और अपने स्वास्थ्य रिकॉर्ड अपडेट रखें।',
                    'পর্যাপ্ত পানি পান করুন, সুষম খাবার খান, সক্রিয় থাকুন এবং স্বাস্থ্য রেকর্ড আপডেট রাখুন।',
                  ),
                  style:
                      const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color:
                        Colors.white70,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}