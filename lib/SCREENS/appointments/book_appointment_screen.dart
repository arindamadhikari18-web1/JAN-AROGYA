import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../../services/appointment_service.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  String? _specialty;
  String? _doctor;
  DateTime? _date;
  TimeOfDay? _time;
  String _mode = 'In-clinic';
  String _facility = 'Healthcare Centre';
  bool _booking = false;
  final _reasonController = TextEditingController();

  String get _lang => JanArogyaApp.of(context)?.currentLanguageCode ?? 'en';
  String t(String en, String hi, String bn) => _lang == 'hi' ? hi : _lang == 'bn' ? bn : en;

  final List<Map<String, dynamic>> _specialties = const [
    {'id': 'General Physician', 'icon': Icons.medical_services_rounded},
    {'id': 'Cardiologist', 'icon': Icons.favorite_rounded},
    {'id': 'Dermatologist', 'icon': Icons.face_rounded},
    {'id': 'Dentist', 'icon': Icons.health_and_safety_rounded},
    {'id': 'Orthopedic', 'icon': Icons.accessibility_new_rounded},
    {'id': 'Eye Specialist', 'icon': Icons.visibility_rounded},
    {'id': 'Pediatrician', 'icon': Icons.child_care_rounded},
    {'id': 'Gynecologist', 'icon': Icons.pregnant_woman_rounded},
  ];

  final Map<String, List<String>> _doctors = const {
    'General Physician': ['Dr. Rahul Sharma', 'Dr. Priya Singh'],
    'Cardiologist': ['Dr. Amit Verma', 'Dr. Neha Kapoor'],
    'Dermatologist': ['Dr. Anjali Mehta', 'Dr. Rohan Gupta'],
    'Dentist': ['Dr. Karan Malhotra', 'Dr. Sneha Joshi'],
    'Orthopedic': ['Dr. Vikram Patel', 'Dr. Pooja Shah'],
    'Eye Specialist': ['Dr. Arjun Nair', 'Dr. Kavya Iyer'],
    'Pediatrician': ['Dr. Meera Rao', 'Dr. Aditya Sen'],
    'Gynecologist': ['Dr. Nisha Kapoor', 'Dr. Ritu Das'],
  };

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date != null && !_date!.isBefore(DateTime(now.year, now.month, now.day)) ? _date! : now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time ?? TimeOfDay.now());
    if (picked == null || !mounted) return;
    if (_date != null) {
      final selected = DateTime(_date!.year, _date!.month, _date!.day, picked.hour, picked.minute);
      if (!selected.isAfter(DateTime.now())) {
        _message(t('Choose a future time.', 'भविष्य का समय चुनें।', 'ভবিষ্যতের সময় বেছে নিন।'));
        return;
      }
    }
    setState(() => _time = picked);
  }

  String _dateText() => _date == null ? t('Select date', 'तारीख चुनें', 'তারিখ নির্বাচন করুন') : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}';

  String _timeText() {
    if (_time == null) return t('Select time', 'समय चुनें', 'সময় নির্বাচন করুন');
    final h = _time!.hourOfPeriod == 0 ? 12 : _time!.hourOfPeriod;
    return '$h:${_time!.minute.toString().padLeft(2, '0')} ${_time!.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  Future<void> _confirm() async {
    if (_specialty == null || _doctor == null || _date == null || _time == null) {
      _message(t('Please complete the appointment details.', 'कृपया अपॉइंटमेंट की सभी जानकारी भरें।', 'অ্যাপয়েন্টমেন্টের সব তথ্য পূরণ করুন।'));
      return;
    }
    final dt = DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute);
    if (!dt.isAfter(DateTime.now())) {
      _message(t('Appointment must be in the future.', 'अपॉइंटमेंट भविष्य का होना चाहिए।', 'অ্যাপয়েন্টমেন্ট ভবিষ্যতের হতে হবে।'));
      return;
    }
    setState(() => _booking = true);
    final saved = await AppointmentService.saveAppointment(
      doctor: _doctor!,
      speciality: _specialty!,
      hospitalName: _mode == 'Video' ? 'JAN AROGYA Teleconsultation' : 'JAN AROGYA Healthcare',
      date: _dateText(),
      time: _timeText(),
      reason: _reasonController.text.trim().isEmpty ? 'General Consultation' : _reasonController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _booking = false);
    if (!saved) {
      _message(t('Could not save appointment.', 'अपॉइंटमेंट सेव नहीं हो सका।', 'অ্যাপয়েন্টমেন্ট সেভ করা যায়নি।'));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(children: [Icon(Icons.check_circle_rounded, color: AppTheme.success), SizedBox(width: 10), Text('Appointment Confirmed')]),
        content: Text('$_doctor\n$_specialty\n$_dateText • ${_timeText()}\nMode: $_mode'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
      ),
    );
    if (mounted) Navigator.pop(context, true);
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final doctors = _specialty == null ? <String>[] : (_doctors[_specialty!] ?? []);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(t('Book Appointment', 'अपॉइंटमेंट बुक करें', 'অ্যাপয়েন্টমেন্ট বুক করুন'))),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 350)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _hero(),
              const SizedBox(height: 18),
              _title(t('Choose care type', 'स्वास्थ्य सेवा चुनें', 'স্বাস্থ্যসেবা বেছে নিন')),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _modeCard('In-clinic', Icons.local_hospital_rounded, 'Visit a facility')),
                const SizedBox(width: 12),
                Expanded(child: _modeCard('Video', Icons.videocam_rounded, 'Consult from home')),
              ]),
              const SizedBox(height: 22),
              _title(t('Select speciality', 'विशेषज्ञता चुनें', 'বিশেষজ্ঞতা বেছে নিন')),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _specialties.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, mainAxisExtent: 74),
                itemBuilder: (_, i) {
                  final s = _specialties[i];
                  final selected = _specialty == s['id'];
                  return _selectCard(
                    selected: selected,
                    icon: s['icon'] as IconData,
                    title: s['id'] as String,
                    onTap: () => setState(() { _specialty = s['id'] as String; _doctor = null; }),
                  );
                },
              ),
              const SizedBox(height: 22),
              _title(t('Select doctor', 'डॉक्टर चुनें', 'ডাক্তার বেছে নিন')),
              const SizedBox(height: 10),
              if (doctors.isEmpty) _empty('Select a speciality first') else ...doctors.map((d) => _doctorCard(d)),
              const SizedBox(height: 22),
              _title(t('Visit details', 'विज़िट विवरण', 'ভিজিটের বিবরণ')),
              const SizedBox(height: 10),
              if (_mode == 'In-clinic') _dropdownFacility(),
              const SizedBox(height: 10),
              Row(children: [Expanded(child: _dateTile()), const SizedBox(width: 10), Expanded(child: _timeTile())]),
              const SizedBox(height: 12),
              TextField(controller: _reasonController, maxLines: 3, decoration: InputDecoration(labelText: t('Reason / symptoms (optional)', 'कारण / लक्षण (वैकल्पिक)', 'কারণ / উপসর্গ (ঐচ্ছিক)'), prefixIcon: const Icon(Icons.notes_rounded), alignLabelWithHint: true)),
              const SizedBox(height: 22),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFEFFAF7), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD2EEE7))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.verified_user_outlined, color: AppTheme.primary), const SizedBox(width: 10), Expanded(child: Text(t('Keep your reports and prescriptions ready for the doctor.', 'डॉक्टर के लिए अपनी रिपोर्ट और प्रिस्क्रिप्शन तैयार रखें।', 'ডাক্তারের জন্য রিপোর্ট ও প্রেসক্রিপশন প্রস্তুত রাখুন।'), style: const TextStyle(color: AppTheme.textSecondary, height: 1.4)))])),
              const SizedBox(height: 18),
              SizedBox(height: 56, child: ElevatedButton.icon(onPressed: _booking ? null : _confirm, icon: _booking ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)) : const Icon(Icons.calendar_month_rounded), label: Text(_booking ? 'Confirming...' : t('Confirm Appointment', 'अपॉइंटमेंट की पुष्टि करें', 'অ্যাপয়েন্টমেন্ট নিশ্চিত করুন')))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]), borderRadius: BorderRadius.circular(28)), child: Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 29)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Plan your care', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text('Choose a doctor, time and consultation mode.', style: const TextStyle(color: Colors.white70, height: 1.35))]))]));

  Widget _title(String text) => Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppTheme.textPrimary));

  Widget _modeCard(String mode, IconData icon, String subtitle) {
    final selected = _mode == mode;
    return InkWell(onTap: () => setState(() => _mode = mode), borderRadius: BorderRadius.circular(20), child: Ink(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: selected ? AppTheme.primaryLight : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFE2EBE8), width: selected ? 1.8 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary), const SizedBox(height: 9), Text(mode, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))])));
  }

  Widget _selectCard({required bool selected, required IconData icon, required String title, required VoidCallback onTap}) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(17), child: Ink(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: selected ? AppTheme.primaryLight : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFE2EBE8), width: selected ? 1.8 : 1)), child: Row(children: [Icon(icon, color: AppTheme.primary, size: 23), const SizedBox(width: 9), Expanded(child: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary))), if (selected) const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20)])));

  Widget _doctorCard(String doctor) { final selected = _doctor == doctor; return Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: () => setState(() => _doctor = doctor), borderRadius: BorderRadius.circular(19), child: Ink(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: selected ? AppTheme.primaryLight : Colors.white, borderRadius: BorderRadius.circular(19), border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFE2EBE8), width: selected ? 1.8 : 1)), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFE8F7F4), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 28)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doctor, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)), const SizedBox(height: 4), Text(_specialty ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))])), Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppTheme.primary : AppTheme.textLight)])))); }

  Widget _empty(String text) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2EBE8))), child: Text(text, style: const TextStyle(color: AppTheme.textSecondary)));

  Widget _dropdownFacility() => DropdownButtonFormField<String>(initialValue: _facility, decoration: const InputDecoration(labelText: 'Facility type', prefixIcon: Icon(Icons.business_rounded)), items: const ['Healthcare Centre', 'Government Hospital', 'Private Hospital', 'Clinic'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) { if (v != null) setState(() => _facility = v); });

  Widget _dateTile() => InkWell(onTap: _pickDate, borderRadius: BorderRadius.circular(16), child: Ink(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2EBE8))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.calendar_today_rounded, color: AppTheme.primary), const SizedBox(height: 9), Text(_dateText(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary))])));

  Widget _timeTile() => InkWell(onTap: _pickTime, borderRadius: BorderRadius.circular(16), child: Ink(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2EBE8))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.access_time_rounded, color: AppTheme.primary), const SizedBox(height: 9), Text(_timeText(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary))])));
}
