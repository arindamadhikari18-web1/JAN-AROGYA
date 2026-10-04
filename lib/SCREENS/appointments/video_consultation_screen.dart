import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

class VideoConsultationScreen extends StatelessWidget {
  final Map<String, dynamic>? appointment;

  const VideoConsultationScreen({super.key, this.appointment});

  String _value(String key, String fallback) =>
      appointment?[key]?.toString().trim().isNotEmpty == true
          ? appointment![key].toString()
          : fallback;

  Future<void> _join(BuildContext context) async {
    final url = _value('meetingUrl', '');
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('The doctor has not opened the video room yet.'),
      ));
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Unable to open the consultation room.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = _value('doctorName', 'Your Doctor');
    final specialty = _value('specialty', 'General Consultation');
    final date = _value('date', 'Date to be confirmed');
    final time = _value('time', 'Time to be confirmed');
    final hasRoom = _value('meetingUrl', '').isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Video Consultation')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async => Future<void>.delayed(const Duration(milliseconds: 350)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.videocam_rounded, color: Colors.white, size: 42),
                    SizedBox(height: 18),
                    Text('Consult your doctor from home', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    SizedBox(height: 8),
                    Text('Keep your reports, medicines and questions ready before the consultation.', style: TextStyle(color: Colors.white70, height: 1.45)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _card(
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(doctor, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                      const SizedBox(height: 4),
                      Text(specialty, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                    ])),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _card(child: Row(children: [
                Expanded(child: _info(Icons.calendar_today_rounded, date)),
                const SizedBox(width: 10),
                Expanded(child: _info(Icons.access_time_rounded, time)),
              ])),
              const SizedBox(height: 18),
              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Before you join', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                _check('Allow camera and microphone access.'),
                _check('Use a stable internet connection.'),
                _check('Keep your health records nearby.'),
                _check('Join a few minutes before the scheduled time.'),
              ])),
              const SizedBox(height: 22),
              SizedBox(height: 56, child: ElevatedButton.icon(
                onPressed: () => _join(context),
                icon: const Icon(Icons.video_call_rounded),
                label: Text(hasRoom ? 'Join Video Consultation' : 'Waiting for Doctor'),
              )),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Appointments'),
              ),
              const SizedBox(height: 18),
              const Text('Video consultation connects the patient to a healthcare professional. It does not replace emergency care.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE2EBE8)), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 16, offset: Offset(0, 5))]),
    child: child,
  );

  Widget _info(IconData icon, String text) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: const Color(0xFFF6FAF9), borderRadius: BorderRadius.circular(15)),
    child: Row(children: [Icon(icon, size: 18, color: AppTheme.primary), const SizedBox(width: 8), Expanded(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)))]),
  );

  Widget _check(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, size: 20, color: AppTheme.success),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.35),
          ),
        ),
      ],
    ),
  );
}
