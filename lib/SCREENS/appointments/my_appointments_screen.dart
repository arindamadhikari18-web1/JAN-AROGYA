import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../main.dart';
import '../../services/appointment_service.dart';
import 'book_appointment_screen.dart';
import 'video_consultation_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  int _tab = 0;

  String get _lang => JanArogyaApp.of(context)?.currentLanguageCode ?? 'en';
  String t(String en, String hi, String bn) => _lang == 'hi' ? hi : _lang == 'bn' ? bn : en;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final data = await AppointmentService.getAppointments();
    if (!mounted) return;
    setState(() { _appointments = data; _loading = false; });
  }

  List<Map<String, dynamic>> get _visible {
    if (_tab == 0) return _appointments.where((a) => (a['status']?.toString().toLowerCase() ?? '') == 'upcoming').toList();
    if (_tab == 1) return _appointments.where((a) => (a['status']?.toString().toLowerCase() ?? '') == 'completed').toList();
    return _appointments.where((a) => (a['status']?.toString().toLowerCase() ?? '') == 'cancelled').toList();
  }

  Future<void> _cancel(Map<String, dynamic> a) async {
    final id = a['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Cancel appointment?'),
      content: const Text('This appointment will be moved to cancelled appointments.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel'))],
    ));
    if (yes != true) return;
    await AppointmentService.cancelAppointment(id);
    await _load();
  }

  Future<void> _complete(Map<String, dynamic> a) async {
    final id = a['id']?.toString() ?? '';
    if (id.isEmpty) return;
    await AppointmentService.completeAppointment(id);
    await _load();
  }

  void _openVideo(Map<String, dynamic> a) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => VideoConsultationScreen(appointment: a))).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text(t('My Appointments', 'मेरे अपॉइंटमेंट', 'আমার অ্যাপয়েন্টমেন্ট')), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded))]),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              _summary(),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2EBE8))), child: Row(children: [
                _tabButton(0, t('Upcoming', 'आगामी', 'আসন্ন')),
                _tabButton(1, t('Completed', 'पूर्ण', 'সম্পন্ন')),
                _tabButton(2, t('Cancelled', 'रद्द', 'বাতিল')),
              ])),
              const SizedBox(height: 16),
              if (_loading) const Padding(padding: EdgeInsets.all(50), child: Center(child: CircularProgressIndicator(color: AppTheme.primary)))
              else if (_visible.isEmpty) _empty()
              else ..._visible.map(_appointmentCard),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const BookAppointmentScreen())); await _load(); }, icon: const Icon(Icons.add_rounded), label: Text(t('Book', 'बुक करें', 'বুক করুন'))),
    );
  }

  Widget _summary() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]), borderRadius: BorderRadius.circular(26)), child: Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(17)), child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 30)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_appointments.where((a) => (a['status']?.toString().toLowerCase() ?? '') == 'upcoming').length} upcoming visits', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)), const SizedBox(height: 4), const Text('Keep your appointments, queue and consultation details in one place.', style: TextStyle(color: Colors.white70, height: 1.35))]))]));

  Widget _tabButton(int index, String text) { final selected = _tab == index; return Expanded(child: InkWell(onTap: () => setState(() => _tab = index), borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: selected ? AppTheme.primaryLight : Colors.transparent, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.w800, color: selected ? AppTheme.primary : AppTheme.textSecondary)))))); }

  Widget _empty() => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE2EBE8))), child: Column(children: [Container(width: 64, height: 64, decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.event_busy_rounded, color: AppTheme.primary, size: 31)), const SizedBox(height: 14), Text(_tab == 0 ? 'No upcoming appointments' : _tab == 1 ? 'No completed appointments' : 'No cancelled appointments', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)), const SizedBox(height: 7), const Text('Your appointment activity will appear here.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary))]));

  Widget _appointmentCard(Map<String, dynamic> a) {
    final doctor = a['doctorName']?.toString().isNotEmpty == true ? a['doctorName'].toString() : 'Doctor';
    final specialty = a['specialty']?.toString() ?? 'General Consultation';
    final mode = a['consultationMode']?.toString() ?? 'In-clinic';
    final status = a['status']?.toString() ?? 'Upcoming';
    final isVideo = mode.toLowerCase() == 'video';
    final upcoming = status.toLowerCase() == 'upcoming';
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(23), border: Border.all(color: const Color(0xFFE2EBE8)), boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 15, offset: Offset(0, 5))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: isVideo ? const Color(0xFFE8F1FF) : AppTheme.primaryLight, borderRadius: BorderRadius.circular(17)), child: Icon(isVideo ? Icons.videocam_rounded : Icons.local_hospital_rounded, color: isVideo ? AppTheme.secondary : AppTheme.primary, size: 27)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doctor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)), const SizedBox(height: 4), Text(specialty, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12.5))])), _status(status)]),
      const SizedBox(height: 15),
      Row(children: [Expanded(child: _detail(Icons.calendar_today_rounded, a['date']?.toString() ?? 'Date')), const SizedBox(width: 9), Expanded(child: _detail(Icons.access_time_rounded, a['time']?.toString() ?? 'Time'))]),
      const SizedBox(height: 9),
      _detail(Icons.place_outlined, isVideo ? 'Online consultation' : (a['hospitalName']?.toString() ?? 'Healthcare Centre')),
      if ((a['reason']?.toString() ?? '').isNotEmpty) ...[const SizedBox(height: 9), _detail(Icons.notes_rounded, a['reason'].toString())],
      if (upcoming) ...[
        const SizedBox(height: 15),
        Row(
          children: [
            if (isVideo)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openVideo(a),
                  icon: const Icon(Icons.video_call_rounded, size: 19),
                  label: const Text('Join'),
                ),
              ),
            if (isVideo) const SizedBox(width: 9),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _cancel(a),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
      if (!upcoming && status.toLowerCase() == 'completed') ...[const SizedBox(height: 13), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.check_circle_outline_rounded), label: const Text('Consultation completed')))],
      if (upcoming && !isVideo) ...[const SizedBox(height: 13), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => _complete(a), icon: const Icon(Icons.done_all_rounded), label: const Text('Mark as completed')))],
    ]));
  }

  Widget _detail(IconData icon, String text) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFFF7FAF9), borderRadius: BorderRadius.circular(13)), child: Row(children: [Icon(icon, size: 17, color: AppTheme.primary), const SizedBox(width: 7), Expanded(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)))]));

  Widget _status(String text) { final cancelled = text.toLowerCase() == 'cancelled'; final completed = text.toLowerCase() == 'completed'; final color = cancelled ? AppTheme.error : completed ? AppTheme.success : AppTheme.primary; return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: .10), borderRadius: BorderRadius.circular(30)), child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800))); }
}
