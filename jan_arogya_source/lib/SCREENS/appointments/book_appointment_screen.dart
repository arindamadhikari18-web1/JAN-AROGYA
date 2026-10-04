import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/appointment_service.dart';
import '../../main.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  String? _selectedSpeciality;
  String? _selectedDoctor;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isBooking = false;

  // =====================================================
  // LANGUAGE
  // =====================================================

  String get _languageCode =>
      JanArogyaApp.of(context)?.currentLanguageCode ?? 'en';

  bool get _isHindi => _languageCode == 'hi';

  // =====================================================
  // TRANSLATIONS
  // =====================================================

  String _text(String key) {
    final Map<String, Map<String, String>> translations = {
      'en': {
        'bookAppointment': 'Book Appointment',
        'findCare': 'Find the right care for you',
        'description':
            'Select a speciality, doctor, appointment date and preferred time.',
        'selectSpeciality': '1. Select Speciality',
        'selectDoctor': '2. Select Doctor',
        'selectDate': '3. Select Date',
        'selectTime': '4. Select Time',
        'selectSpecialityFirst':
            'Please select a speciality first.',
        'selectAppointmentDate':
            'Select appointment date',
        'selectAppointmentTime':
            'Select appointment time',
        'confirmAppointment':
            'Confirm Appointment',
        'savingAppointment':
            'Saving Appointment...',
        'selectSpecialityMessage':
            'Please select a speciality',
        'selectDoctorMessage':
            'Please select a doctor',
        'selectDateMessage':
            'Please select an appointment date',
        'selectTimeMessage':
            'Please select an appointment time',
        'futureTime':
            'Please select a future appointment time',
        'futureDateTime':
            'Appointment date and time must be in the future',
        'saveFailed':
            'Appointment could not be saved. Please try again.',
        'somethingWrong':
            'Something went wrong. Please try again.',
        'appointmentBooked':
            'Appointment Booked!',
        'successMessage':
            'has been successfully confirmed.',
        'done': 'Done',

        'generalPhysician': 'General Physician',
        'cardiologist': 'Cardiologist',
        'dermatologist': 'Dermatologist',
        'dentist': 'Dentist',
        'orthopedic': 'Orthopedic',
        'eyeSpecialist': 'Eye Specialist',
      },

      'hi': {
        'bookAppointment': 'अपॉइंटमेंट बुक करें',
        'findCare': 'अपने लिए सही स्वास्थ्य सेवा चुनें',
        'description':
            'विशेषज्ञता, डॉक्टर, अपॉइंटमेंट की तारीख और पसंदीदा समय चुनें।',
        'selectSpeciality': '1. विशेषज्ञता चुनें',
        'selectDoctor': '2. डॉक्टर चुनें',
        'selectDate': '3. तारीख चुनें',
        'selectTime': '4. समय चुनें',
        'selectSpecialityFirst':
            'कृपया पहले एक विशेषज्ञता चुनें।',
        'selectAppointmentDate':
            'अपॉइंटमेंट की तारीख चुनें',
        'selectAppointmentTime':
            'अपॉइंटमेंट का समय चुनें',
        'confirmAppointment':
            'अपॉइंटमेंट की पुष्टि करें',
        'savingAppointment':
            'अपॉइंटमेंट सेव किया जा रहा है...',
        'selectSpecialityMessage':
            'कृपया एक विशेषज्ञता चुनें',
        'selectDoctorMessage':
            'कृपया एक डॉक्टर चुनें',
        'selectDateMessage':
            'कृपया अपॉइंटमेंट की तारीख चुनें',
        'selectTimeMessage':
            'कृपया अपॉइंटमेंट का समय चुनें',
        'futureTime':
            'कृपया भविष्य का अपॉइंटमेंट समय चुनें',
        'futureDateTime':
            'अपॉइंटमेंट की तारीख और समय भविष्य का होना चाहिए',
        'saveFailed':
            'अपॉइंटमेंट सेव नहीं हो सका। कृपया दोबारा प्रयास करें।',
        'somethingWrong':
            'कुछ गलत हो गया। कृपया दोबारा प्रयास करें।',
        'appointmentBooked':
            'अपॉइंटमेंट बुक हो गया!',
        'successMessage':
            'का अपॉइंटमेंट सफलतापूर्वक कन्फर्म हो गया है।',
        'done': 'हो गया',

        'generalPhysician': 'सामान्य चिकित्सक',
        'cardiologist': 'हृदय रोग विशेषज्ञ',
        'dermatologist': 'त्वचा रोग विशेषज्ञ',
        'dentist': 'दंत चिकित्सक',
        'orthopedic': 'हड्डी रोग विशेषज्ञ',
        'eyeSpecialist': 'नेत्र विशेषज्ञ',
      },
    };

    return translations[_languageCode]?[key] ??
        translations['en']![key] ??
        key;
  }

  // =====================================================
  // SPECIALITIES
  // =====================================================

  List<Map<String, dynamic>> get _specialities => [
        {
          'id': 'generalPhysician',
          'icon': Icons.medical_services_rounded,
        },
        {
          'id': 'cardiologist',
          'icon': Icons.favorite_rounded,
        },
        {
          'id': 'dermatologist',
          'icon': Icons.face_rounded,
        },
        {
          'id': 'dentist',
          'icon': Icons.health_and_safety_rounded,
        },
        {
          'id': 'orthopedic',
          'icon': Icons.accessibility_new_rounded,
        },
        {
          'id': 'eyeSpecialist',
          'icon': Icons.visibility_rounded,
        },
      ];

  // =====================================================
  // DOCTORS
  // =====================================================

  final Map<String, List<String>> _doctors = {
    'generalPhysician': [
      'Dr. Rahul Sharma',
      'Dr. Priya Singh',
    ],
    'cardiologist': [
      'Dr. Amit Verma',
      'Dr. Neha Kapoor',
    ],
    'dermatologist': [
      'Dr. Anjali Mehta',
      'Dr. Rohan Gupta',
    ],
    'dentist': [
      'Dr. Karan Malhotra',
      'Dr. Sneha Joshi',
    ],
    'orthopedic': [
      'Dr. Vikram Patel',
      'Dr. Pooja Shah',
    ],
    'eyeSpecialist': [
      'Dr. Arjun Nair',
      'Dr. Kavya Iyer',
    ],
  };

  // =====================================================
  // SELECT DATE
  // =====================================================

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final DateTime initialDate =
        _selectedDate != null &&
                !_selectedDate!.isBefore(today)
            ? _selectedDate!
            : today;

    final DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(
        const Duration(days: 90),
      ),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  // =====================================================
  // SELECT TIME
  // =====================================================

  Future<void> _selectTime() async {
    final TimeOfDay now = TimeOfDay.now();

    final TimeOfDay initialTime =
        _selectedTime ?? now;

    final TimeOfDay? pickedTime =
        await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null || !mounted) return;

    if (_selectedDate != null &&
        _isToday(_selectedDate!)) {
      final DateTime currentDateTime =
          DateTime.now();

      final DateTime selectedDateTime =
          DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      if (!selectedDateTime.isAfter(
        currentDateTime,
      )) {
        _showMessage(
          _text('futureTime'),
        );
        return;
      }
    }

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  // =====================================================
  // CHECK TODAY
  // =====================================================

  bool _isToday(DateTime date) {
    final DateTime now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  String get _formattedDate {
    if (_selectedDate == null) {
      return _text('selectAppointmentDate');
    }

    return '${_selectedDate!.day.toString().padLeft(2, '0')}/'
        '${_selectedDate!.month.toString().padLeft(2, '0')}/'
        '${_selectedDate!.year}';
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================

  String get _formattedTime {
    if (_selectedTime == null) {
      return _text('selectAppointmentTime');
    }

    final int hour =
        _selectedTime!.hourOfPeriod == 0
            ? 12
            : _selectedTime!.hourOfPeriod;

    final String minute =
        _selectedTime!.minute
            .toString()
            .padLeft(2, '0');

    final String period =
        _selectedTime!.period == DayPeriod.am
            ? 'AM'
            : 'PM';

    return '$hour:$minute $period';
  }

  // =====================================================
  // CONFIRM APPOINTMENT
  // =====================================================

  Future<void> _confirmAppointment() async {
    if (_selectedSpeciality == null) {
      _showMessage(
        _text('selectSpecialityMessage'),
      );
      return;
    }

    if (_selectedDoctor == null) {
      _showMessage(
        _text('selectDoctorMessage'),
      );
      return;
    }

    if (_selectedDate == null) {
      _showMessage(
        _text('selectDateMessage'),
      );
      return;
    }

    if (_selectedTime == null) {
      _showMessage(
        _text('selectTimeMessage'),
      );
      return;
    }

    final DateTime appointmentDateTime =
        DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (!appointmentDateTime.isAfter(
      DateTime.now(),
    )) {
      _showMessage(
        _text('futureDateTime'),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final bool isSaved =
          await AppointmentService.saveAppointment(
        speciality: _selectedSpeciality!,
        doctor: _selectedDoctor!,
        date: _formattedDate,
        time: _formattedTime,
      );

      if (!mounted) return;

      setState(() {
        _isBooking = false;
      });

      if (isSaved) {
        _showSuccessDialog();
      } else {
        _showMessage(
          _text('saveFailed'),
        );
      }
    } catch (e) {
      debugPrint(
        'Appointment booking error: $e',
      );

      if (!mounted) return;

      setState(() {
        _isBooking = false;
      });

      _showMessage(
        _text('somethingWrong'),
      );
    }
  }

  // =====================================================
  // SHOW MESSAGE
  // =====================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =====================================================
  // SUCCESS DIALOG
  // =====================================================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.primary,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _text('appointmentBooked'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  _isHindi
                      ? '$_selectedDoctor ${_text('successMessage')}'
                      : 'Your appointment with $_selectedDoctor '
                          '${_text('successMessage')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8EDF2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedSpeciality != null
                            ? _text(
                                _selectedSpeciality!,
                              )
                            : '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _selectedDoctor ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        '$_formattedDate • $_formattedTime',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      _text('done'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // SECTION TITLE
  // =====================================================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  // =====================================================
  // MAIN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final List<String> availableDoctors =
        _selectedSpeciality == null
            ? <String>[]
            : _doctors[_selectedSpeciality] ??
                <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(
          _text('bookAppointment'),
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                _text('findCare'),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                _text('description'),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      height: 1.5,
                      color: Colors.grey.shade600,
                    ),
              ),

              const SizedBox(height: 28),

              // SPECIALITY
              _buildSectionTitle(
                _text('selectSpeciality'),
              ),

              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: _specialities.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                itemBuilder: (context, index) {
                  final speciality =
                      _specialities[index];

                  final String id =
                      speciality['id'] as String;

                  final String name = _text(id);

                  final bool isSelected =
                      _selectedSpeciality == id;

                  return InkWell(
                    onTap: _isBooking
                        ? null
                        : () {
                            setState(() {
                              _selectedSpeciality = id;
                              _selectedDoctor = null;
                            });
                          },
                    borderRadius:
                        BorderRadius.circular(18),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryLight
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : const Color(
                                  0xFFE8EDF2,
                                ),
                          width:
                              isSelected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              speciality['icon']
                                  as IconData,
                              color: AppTheme.primary,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // DOCTOR
              _buildSectionTitle(
                _text('selectDoctor'),
              ),

              if (_selectedSpeciality == null)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          const Color(0xFFE8EDF2),
                    ),
                  ),
                  child: Text(
                    _text('selectSpecialityFirst'),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Column(
                  children:
                      availableDoctors.map((doctor) {
                    final bool isSelected =
                        _selectedDoctor == doctor;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: InkWell(
                        onTap: _isBooking
                            ? null
                            : () {
                                setState(() {
                                  _selectedDoctor =
                                      doctor;
                                });
                              },
                        borderRadius:
                            BorderRadius.circular(18),
                        child: Ink(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryLight
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : const Color(
                                      0xFFE8EDF2,
                                    ),
                              width:
                                  isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      AppTheme.primaryLight,
                                  borderRadius:
                                      BorderRadius.circular(
                                    16,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color:
                                      AppTheme.primary,
                                  size: 28,
                                ),
                              ),

                              const SizedBox(
                                width: 14,
                              ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      doctor,
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                        fontSize: 16,
                                        color: AppTheme
                                            .textPrimary,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(
                                      _text(
                                        _selectedSpeciality!,
                                      ),
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isSelected)
                                const Icon(
                                  Icons
                                      .check_circle_rounded,
                                  color:
                                      AppTheme.primary,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 28),

              // DATE
              _buildSectionTitle(
                _text('selectDate'),
              ),

              InkWell(
                onTap: _isBooking
                    ? null
                    : _selectDate,
                borderRadius:
                    BorderRadius.circular(16),
                child: Ink(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          const Color(0xFFE8EDF2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: AppTheme.primary,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          _formattedDate,
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            color:
                                _selectedDate == null
                                    ? Colors.grey
                                    : AppTheme
                                        .textPrimary,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // TIME
              _buildSectionTitle(
                _text('selectTime'),
              ),

              InkWell(
                onTap: _isBooking
                    ? null
                    : _selectTime,
                borderRadius:
                    BorderRadius.circular(16),
                child: Ink(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          const Color(0xFFE8EDF2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppTheme.primary,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          _formattedTime,
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            color:
                                _selectedTime == null
                                    ? Colors.grey
                                    : AppTheme
                                        .textPrimary,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // CONFIRM BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isBooking
                      ? null
                      : _confirmAppointment,
                  icon: _isBooking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .check_circle_outline_rounded,
                        ),
                  label: Text(
                    _isBooking
                        ? _text('savingAppointment')
                        : _text('confirmAppointment'),
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