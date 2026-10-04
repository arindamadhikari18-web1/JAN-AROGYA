import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userAge;
  final String userGender;
  final String userCity;
  final String bloodGroup;
  final String emergencyContact;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userAge,
    required this.userGender,
    required this.userCity,
    required this.bloodGroup,
    required this.emergencyContact,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String userName;
  late String userAge;
  late String userGender;
  late String userCity;
  late String bloodGroup;
  late String emergencyContact;

  String get _languageCode =>
      JanArogyaApp.of(context)?.currentLanguageCode ?? 'en';

  String _t(String english, String hindi, String bengali) {
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

    userName = widget.userName;
    userAge = widget.userAge;
    userGender = widget.userGender;
    userCity = widget.userCity;
    bloodGroup = widget.bloodGroup;
    emergencyContact = widget.emergencyContact;

    _loadProfile();
  }

  // =====================================================
  // LOAD PROFILE
  // =====================================================

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      userName = prefs.getString('userName') ?? widget.userName;
      userAge = prefs.getString('userAge') ?? widget.userAge;
      userGender =
          prefs.getString('userGender') ?? widget.userGender;
      userCity = prefs.getString('userCity') ?? widget.userCity;
      bloodGroup =
          prefs.getString('bloodGroup') ?? widget.bloodGroup;
      emergencyContact =
          prefs.getString('emergencyContact') ??
              widget.emergencyContact;
    });
  }

  // =====================================================
  // SAVE PROFILE
  // =====================================================

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userName', userName);
    await prefs.setString('userAge', userAge);
    await prefs.setString('userGender', userGender);
    await prefs.setString('userCity', userCity);
    await prefs.setString('bloodGroup', bloodGroup);
    await prefs.setString(
      'emergencyContact',
      emergencyContact,
    );
  }

  // =====================================================
  // EDIT PROFILE
  // =====================================================

  void _editProfile() {
    final nameController =
        TextEditingController(text: userName);

    final ageController =
        TextEditingController(text: userAge);

    final cityController =
        TextEditingController(text: userCity);

    final bloodGroupController =
        TextEditingController(text: bloodGroup);

    final emergencyController =
        TextEditingController(text: emergencyContact);

    String selectedGender = userGender;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(24, 20, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        _t(
                          'Edit Profile',
                          'प्रोफ़ाइल संपादित करें',
                          'প্রোফাইল সম্পাদনা করুন',
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: _t(
                            'Full Name',
                            'पूरा नाम',
                            'পুরো নাম',
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _t(
                            'Age',
                            'उम्र',
                            'বয়স',
                          ),
                          prefixIcon:
                              const Icon(Icons.cake_outlined),
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          labelText: _t(
                            'Gender',
                            'लिंग',
                            'লিঙ্গ',
                          ),
                          prefixIcon:
                              const Icon(Icons.person_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              selectedGender = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: _t(
                            'City',
                            'शहर',
                            'শহর',
                          ),
                          prefixIcon: const Icon(
                            Icons.location_city_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: bloodGroupController,
                        decoration: InputDecoration(
                          labelText: _t(
                            'Blood Group',
                            'ब्लड ग्रुप',
                            'রক্তের গ্রুপ',
                          ),
                          prefixIcon: const Icon(
                            Icons.bloodtype_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: emergencyController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: _t(
                            'Emergency Contact',
                            'आपातकालीन संपर्क',
                            'জরুরি যোগাযোগ',
                          ),
                          counterText: '',
                          prefixIcon: const Icon(
                            Icons.phone_in_talk_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty ||
                                ageController.text.trim().isEmpty ||
                                cityController.text.trim().isEmpty ||
                                bloodGroupController.text
                                    .trim()
                                    .isEmpty ||
                                emergencyController.text.trim().length !=
                                    10) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _t(
                                      'Please fill all details correctly',
                                      'कृपया सभी जानकारी सही भरें',
                                      'অনুগ্রহ করে সমস্ত তথ্য সঠিকভাবে পূরণ করুন',
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }

                            if (!mounted) return;

                            setState(() {
                              userName =
                                  nameController.text.trim();
                              userAge =
                                  ageController.text.trim();
                              userGender = selectedGender;
                              userCity =
                                  cityController.text.trim();
                              bloodGroup =
                                  bloodGroupController.text.trim();
                              emergencyContact =
                                  emergencyController.text.trim();
                            });

                            await _saveProfile();

                            if (!modalContext.mounted) return;

                            Navigator.pop(modalContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  _t(
                                    'Profile saved successfully',
                                    'प्रोफ़ाइल सफलतापूर्वक सेव हो गई',
                                    'প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে',
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            _t(
                              'Save Changes',
                              'परिवर्तन सेव करें',
                              'পরিবর্তন সংরক্ষণ করুন',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =====================================================
  // SETTINGS SCREEN
  // =====================================================

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            _t(
              'Logout?',
              'लॉगआउट करें?',
              'লগআউট করবেন?',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            _t(
              'Are you sure you want to logout from JAN AROGYA?',
              'क्या आप JAN AROGYA से लॉगआउट करना चाहते हैं?',
              'আপনি কি JAN AROGYA থেকে লগআউট করতে চান?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                _t('Cancel', 'रद्द करें', 'বাতিল করুন'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                _t('Logout', 'लॉगआउट', 'লগআউট'),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const WelcomeScreen(),
      ),
      (route) => false,
    );
  }

  // =====================================================
  // MENU ITEM
  // =====================================================

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE8EDF2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDanger
                    ? const Color(0xFFFFE9E9)
                    : AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isDanger
                    ? Colors.red
                    : AppTheme.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDanger
                          ? Colors.red
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDanger
                  ? Colors.red
                  : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PROFILE UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(
          _t(
            'My Profile',
            'मेरी प्रोफ़ाइल',
            'আমার প্রোফাইল',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.textPrimary,
        ),

        // EDIT + SETTINGS ICON
        actions: [
          IconButton(
            onPressed: _editProfile,
            tooltip: _t(
              'Edit Profile',
              'प्रोफ़ाइल संपादित करें',
              'প্রোফাইল সম্পাদনা করুন',
            ),
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),

          IconButton(
            onPressed: _openSettings,
            tooltip: _t(
              'Settings',
              'सेटिंग्स',
              'সেটিংস',
            ),
            icon: const Icon(
              Icons.settings_outlined,
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          children: [
            // PROFILE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE8EDF2),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    emergencyContact,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      label: Text(
                        _t(
                          'Edit Profile',
                          'प्रोफ़ाइल संपादित करें',
                          'প্রোফাইল সম্পাদনা করুন',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _t(
                  'Personal Information',
                  'व्यक्तिगत जानकारी',
                  'ব্যক্তিগত তথ্য',
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),

            const SizedBox(height: 14),

            _buildMenuItem(
              icon: Icons.cake_outlined,
              title: _t('Age', 'उम्र', 'বয়স'),
              subtitle: '$userAge ${_t('years', 'वर्ष', 'বছর')}',
              onTap: _editProfile,
            ),

            const SizedBox(height: 12),

            _buildMenuItem(
              icon: Icons.person_outline_rounded,
              title: _t('Gender', 'लिंग', 'লিঙ্গ'),
              subtitle: userGender,
              onTap: _editProfile,
            ),

            const SizedBox(height: 12),

            _buildMenuItem(
              icon: Icons.location_on_outlined,
              title: _t('City', 'शहर', 'শহর'),
              subtitle: userCity,
              onTap: _editProfile,
            ),

            const SizedBox(height: 12),

            _buildMenuItem(
              icon: Icons.bloodtype_outlined,
              title: _t(
                'Blood Group',
                'ब्लड ग्रुप',
                'রক্তের গ্রুপ',
              ),
              subtitle: bloodGroup,
              onTap: _editProfile,
            ),

            const SizedBox(height: 12),

            _buildMenuItem(
              icon: Icons.phone_in_talk_outlined,
              title: _t(
                'Emergency Contact',
                'आपातकालीन संपर्क',
                'জরুরি যোগাযোগ',
              ),
              subtitle: emergencyContact,
              onTap: _editProfile,
            ),

            const SizedBox(height: 28),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _t(
                  'Settings & Account',
                  'सेटिंग्स और अकाउंट',
                  'সেটিংস এবং অ্যাকাউন্ট',
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),

            const SizedBox(height: 14),

            // SETTINGS
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: _t(
                'Settings',
                'सेटिंग्स',
                'সেটিংস',
              ),
              subtitle: _t(
                'Language, notifications and preferences',
                'भाषा, नोटिफिकेशन और प्राथमिकताएँ',
                'ভাষা, নোটিফিকেশন এবং পছন্দসমূহ',
              ),
              onTap: _openSettings,
            ),

            const SizedBox(height: 12),

            _buildMenuItem(
              icon: Icons.logout_rounded,
              title: _t(
                'Logout',
                'लॉगआउट',
                'লগআউট',
              ),
              subtitle: _t(
                'Sign out from your account',
                'अपने अकाउंट से साइन आउट करें',
                'আপনার অ্যাকাউন্ট থেকে সাইন আউট করুন',
              ),
              onTap: _logout,
              isDanger: true,
            ),

            const SizedBox(height: 30),

            Text(
              'JAN AROGYA • Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SETTINGS SCREEN
// =====================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  String get _languageCode =>
      JanArogyaApp.of(context)?.currentLanguageCode ?? 'en';

  String _t(String english, String hindi, String bengali) {
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
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _changeLanguage() async {
    final selectedLanguage = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            16,
            20,
            30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _t(
                  'Choose Language',
                  'भाषा चुनें',
                  'ভাষা নির্বাচন করুন',
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const CircleAvatar(
                  child: Text('EN'),
                ),
                title: const Text('English'),
                trailing: _languageCode == 'en'
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext, 'en');
                },
              ),

              ListTile(
                leading: const CircleAvatar(
                  child: Text('हि'),
                ),
                title: const Text('हिंदी'),
                trailing: _languageCode == 'hi'
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext, 'hi');
                },
              ),

              ListTile(
                leading: const CircleAvatar(
                  child: Text('অ'),
                ),
                title: const Text('বাংলা'),
                trailing: _languageCode == 'bn'
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext, 'bn');
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedLanguage == null) return;

    final appState = JanArogyaApp.of(context);

    if (appState != null) {
      await appState.changeLanguage(selectedLanguage);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _changeNotification(bool value) async {
    setState(() {
      notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'notifications_enabled',
      value,
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title ${_t('will be available soon', 'जल्द उपलब्ध होगा', 'শীঘ্রই উপলব্ধ হবে')}',
        ),
      ),
    );
  }

  String _currentLanguageName() {
    switch (_languageCode) {
      case 'hi':
        return 'हिंदी';
      case 'bn':
        return 'বাংলা';
      default:
        return 'English';
    }
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE8EDF2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            trailing ??
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(
          _t(
            'Settings',
            'सेटिंग्स',
            'সেটিংস',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.textPrimary,
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t(
                'App Preferences',
                'ऐप प्राथमिकताएँ',
                'অ্যাপ পছন্দসমূহ',
              ),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),

            const SizedBox(height: 14),

            _buildSettingsItem(
              icon: Icons.language_rounded,
              title: _t(
                'Language',
                'भाषा',
                'ভাষা',
              ),
              subtitle: _currentLanguageName(),
              onTap: _changeLanguage,
            ),

            const SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.notifications_outlined,
              title: _t(
                'Notifications',
                'नोटिफिकेशन',
                'নোটিফিকেশন',
              ),
              subtitle: _t(
                'Manage health and appointment reminders',
                'स्वास्थ्य और अपॉइंटमेंट रिमाइंडर मैनेज करें',
                'স্বাস্থ্য এবং অ্যাপয়েন্টমেন্ট রিমাইন্ডার পরিচালনা করুন',
              ),
              trailing: Switch(
                value: notificationsEnabled,
                activeColor: AppTheme.primary,
                onChanged: _changeNotification,
              ),
              onTap: () {
                _changeNotification(!notificationsEnabled);
              },
            ),

            const SizedBox(height: 28),

            Text(
              _t(
                'Security & Support',
                'सुरक्षा और सहायता',
                'নিরাপত্তা এবং সহায়তা',
              ),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),

            const SizedBox(height: 14),

            _buildSettingsItem(
              icon: Icons.security_outlined,
              title: _t(
                'Privacy & Security',
                'प्राइवेसी और सुरक्षा',
                'গোপনীয়তা এবং নিরাপত্তা',
              ),
              subtitle: _t(
                'Manage your account security',
                'अपने अकाउंट की सुरक्षा मैनेज करें',
                'আপনার অ্যাকাউন্টের নিরাপত্তা পরিচালনা করুন',
              ),
              onTap: () => _showComingSoon(
                _t(
                  'Privacy & Security',
                  'प्राइवेसी और सुरक्षा',
                  'গোপনীয়তা এবং নিরাপত্তা',
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.help_outline_rounded,
              title: _t(
                'Help & Support',
                'सहायता और सपोर्ट',
                'সাহায্য এবং সাপোর্ট',
              ),
              subtitle: _t(
                'Get help with JAN AROGYA',
                'JAN AROGYA से सहायता प्राप्त करें',
                'JAN AROGYA সম্পর্কে সাহায্য নিন',
              ),
              onTap: () => _showComingSoon(
                _t(
                  'Help & Support',
                  'सहायता और सपोर्ट',
                  'সাহায্য এবং সাপোর্ট',
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildSettingsItem(
              icon: Icons.info_outline_rounded,
              title: _t(
                'About JAN AROGYA',
                'JAN AROGYA के बारे में',
                'JAN AROGYA সম্পর্কে',
              ),
              subtitle: 'Version 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'JAN AROGYA',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'Healthcare that stays connected with every step of your journey.',
                );
              },
            ),

            const SizedBox(height: 30),

            Center(
              child: Text(
                'JAN AROGYA • Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}