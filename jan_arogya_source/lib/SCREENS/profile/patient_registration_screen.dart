import '../home/home_dashboard.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/user_service.dart';
import '../home/home_dashboard.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState
    extends State<PatientRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emergencyController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodGroup;

  bool _isSaving = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Don’t Know',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String get _formattedDate {
    if (_selectedDate == null) {
      return 'Select date of birth';
    }

    return '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  String _calculateAge() {
    if (_selectedDate == null) return '';

    final today = DateTime.now();

    int age = today.year - _selectedDate!.year;

    if (today.month < _selectedDate!.month ||
        (today.month == _selectedDate!.month &&
            today.day < _selectedDate!.day)) {
      age--;
    }

    return age.toString();
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null ||
        _selectedGender == null ||
        _selectedBloodGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required details'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final String userName = _nameController.text.trim();
    final String userAge = _calculateAge();
    final String userGender = _selectedGender!;
    final String userCity = _cityController.text.trim();
    final String bloodGroup = _selectedBloodGroup!;
    final String emergencyContact = _emergencyController.text.trim();

    try {
      await UserService.saveUser(
        userName: userName,
        userAge: userAge,
        userGender: userGender,
        userCity: userCity,
        bloodGroup: bloodGroup,
        emergencyContact: emergencyContact,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, __) => HomeDashboard(
            userName: userName,
            userAge: userAge,
            userGender: userGender,
            userCity: userCity,
            bloodGroup: bloodGroup,
            emergencyContact: emergencyContact,
          ),
          transitionsBuilder: (_, animation, __, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideAnimation,
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
          content: Text('Something went wrong. Please try again.'),
        ),
      );

      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: _isSaving
                      ? null
                      : () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  padding: EdgeInsets.zero,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppTheme.primary,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 26),

                Text(
                  'Tell us about yourself',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 30,
                      ),
                ),

                const SizedBox(height: 10),

                Text(
                  'This information helps us personalize your healthcare experience.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                      ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Full Name',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Date of Birth',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _isSaving ? null : _selectDateOfBirth,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _formattedDate,
                      style: TextStyle(
                        color: _selectedDate == null
                            ? Colors.grey
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Gender',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  hint: const Text('Select gender'),
                  items: _genders
                      .map(
                        (gender) => DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                ),

                const SizedBox(height: 20),

                Text(
                  'Blood Group',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  hint: const Text('Select blood group'),
                  items: _bloodGroups
                      .map(
                        (bloodGroup) => DropdownMenuItem<String>(
                          value: bloodGroup,
                          child: Text(bloodGroup),
                        ),
                      )
                      .toList(),
                  onChanged: _isSaving
                      ? null
                      : (value) {
                          setState(() {
                            _selectedBloodGroup = value;
                          });
                        },
                ),

                const SizedBox(height: 20),

                Text(
                  'City',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _cityController,
                  enabled: !_isSaving,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Enter your city',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your city';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text(
                  'Emergency Contact',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _emergencyController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: 'Enter emergency mobile number',
                    counterText: '',
                    prefixIcon: Icon(Icons.phone_in_talk_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length != 10) {
                      return 'Please enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAndContinue,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save & Continue'),
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