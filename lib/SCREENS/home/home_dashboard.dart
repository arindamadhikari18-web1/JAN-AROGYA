import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/appointment_service.dart';
import '../../services/medicine_service.dart';

import '../ai_chatbot/ai_chatbot_screen.dart';
import '../appointments/book_appointment_screen.dart';
import '../appointments/my_appointments_screen.dart';
import '../emergency/emergency_screen.dart';
import '../family/family_profiles_screen.dart';
import '../records/health_records_screen.dart';
import '../lab/lab_tests_screen.dart';
import '../medicine/medicine_reminder_screen.dart';
import '../nearby_hospitals_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/language_settings_screen.dart';

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
  static const Color primary = Color(0xFF00796B);
  static const Color emerald = Color(0xFF00A878);
  static const Color background = Color(0xFFF7FAF9);
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
  static const Color pink = Color(0xFFE64A7B);
  static const Color pinkLight = Color(0xFFFCEAF2);
  static const Color mint = Color(0xFFE8F8F4);

  int upcomingAppointments = 0;
  int totalMedicines = 0;
  int medicinesTaken = 0;
  int pendingMedicines = 0;
  bool isLoading = true;
  int _selectedNavIndex = 0;

  String _locationText = 'Detecting location…';
  bool _locationLoading = true;
  bool _locationDenied = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadCurrentLocation();
  }

  Future<void> _loadDashboard() async {
    try {
      final appointments = await AppointmentService.getUpcomingAppointments();
      final medicines = await MedicineService.getMedicines();
      final taken = await MedicineService.getTakenMedicines();
      final pending = await MedicineService.getPendingMedicines();

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
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshDashboard() async {
    await Future.wait<void>([
      _loadDashboard(),
      _loadCurrentLocation(showLoadingState: false),
    ]);
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  String t(String english, String hindi, String bengali) {
    final language = Localizations.localeOf(context).languageCode;
    if (language == 'hi') return hindi;
    if (language == 'bn') return bengali;
    return english;
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return t('Good morning', 'सुप्रभात', 'সুপ্রভাত');
    }
    if (hour < 17) {
      return t('Good afternoon', 'शुभ दोपहर', 'শুভ অপরাহ্ন');
    }
    return t('Good evening', 'शुभ संध्या', 'শুভ সন্ধ্যা');
  }

  String _firstName() {
    final value = widget.userName.trim();
    if (value.isEmpty) return 'there';
    return value.split(RegExp(r'\s+')).first;
  }

  Future<void> _loadCurrentLocation({bool showLoadingState = true}) async {
    if (showLoadingState && mounted) {
      setState(() {
        _locationLoading = true;
        _locationDenied = false;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationFallback('Location services are off');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _locationLoading = false;
          _locationDenied = true;
          _locationText = widget.userCity.trim().isEmpty
              ? 'Location permission needed'
              : widget.userCity.trim();
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      // Keep this dependency-free: the app already uses geolocator, so the
      // dashboard can show the live device position without adding another
      // reverse-geocoding package to pubspec.yaml.
      final lat = position.latitude.toStringAsFixed(4);
      final lng = position.longitude.toStringAsFixed(4);

      setState(() {
        _locationLoading = false;
        _locationDenied = false;
        _locationText = '$lat°, $lng°';
      });
    } catch (_) {
      _setLocationFallback(
        widget.userCity.trim().isEmpty ? 'Location unavailable' : widget.userCity.trim(),
      );
    }
  }

  void _setLocationFallback(String value) {
    if (!mounted) return;
    setState(() {
      _locationLoading = false;
      _locationText = value;
    });
  }

  Future<void> _openScreen(Widget screen) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, __) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.05, 0),
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
    if (mounted) await _loadDashboard();
  }

  void _selectNavigation(int index) {
    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        _openScreen(const MyAppointmentsScreen());
        break;
      case 2:
        _openScreen(HealthRecordsScreen());
        break;
      case 3:
        _openScreen(
          EmergencyScreen(emergencyContact: widget.emergencyContact),
        );
        break;
      case 4:
        _openScreen(
          ProfileScreen(
            userName: widget.userName,
            userAge: widget.userAge,
            userGender: widget.userGender,
            userCity: widget.userCity,
            bloodGroup: widget.bloodGroup,
            emergencyContact: widget.emergencyContact,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 88,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 7, 10, 0),
          child: Row(
            children: [
              Expanded(child: _buildProfessionalHeader()),
              IconButton(
                tooltip: 'Language',
                onPressed: () =>
                    _openScreen(const LanguageSettingsScreen()),
                icon: const Icon(Icons.language_rounded, color: primary),
              ),
              const SizedBox(width: 2),
              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _openScreen(
                  ProfileScreen(
                    userName: widget.userName,
                    userAge: widget.userAge,
                    userGender: widget.userGender,
                    userCity: widget.userCity,
                    bloodGroup: widget.bloodGroup,
                    emergencyContact: widget.emergencyContact,
                  ),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: border),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: primary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: primary,
          onRefresh: _refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                const SizedBox(height: 22),
                _sectionTitle('Our Services'),
                const SizedBox(height: 12),
                _buildPosterServices(),
                const SizedBox(height: 24),
                _sectionTitle(
                  t(
                    'Health Overview',
                    'स्वास्थ्य अवलोकन',
                    'স্বাস্থ্য সংক্ষিপ্তসার',
                  ),
                ),
                const SizedBox(height: 12),
                _buildHealthOverview(),
                const SizedBox(height: 18),
                _buildMedicineProgress(),
                const SizedBox(height: 24),
                _buildNextAppointment(),
                const SizedBox(height: 24),
                _buildHealthTip(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildProfessionalHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _greeting(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Hello, ${_firstName()}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: _locationDenied
              ? () async => Geolocator.openAppSettings()
              : _loadCurrentLocation,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 14,
                color: _locationDenied ? orange : primary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _locationLoading
                      ? 'Detecting current location…'
                      : _locationText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: _locationDenied ? orange : textSecondary,
                  ),
                ),
              ),
              if (_locationLoading) ...[
                const SizedBox(width: 5),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedIndex: _selectedNavIndex,
          indicatorColor: const Color(0xFFD2F1E9),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: _selectNavigation,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Appointments',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_copy_outlined),
              selectedIcon: Icon(Icons.folder_copy_rounded),
              label: 'Records',
            ),
            NavigationDestination(
              icon: Icon(Icons.emergency_outlined),
              selectedIcon: Icon(Icons.emergency_rounded),
              label: 'Emergency',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -.4,
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 272,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE7FAF5), Color(0xFFDDF3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: const Color(0xFFC7ECE3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -80,
            top: -55,
            child: _circle(220, emerald.withOpacity(.10)),
          ),
          Positioned(
            right: 55,
            bottom: -110,
            child: _circle(240, primary.withOpacity(.06)),
          ),
          Positioned(
            left: 20,
            top: 19,
            bottom: 18,
            right: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 47,
                  height: 47,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: emerald,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  t('Your Health,', 'आपका स्वास्थ्य,', 'আপনার স্বাস্থ্য,'),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    height: 1.0,
                  ),
                ),
                Text(
                  t('Our Priority.', 'हमारी प्राथमिकता।', 'আমাদের অগ্রাধিকার।'),
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  t(
                    'One platform for guidance, care, records and follow-up.',
                    'मार्गदर्शन, देखभाल, रिकॉर्ड और फॉलो-अप के लिए एक प्लेटफॉर्म।',
                    'পরামর্শ, যত্ন, রেকর্ড ও ফলো-আপের জন্য একটি প্ল্যাটফর্ম।',
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _heroChip(Icons.calendar_month_outlined, 'Appointments'),
                    _heroChip(Icons.medication_outlined, 'Medicines'),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: -6,
            bottom: -3,
            child: SizedBox(
              width: 198,
              height: 257,
              child: Image.asset(
                'assets/images/doctor.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 95,
                    color: primary,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.water_drop_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Blood: ${widget.bloodGroup.isEmpty ? '—' : widget.bloodGroup}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
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

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _heroChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterServices() {
    final services = <Map<String, dynamic>>[
      {
        'number': '1',
        'title': 'AI Health Assistant',
        'subtitle': 'Voice + Text guidance\n& Digital Triage',
        'footer': 'Ask  •  Get Guidance  •  In Your Language',
        'icon': Icons.smart_toy_rounded,
        'color': blue,
        'bg': const Color(0xFFE5F2FF),
        'screen': const AiChatbotScreen(),
      },
      {
        'number': '2',
        'title': 'Nearby Hospitals',
        'subtitle': 'Map • Call • OPD\nLive Bed Availability',
        'footer': 'Find  •  Check  •  Reach',
        'icon': Icons.local_hospital_rounded,
        'color': emerald,
        'bg': const Color(0xFFE5F8ED),
        'screen': const NearbyHospitalsScreen(),
      },
      {
        'number': '3',
        'title': 'Doctor Appointment',
        'subtitle': 'Government / Private\nDoctor Fee • Video / OPD',
        'footer': 'Book  •  Consult  •  Get Care',
        'icon': Icons.video_camera_front_rounded,
        'color': orange,
        'bg': const Color(0xFFFFF0E1),
        'screen': const BookAppointmentScreen(),
      },
      {
        'number': '4',
        'title': 'Health Records',
        'subtitle': 'Reports • Prescriptions\nHealth History',
        'footer': 'Store  •  Access  •  Anytime',
        'icon': Icons.description_rounded,
        'color': purple,
        'bg': purpleLight,
        'screen': HealthRecordsScreen(),
      },
      {
        'number': '5',
        'title': 'Medicine Reminder',
        'subtitle': 'Timely Reminders\nMedicine Tracking',
        'footer': 'Set  •  Track  •  Stay on Time',
        'icon': Icons.medication_rounded,
        'color': orange,
        'bg': const Color(0xFFFFF6D9),
        'screen': const MedicineReminderScreen(),
      },
      {
        'number': '6',
        'title': 'Lab Tests',
        'subtitle': 'Search Any Test • Compare Prices\nBook Test • Give Sample',
        'footer': 'Search  •  Compare  •  Book  •  Get Report',
        'icon': Icons.biotech_rounded,
        'color': pink,
        'bg': pinkLight,
        'screen': const LabTestsScreen(),
      },
      {
        'number': '7',
        'title': 'Emergency Support',
        'subtitle': 'Guest Access\nAmbulance • Emergency Contact',
        'footer': 'Quick Access  •  Immediate Help',
        'icon': Icons.emergency_rounded,
        'color': red,
        'bg': const Color(0xFFE8F3FF),
        'screen': EmergencyScreen(
          emergencyContact: widget.emergencyContact,
        ),
      },
      {
        'number': '8',
        'title': 'Family Health',
        'subtitle': 'Manage Family\nHealth Records',
        'footer': 'Add Members  •  Manage  •  Care Together',
        'icon': Icons.groups_rounded,
        'color': emerald,
        'bg': const Color(0xFFE7F8E9),
        'screen': const FamilyProfilesScreen(),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 11,
          mainAxisSpacing: 11,
          mainAxisExtent: 188,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          return _serviceCard(
            number: service['number'] as String,
            title: service['title'] as String,
            subtitle: service['subtitle'] as String,
            footer: service['footer'] as String,
            icon: service['icon'] as IconData,
            color: service['color'] as Color,
            backgroundColor: service['bg'] as Color,
            onTap: () => _openScreen(service['screen'] as Widget),
          );
        },
      ),
    );
  }

  Widget _serviceCard({
    required String number,
    required String title,
    required String subtitle,
    required String footer,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(.12)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 31,
                    height: 31,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withOpacity(.9),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(icon, color: color, size: 37),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.2,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.7,
                    height: 1.25,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.55),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  footer,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.7,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthOverview() {
    final cards = [
      (
        Icons.calendar_month_outlined,
        upcomingAppointments,
        'Upcoming\nAppointments',
        blue,
        blueLight,
      ),
      (
        Icons.medication_outlined,
        totalMedicines,
        'Total\nMedicines',
        orange,
        orangeLight,
      ),
      (
        Icons.check_circle_outline,
        medicinesTaken,
        'Medicines\nTaken',
        emerald,
        mint,
      ),
      (
        Icons.assignment_late_outlined,
        pendingMedicines,
        'Pending\nMedicines',
        red,
        redLight,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 160,
        ),
        itemBuilder: (_, index) {
          final card = cards[index];
          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: card.$5,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: card.$4.withOpacity(.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(card.$1, color: card.$4, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  card.$2.toString(),
                  style: const TextStyle(
                    fontSize: 27,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.$3,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.15,
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: textSecondary,
                      size: 23,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicineProgress() {
    final progress = totalMedicines == 0
        ? 0.0
        : (medicinesTaken / totalMedicines).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: emerald,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t('Medicine Progress', 'दवा प्रगति', 'ওষুধের অগ্রগতি'),
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: const Color(0xFFDDF2ED),
              valueColor: const AlwaysStoppedAnimation<Color>(emerald),
            ),
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              totalMedicines == 0
                  ? 'No medicines added yet.'
                  : '$medicinesTaken of $totalMedicines medicines taken.',
              style: const TextStyle(
                fontSize: 11.5,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextAppointment() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: blueLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: blue,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  upcomingAppointments == 0
                      ? 'No upcoming appointments'
                      : '$upcomingAppointments appointment(s) scheduled',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  upcomingAppointments == 0
                      ? 'Book an appointment when needed.'
                      : 'Open appointments to view the full schedule.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openScreen(
              upcomingAppointments == 0
                  ? const BookAppointmentScreen()
                  : const MyAppointmentsScreen(),
            ),
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00695C), Color(0xFF008F78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Health Tip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Stay hydrated, eat balanced meals, stay active and keep your health records updated.',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Colors.white70,
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
