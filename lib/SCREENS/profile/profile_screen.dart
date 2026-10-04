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

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4ECE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
        ],
      ),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: child,
    );
  }

  Widget _sectionHeading(String title, {String? action}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: _editProfile,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F7),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          _t('My Profile', 'मेरी प्रोफ़ाइल', 'আমার প্রোফাইল'),
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: const Color(0xFFF5F9F7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            onPressed: _openSettings,
            tooltip: _t('Settings', 'सेटिंग्स', 'সেটিংস'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------
              // PREMIUM PROFILE HEADER
              // -------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE9F9F4),
                      Color(0xFFD8F2EA),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFCDE9E0)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 31,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName.isEmpty ? 'User' : userName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 15,
                                    color: AppTheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      userCity.isEmpty
                                          ? _t('Location not added', 'स्थान नहीं जोड़ा गया', 'অবস্থান যোগ করা হয়নি')
                                          : userCity,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                emergencyContact.isEmpty
                                    ? _t('Emergency contact not added', 'आपातकालीन संपर्क नहीं जोड़ा गया', 'জরুরি যোগাযোগ যোগ করা হয়নি')
                                    : emergencyContact,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit_outlined, size: 19),
                        label: Text(
                          _t('Edit Profile', 'प्रोफ़ाइल संपादित करें', 'প্রোফাইল সম্পাদনা করুন'),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              _sectionHeading(
                _t('Health Identity', 'स्वास्थ्य जानकारी', 'স্বাস্থ্য পরিচয়'),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon: Icons.bloodtype_outlined,
                      title: _t('Blood Group', 'ब्लड ग्रुप', 'রক্তের গ্রুপ'),
                      value: bloodGroup,
                      color: const Color(0xFFD94A42),
                      onTap: _editProfile,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.cake_outlined,
                      title: _t('Age', 'उम्र', 'বয়স'),
                      value: userAge.isEmpty
                          ? ''
                          : '$userAge ${_t('years', 'वर्ष', 'বছর')}',
                      color: const Color(0xFF7653D6),
                      onTap: _editProfile,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon: Icons.person_outline_rounded,
                      title: _t('Gender', 'लिंग', 'লিঙ্গ'),
                      value: userGender,
                      color: const Color(0xFF2878E8),
                      onTap: _editProfile,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.location_city_outlined,
                      title: _t('City', 'शहर', 'শহর'),
                      value: userCity,
                      color: AppTheme.primary,
                      onTap: _editProfile,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              _sectionHeading(
                _t('Emergency Information', 'आपातकालीन जानकारी', 'জরুরি তথ্য'),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF3D8D5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD94A42).withOpacity(0.11),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.emergency_outlined,
                        color: Color(0xFFD94A42),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Emergency Contact', 'आपातकालीन संपर्क', 'জরুরি যোগাযোগ'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emergencyContact.isEmpty ? '—' : emergencyContact,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _editProfile,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFD94A42),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              _sectionHeading(
                _t('Account & Preferences', 'अकाउंट और प्राथमिकताएँ', 'অ্যাকাউন্ট ও পছন্দসমূহ'),
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: _t('Settings', 'सेटिंग्स', 'সেটিংস'),
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
                title: _t('Logout', 'लॉगआउट', 'লগআউট'),
                subtitle: _t(
                  'Sign out from your account',
                  'अपने अकाउंट से साइन आउट करें',
                  'আপনার অ্যাকাউন্ট থেকে সাইন আউট করুন',
                ),
                onTap: _logout,
                isDanger: true,
              ),

              const SizedBox(height: 28),

              Center(
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE8E4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'JAN AROGYA • Version 1.0.0',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _t(
                        'Your health, connected.',
                        'आपका स्वास्थ्य, हमेशा जुड़ा हुआ।',
                        'আপনার স্বাস্থ্য, সবসময় সংযুক্ত।',
                      ),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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