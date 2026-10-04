import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/family_service.dart';
import '../../services/medicine_service.dart';
import '../../services/notification_service.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() =>
      _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  List<Map<String, dynamic>> _medicines = [];
  List<Map<String, dynamic>> _familyMembers = [];

  bool _isLoading = true;

  String _selectedMemberId = 'all';

  // =====================================================
  // LANGUAGE
  // =====================================================

  String _language = 'en';

  final Map<String, Map<String, String>> _translations = {
    'en': {
      'medicineReminder': 'Medicine Reminder',
      'myMedicines': 'My Medicines',
      'all': 'All',
      'self': 'Self',
      'member': 'Member',
      'familyMember': 'Family Member',
      'medicineFor': 'Medicine For',
      'addMedicine': 'Add Medicine',
      'editMedicine': 'Edit Medicine',
      'deleteMedicine': 'Delete Medicine?',
      'medicineName': 'Medicine Name',
      'dosage': 'Dosage',
      'reminderTime': 'Reminder Time',
      'frequency': 'Frequency',
      'daily': 'Daily',
      'twiceDaily': 'Twice Daily',
      'threeTimesDaily': 'Three Times Daily',
      'weekly': 'Weekly',
      'asNeeded': 'As Needed',
      'save': 'Save',
      'cancel': 'Cancel',
      'update': 'Update',
      'delete': 'Delete',
      'edit': 'Edit',
      'taken': 'Taken',
      'refresh': 'Refresh',
      'testNotification': 'Test Notification',
      'checkPending': 'Check Pending',
      'noMedicinesFound': 'No Medicines Found',
      'noMedicinesAdded': 'No Medicines Added',
      'noMedicinesForPerson':
          'There are no medicines for the selected person.',
      'addMedicineDescription':
          'Add medicines for yourself or your family members and keep track of daily doses.',
      'medicineAndDosageRequired':
          'Please enter medicine name and dosage',
      'medicineNameDosageRequired':
          'Medicine name and dosage are required',
      'medicineSaved':
          'Medicine added and reminder scheduled',
      'medicineSavedFailedReminder':
          'Medicine added, but notification scheduling failed',
      'medicineUpdated':
          'Medicine updated successfully',
      'medicineUpdatedFailedReminder':
          'Medicine updated, but reminder failed',
      'couldNotSave': 'Could not save medicine',
      'couldNotUpdate': 'Could not update medicine',
      'medicineDeleted': 'Medicine and reminder deleted',
      'couldNotDelete': 'Could not delete medicine',
      'testNotificationSent':
          'Test notification sent! Check notification panel.',
      'pendingNotifications':
          'Pending notifications printed in Debug Console',
      'exampleTablet': 'Example: 1 Tablet',
      'forText': 'For',
      'of': 'of',
      'medicinesTaken': 'medicines taken',
      'deleteConfirmation':
          'Are you sure you want to delete',
      'language': 'Language',
    },

    'hi': {
      'medicineReminder': 'दवा रिमाइंडर',
      'myMedicines': 'मेरी दवाइयाँ',
      'all': 'सभी',
      'self': 'स्वयं',
      'member': 'सदस्य',
      'familyMember': 'परिवार का सदस्य',
      'medicineFor': 'दवा किसके लिए',
      'addMedicine': 'दवा जोड़ें',
      'editMedicine': 'दवा संपादित करें',
      'deleteMedicine': 'दवा हटाएं?',
      'medicineName': 'दवा का नाम',
      'dosage': 'खुराक',
      'reminderTime': 'रिमाइंडर समय',
      'frequency': 'आवृत्ति',
      'daily': 'प्रतिदिन',
      'twiceDaily': 'दिन में दो बार',
      'threeTimesDaily': 'दिन में तीन बार',
      'weekly': 'साप्ताहिक',
      'asNeeded': 'आवश्यकतानुसार',
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'update': 'अपडेट करें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'taken': 'ली गई',
      'refresh': 'रीफ्रेश',
      'testNotification': 'नोटिफिकेशन टेस्ट करें',
      'checkPending': 'पेंडिंग नोटिफिकेशन देखें',
      'noMedicinesFound': 'कोई दवा नहीं मिली',
      'noMedicinesAdded': 'कोई दवा नहीं जोड़ी गई',
      'noMedicinesForPerson':
          'चुने गए व्यक्ति के लिए कोई दवा नहीं है।',
      'addMedicineDescription':
          'अपने या परिवार के सदस्यों के लिए दवाइयाँ जोड़ें और रोज़ की खुराक का ध्यान रखें।',
      'medicineAndDosageRequired':
          'कृपया दवा का नाम और खुराक दर्ज करें',
      'medicineNameDosageRequired':
          'दवा का नाम और खुराक आवश्यक है',
      'medicineSaved':
          'दवा जोड़ दी गई और रिमाइंडर सेट कर दिया गया',
      'medicineSavedFailedReminder':
          'दवा जोड़ दी गई, लेकिन रिमाइंडर सेट नहीं हो सका',
      'medicineUpdated':
          'दवा सफलतापूर्वक अपडेट हो गई',
      'medicineUpdatedFailedReminder':
          'दवा अपडेट हो गई, लेकिन रिमाइंडर सेट नहीं हो सका',
      'couldNotSave': 'दवा सेव नहीं हो सकी',
      'couldNotUpdate': 'दवा अपडेट नहीं हो सकी',
      'medicineDeleted': 'दवा और रिमाइंडर हटा दिया गया',
      'couldNotDelete': 'दवा हटाई नहीं जा सकी',
      'testNotificationSent':
          'टेस्ट नोटिफिकेशन भेज दिया गया! नोटिफिकेशन पैनल देखें।',
      'pendingNotifications':
          'पेंडिंग नोटिफिकेशन Debug Console में दिखाए गए हैं',
      'exampleTablet': 'उदाहरण: 1 टैबलेट',
      'forText': 'के लिए',
      'of': 'में से',
      'medicinesTaken': 'दवाइयाँ ली गईं',
      'deleteConfirmation':
          'क्या आप वाकई हटाना चाहते हैं',
      'language': 'भाषा',
    },

    'bn': {
      'medicineReminder': 'ওষুধের রিমাইন্ডার',
      'myMedicines': 'আমার ওষুধ',
      'all': 'সব',
      'self': 'নিজে',
      'member': 'সদস্য',
      'familyMember': 'পরিবারের সদস্য',
      'medicineFor': 'কার জন্য ওষুধ',
      'addMedicine': 'ওষুধ যোগ করুন',
      'editMedicine': 'ওষুধ সম্পাদনা করুন',
      'deleteMedicine': 'ওষুধ মুছবেন?',
      'medicineName': 'ওষুধের নাম',
      'dosage': 'ডোজ',
      'reminderTime': 'রিমাইন্ডার সময়',
      'frequency': 'ফ্রিকোয়েন্সি',
      'daily': 'প্রতিদিন',
      'twiceDaily': 'দিনে দুইবার',
      'threeTimesDaily': 'দিনে তিনবার',
      'weekly': 'সাপ্তাহিক',
      'asNeeded': 'প্রয়োজন অনুযায়ী',
      'save': 'সংরক্ষণ করুন',
      'cancel': 'বাতিল',
      'update': 'আপডেট করুন',
      'delete': 'মুছুন',
      'edit': 'সম্পাদনা করুন',
      'taken': 'নেওয়া হয়েছে',
      'refresh': 'রিফ্রেশ',
      'testNotification': 'নোটিফিকেশন পরীক্ষা',
      'checkPending': 'পেন্ডিং নোটিফিকেশন দেখুন',
      'noMedicinesFound': 'কোনো ওষুধ পাওয়া যায়নি',
      'noMedicinesAdded': 'কোনো ওষুধ যোগ করা হয়নি',
      'noMedicinesForPerson':
          'নির্বাচিত ব্যক্তির জন্য কোনো ওষুধ নেই।',
      'addMedicineDescription':
          'নিজের বা পরিবারের সদস্যদের জন্য ওষুধ যোগ করুন এবং প্রতিদিনের ডোজের হিসাব রাখুন।',
      'medicineAndDosageRequired':
          'অনুগ্রহ করে ওষুধের নাম এবং ডোজ লিখুন',
      'medicineNameDosageRequired':
          'ওষুধের নাম এবং ডোজ প্রয়োজন',
      'medicineSaved':
          'ওষুধ যোগ করা হয়েছে এবং রিমাইন্ডার সেট করা হয়েছে',
      'medicineSavedFailedReminder':
          'ওষুধ যোগ করা হয়েছে, কিন্তু রিমাইন্ডার সেট করা যায়নি',
      'medicineUpdated':
          'ওষুধ সফলভাবে আপডেট করা হয়েছে',
      'medicineUpdatedFailedReminder':
          'ওষুধ আপডেট করা হয়েছে, কিন্তু রিমাইন্ডার সেট করা যায়নি',
      'couldNotSave': 'ওষুধ সংরক্ষণ করা যায়নি',
      'couldNotUpdate': 'ওষুধ আপডেট করা যায়নি',
      'medicineDeleted': 'ওষুধ এবং রিমাইন্ডার মুছে ফেলা হয়েছে',
      'couldNotDelete': 'ওষুধ মুছে ফেলা যায়নি',
      'testNotificationSent':
          'টেস্ট নোটিফিকেশন পাঠানো হয়েছে! নোটিফিকেশন প্যানেল দেখুন।',
      'pendingNotifications':
          'পেন্ডিং নোটিফিকেশন Debug Console-এ দেখানো হয়েছে',
      'exampleTablet': 'উদাহরণ: ১ ট্যাবলেট',
      'forText': 'জন্য',
      'of': 'এর মধ্যে',
      'medicinesTaken': 'টি ওষুধ নেওয়া হয়েছে',
      'deleteConfirmation':
          'আপনি কি নিশ্চিত যে মুছে ফেলতে চান',
      'language': 'ভাষা',
    },
  };

  String _t(String key) {
    return _translations[_language]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  // =====================================================
  // INITIAL LOAD
  // =====================================================

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // =====================================================
  // LOAD DATA
  // =====================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final results = await Future.wait([
        MedicineService.getMedicines(),
        FamilyService.getFamilyMembers(),
      ]);

      if (!mounted) return;

      setState(() {
        _medicines =
            List<Map<String, dynamic>>.from(results[0] as List);

        _familyMembers =
            List<Map<String, dynamic>>.from(results[1] as List);

        final selectedStillExists =
            _selectedMemberId == 'all' ||
                _selectedMemberId == 'self' ||
                _familyMembers.any(
                  (member) =>
                      member['id']?.toString() ==
                      _selectedMemberId,
                );

        if (!selectedStillExists) {
          _selectedMemberId = 'all';
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _medicines = [];
        _familyMembers = [];
        _isLoading = false;
      });
    }
  }

  // =====================================================
  // FILTERED MEDICINES
  // =====================================================

  List<Map<String, dynamic>> get _filteredMedicines {
    if (_selectedMemberId == 'all') {
      return _medicines;
    }

    return _medicines.where(
      (medicine) =>
          medicine['memberId']?.toString() ==
          _selectedMemberId,
    ).toList();
  }

  // =====================================================
  // NOTIFICATION ID
  // =====================================================

  int _generateNotificationId() {
    return DateTime.now()
        .millisecondsSinceEpoch
        .remainder(2147483647);
  }

  // =====================================================
  // PARSE TIME
  // =====================================================

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.trim().split(' ');

      if (parts.length != 2) {
        return const TimeOfDay(hour: 9, minute: 0);
      }

      final timeParts = parts[0].split(':');

      if (timeParts.length != 2) {
        return const TimeOfDay(hour: 9, minute: 0);
      }

      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      final String period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  // =====================================================
  // FORMAT TIME
  // =====================================================

  String _formatTime(TimeOfDay time) {
    final hour =
        time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  // =====================================================
  // TIME PICKER
  // =====================================================

  Widget _buildTimePicker({
    required TimeOfDay selectedTime,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );

        if (pickedTime != null) {
          onTimeChanged(pickedTime);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _t('reminderTime'),
          prefixIcon: const Icon(
            Icons.access_time_rounded,
          ),
        ),
        child: Text(
          _formatTime(selectedTime),
        ),
      ),
    );
  }

  // =====================================================
  // LANGUAGE SELECTOR
  // =====================================================

  Widget _buildLanguageButton() {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.language_rounded,
      ),
      tooltip: _t('language'),
      onSelected: (value) {
        setState(() {
          _language = value;
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: const [
              Icon(Icons.language_rounded),
              SizedBox(width: 10),
              Text('English'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'hi',
          child: Row(
            children: const [
              Icon(Icons.language_rounded),
              SizedBox(width: 10),
              Text('हिन्दी'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'bn',
          child: Row(
            children: const [
              Icon(Icons.language_rounded),
              SizedBox(width: 10),
              Text('বাংলা'),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SCHEDULE NOTIFICATION
  // =====================================================

  Future<void> _scheduleNotification({
    required int notificationId,
    required String name,
    required String dosage,
    required TimeOfDay time,
    required String memberName,
  }) async {
    await NotificationService.scheduleMedicineReminder(
      id: notificationId,
      medicineName: '$name • $memberName',
      dosage: dosage,
      hour: time.hour,
      minute: time.minute,
    );
  }

  // =====================================================
  // TEST NOTIFICATION
  // =====================================================

  Future<void> _testNotification() async {
    try {
      await NotificationService.showTestNotification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('testNotificationSent'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Test notification error: $e',
          ),
        ),
      );
    }
  }

  // =====================================================
  // CHECK PENDING
  // =====================================================

  Future<void> _checkPendingNotifications() async {
    try {
      await NotificationService.printPendingNotifications();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('pendingNotifications'),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Pending notification check error: $e');
    }
  }

  // =====================================================
  // MEMBER NAME
  // =====================================================

  String _getMemberName(String memberId) {
    if (memberId == 'self') {
      return _t('self');
    }

    final memberIndex = _familyMembers.indexWhere(
      (member) =>
          member['id']?.toString() == memberId,
    );

    if (memberIndex == -1) {
      return _t('familyMember');
    }

    return _familyMembers[memberIndex]['name']
            ?.toString() ??
        _t('familyMember');
  }

  // =====================================================
  // MEMBER RELATION
  // =====================================================

  String _getMemberRelation(String memberId) {
    if (memberId == 'self') {
      return _t('self');
    }

    final memberIndex = _familyMembers.indexWhere(
      (member) =>
          member['id']?.toString() == memberId,
    );

    if (memberIndex == -1) {
      return _t('familyMember');
    }

    return _familyMembers[memberIndex]['relation']
            ?.toString() ??
        _t('familyMember');
  }

  // =====================================================
  // PERSON SELECTOR
  // =====================================================

  Widget _buildPersonSelector({
    required String selectedMemberId,
    required Function(String) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedMemberId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: _t('medicineFor'),
        prefixIcon: const Icon(
          Icons.person_rounded,
        ),
      ),
      items: [
        DropdownMenuItem<String>(
          value: 'self',
          child: Text(_t('self')),
        ),

        ..._familyMembers.map((member) {
          final id =
              member['id']?.toString() ?? '';

          final name =
              member['name']?.toString() ??
                  _t('familyMember');

          final relation =
              member['relation']?.toString() ??
                  _t('familyMember');

          return DropdownMenuItem<String>(
            value: id,
            child: Text(
              '$name ($relation)',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  // =====================================================
  // ADD MEDICINE DIALOG
  // =====================================================

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();

    TimeOfDay selectedTime =
        const TimeOfDay(hour: 9, minute: 0);

    String selectedFrequency = 'Daily';
    String selectedMemberId = 'self';

    final frequencyOptions = [
      'Daily',
      'Twice Daily',
      'Three Times Daily',
      'Weekly',
      'As Needed',
    ];

    String getFrequencyText(String frequency) {
      switch (frequency) {
        case 'Daily':
          return _t('daily');
        case 'Twice Daily':
          return _t('twiceDaily');
        case 'Three Times Daily':
          return _t('threeTimesDaily');
        case 'Weekly':
          return _t('weekly');
        case 'As Needed':
          return _t('asNeeded');
        default:
          return frequency;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                _t('addMedicine'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPersonSelector(
                      selectedMemberId: selectedMemberId,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMemberId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: _t('medicineName'),
                        prefixIcon: const Icon(
                          Icons.medication_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: _t('dosage'),
                        hintText: _t('exampleTablet'),
                        prefixIcon: const Icon(
                          Icons.medical_services_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildTimePicker(
                      selectedTime: selectedTime,
                      onTimeChanged: (newTime) {
                        setDialogState(() {
                          selectedTime = newTime;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedFrequency,
                      decoration: InputDecoration(
                        labelText: _t('frequency'),
                        prefixIcon: const Icon(
                          Icons.repeat_rounded,
                        ),
                      ),
                      items:
                          frequencyOptions.map((frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Text(
                            getFrequencyText(frequency),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedFrequency = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(_t('cancel')),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final name =
                        nameController.text.trim();

                    final dosage =
                        dosageController.text.trim();

                    if (name.isEmpty || dosage.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            _t('medicineAndDosageRequired'),
                          ),
                        ),
                      );
                      return;
                    }

                    final memberName =
                        _getMemberName(selectedMemberId);

                    final memberRelation =
                        _getMemberRelation(selectedMemberId);

                    final notificationId =
                        _generateNotificationId();

                    bool notificationScheduled = false;

                    try {
                      await _scheduleNotification(
                        notificationId: notificationId,
                        name: name,
                        dosage: dosage,
                        time: selectedTime,
                        memberName: memberName,
                      );

                      notificationScheduled = true;

                      await NotificationService
                          .printPendingNotifications();
                    } catch (e) {
                      debugPrint(
                        'Notification scheduling error: $e',
                      );
                    }

                    final saved =
                        await MedicineService.saveMedicine(
                      name: name,
                      dosage: dosage,
                      time: _formatTime(selectedTime),
                      frequency: selectedFrequency,
                      notificationId: notificationId,
                      memberId: selectedMemberId,
                      memberName: memberName,
                      relation: memberRelation,
                    );

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    if (saved) {
                      await _loadData();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            notificationScheduled
                                ? _t('medicineSaved')
                                : _t(
                                    'medicineSavedFailedReminder',
                                  ),
                          ),
                        ),
                      );
                    } else {
                      if (notificationScheduled) {
                        await NotificationService
                            .cancelMedicineReminder(
                          notificationId,
                        );
                      }

                      if (!mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            _t('couldNotSave'),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(_t('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // EDIT MEDICINE DIALOG
  // =====================================================

  void _showEditMedicineDialog(
    Map<String, dynamic> medicine,
  ) {
    final nameController = TextEditingController(
      text: medicine['name']?.toString() ?? '',
    );

    final dosageController = TextEditingController(
      text: medicine['dosage']?.toString() ?? '',
    );

    TimeOfDay selectedTime = _parseTime(
      medicine['time']?.toString() ?? '09:00 AM',
    );

    String selectedFrequency =
        medicine['frequency']?.toString() ?? 'Daily';

    String selectedMemberId =
        medicine['memberId']?.toString() ?? 'self';

    final validMemberIds = [
      'self',
      ..._familyMembers.map(
        (member) =>
            member['id']?.toString() ?? '',
      ),
    ];

    if (!validMemberIds.contains(selectedMemberId)) {
      selectedMemberId = 'self';
    }

    final frequencyOptions = [
      'Daily',
      'Twice Daily',
      'Three Times Daily',
      'Weekly',
      'As Needed',
    ];

    if (!frequencyOptions.contains(selectedFrequency)) {
      selectedFrequency = 'Daily';
    }

    String getFrequencyText(String frequency) {
      switch (frequency) {
        case 'Daily':
          return _t('daily');
        case 'Twice Daily':
          return _t('twiceDaily');
        case 'Three Times Daily':
          return _t('threeTimesDaily');
        case 'Weekly':
          return _t('weekly');
        case 'As Needed':
          return _t('asNeeded');
        default:
          return frequency;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                _t('editMedicine'),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPersonSelector(
                      selectedMemberId: selectedMemberId,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedMemberId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: _t('medicineName'),
                        prefixIcon: const Icon(
                          Icons.medication_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: dosageController,
                      decoration: InputDecoration(
                        labelText: _t('dosage'),
                        prefixIcon: const Icon(
                          Icons.medical_services_rounded,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildTimePicker(
                      selectedTime: selectedTime,
                      onTimeChanged: (newTime) {
                        setDialogState(() {
                          selectedTime = newTime;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: selectedFrequency,
                      decoration: InputDecoration(
                        labelText: _t('frequency'),
                        prefixIcon: const Icon(
                          Icons.repeat_rounded,
                        ),
                      ),
                      items:
                          frequencyOptions.map((frequency) {
                        return DropdownMenuItem<String>(
                          value: frequency,
                          child: Text(
                            getFrequencyText(frequency),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedFrequency = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(_t('cancel')),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final name =
                        nameController.text.trim();

                    final dosage =
                        dosageController.text.trim();

                    if (name.isEmpty || dosage.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            _t(
                              'medicineNameDosageRequired',
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    final memberName =
                        _getMemberName(selectedMemberId);

                    final memberRelation =
                        _getMemberRelation(selectedMemberId);

                    final existingNotificationId =
                        medicine['notificationId'];

                    final int notificationId =
                        existingNotificationId is int
                            ? existingNotificationId
                            : int.tryParse(
                                  existingNotificationId
                                          ?.toString() ??
                                      '',
                                ) ??
                                _generateNotificationId();

                    try {
                      await NotificationService
                          .cancelMedicineReminder(
                        notificationId,
                      );
                    } catch (e) {
                      debugPrint(
                        'Old notification cancel error: $e',
                      );
                    }

                    final updated =
                        await MedicineService.updateMedicine(
                      id: medicine['id'].toString(),
                      notificationId: notificationId,
                      name: name,
                      dosage: dosage,
                      time: _formatTime(selectedTime),
                      frequency: selectedFrequency,
                      memberId: selectedMemberId,
                      memberName: memberName,
                      relation: memberRelation,
                    );

                    bool notificationScheduled = false;

                    if (updated) {
                      try {
                        await _scheduleNotification(
                          notificationId: notificationId,
                          name: name,
                          dosage: dosage,
                          time: selectedTime,
                          memberName: memberName,
                        );

                        notificationScheduled = true;
                      } catch (e) {
                        debugPrint(
                          'Updated notification error: $e',
                        );
                      }
                    }

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    if (updated) {
                      await _loadData();

                      if (!mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            notificationScheduled
                                ? _t('medicineUpdated')
                                : _t(
                                    'medicineUpdatedFailedReminder',
                                  ),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            _t('couldNotUpdate'),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(_t('update')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =====================================================
  // DELETE MEDICINE
  // =====================================================

  void _showDeleteDialog(
    Map<String, dynamic> medicine,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            _t('deleteMedicine'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            '${_t('deleteConfirmation')} '
            '${medicine['name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(_t('cancel')),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final existingNotificationId =
                    medicine['notificationId'];

                final int? notificationId =
                    existingNotificationId is int
                        ? existingNotificationId
                        : int.tryParse(
                            existingNotificationId
                                    ?.toString() ??
                                '',
                          );

                if (notificationId != null) {
                  try {
                    await NotificationService
                        .cancelMedicineReminder(
                      notificationId,
                    );
                  } catch (e) {
                    debugPrint(
                      'Notification cancel error: $e',
                    );
                  }
                }

                final deleted =
                    await MedicineService.deleteMedicine(
                  medicine['id'].toString(),
                );

                if (!mounted) return;

                Navigator.pop(dialogContext);

                if (deleted) {
                  await _loadData();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        _t('medicineDeleted'),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        _t('couldNotDelete'),
                      ),
                    ),
                  );
                }
              },
              child: Text(_t('delete')),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // TOGGLE TAKEN
  // =====================================================

  Future<void> _toggleMedicineTaken(
    Map<String, dynamic> medicine,
    bool value,
  ) async {
    final updated =
        await MedicineService.toggleMedicineTaken(
      id: medicine['id'].toString(),
      isTaken: value,
    );

    if (updated) {
      await _loadData();
    }
  }

  // =====================================================
  // MEMBER FILTER
  // =====================================================

  Widget _buildMemberFilter() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            label: _t('all'),
            memberId: 'all',
          ),

          const SizedBox(width: 8),

          _buildFilterChip(
            label: _t('self'),
            memberId: 'self',
          ),

          ..._familyMembers.map(
            (member) {
              return Padding(
                padding:
                    const EdgeInsets.only(left: 8),
                child: _buildFilterChip(
                  label:
                      member['name']?.toString() ??
                          _t('member'),
                  memberId:
                      member['id']?.toString() ?? '',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String memberId,
  }) {
    final bool isSelected =
        _selectedMemberId == memberId;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppTheme.primaryLight,
      onSelected: (_) {
        setState(() {
          _selectedMemberId = memberId;
        });
      },
      labelStyle: TextStyle(
        color: isSelected
            ? AppTheme.primary
            : AppTheme.textPrimary,
        fontWeight: isSelected
            ? FontWeight.w700
            : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected
            ? AppTheme.primary
            : const Color(0xFFE8EDF2),
      ),
    );
  }

  // =====================================================
  // MEDICINE CARD
  // =====================================================

  Widget _buildMedicineCard(
    Map<String, dynamic> medicine,
  ) {
    final bool isTaken =
        medicine['isTaken'] == true;

    final String name =
        medicine['name']?.toString() ??
            'Unknown Medicine';

    final String dosage =
        medicine['dosage']?.toString() ?? '';

    final String time =
        medicine['time']?.toString() ?? '';

    final String frequency =
        medicine['frequency']?.toString() ?? '';

    final String memberName =
        medicine['memberName']?.toString() ??
            _t('self');

    final String relation =
        medicine['relation']?.toString() ??
            _t('self');

    String getFrequencyText(String value) {
      switch (value) {
        case 'Daily':
          return _t('daily');
        case 'Twice Daily':
          return _t('twiceDaily');
        case 'Three Times Daily':
          return _t('threeTimesDaily');
        case 'Weekly':
          return _t('weekly');
        case 'As Needed':
          return _t('asNeeded');
        default:
          return value;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTaken
              ? AppTheme.primary
              : const Color(0xFFE8EDF2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isTaken
                            ? Colors.grey
                            : AppTheme.textPrimary,
                        decoration: isTaken
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$dosage • ${getFrequencyText(frequency)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditMedicineDialog(medicine);
                  } else if (value == 'delete') {
                    _showDeleteDialog(medicine);
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded),
                          const SizedBox(width: 10),
                          Text(_t('edit')),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                          ),
                          const SizedBox(width: 10),
                          Text(_t('delete')),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    '${_t('forText')}: '
                    '$memberName ($relation)',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppTheme.primary,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),

              const Spacer(),

              Checkbox(
                value: isTaken,
                activeColor: AppTheme.primary,
                onChanged: (value) {
                  if (value != null) {
                    _toggleMedicineTaken(
                      medicine,
                      value,
                    );
                  }
                },
              ),

              Text(
                _t('taken'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    final isFiltered =
        _selectedMemberId != 'all';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                color: AppTheme.primary,
                size: 44,
              ),
            ),

            const SizedBox(height: 22),

            Text(
              isFiltered
                  ? _t('noMedicinesFound')
                  : _t('noMedicinesAdded'),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              isFiltered
                  ? _t('noMedicinesForPerson')
                  : _t('addMedicineDescription'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _showAddMedicineDialog,
              icon: const Icon(Icons.add_rounded),
              label: Text(_t('addMedicine')),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // MAIN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = _filteredMedicines;
    final int takenCount = filteredMedicines.where((medicine) => medicine['isTaken'] == true).length;
    final int pendingCount = filteredMedicines.length - takenCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF9),
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('medicineReminder'), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text('Stay on schedule with your medicines', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          _buildLanguageButton(),
          IconButton(tooltip: _t('refresh'), onPressed: _loadData, icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMedicineDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Medicine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFF3E1), Color(0xFFFFF9F0)]),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF5E1BD)),
                    ),
                    child: Row(children: [
                      Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.medication_rounded, color: Color(0xFFEF8B17), size: 30)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Medication overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text('$takenCount taken • $pendingCount pending', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ])),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _medicineSummary('Total', '${filteredMedicines.length}', Icons.medication_outlined, const Color(0xFFEAF2FF), const Color(0xFF2878E8))),
                    const SizedBox(width: 10),
                    Expanded(child: _medicineSummary('Taken', '$takenCount', Icons.check_circle_outline_rounded, const Color(0xFFE7F8F4), AppTheme.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _medicineSummary('Pending', '$pendingCount', Icons.schedule_rounded, const Color(0xFFFFEEEE), const Color(0xFFD94A42))),
                  ]),
                  const SizedBox(height: 20),
                  _buildMemberFilter(),
                  const SizedBox(height: 16),
                  if (filteredMedicines.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredMedicines.map((medicine) => _buildMedicineCard(medicine)),
                ],
              ),
            ),
    );
  }

  Widget _medicineSummary(String label, String value, IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE5ECEA))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 9),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary)),
      ]),
    );
  }
}