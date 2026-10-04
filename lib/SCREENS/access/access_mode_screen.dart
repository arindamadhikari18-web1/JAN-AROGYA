import 'package:flutter/material.dart';
import '../emergency/emergency_screen.dart';
import '../auth/hospital_login_screen.dart';
import '../auth/lab_login_screen.dart';

class AccessModeScreen extends StatelessWidget {
  final String emergencyContact;
  const AccessModeScreen({super.key, required this.emergencyContact});
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF62758A);
  static const Color background = Color(0xFFF7FAF9);

  void _open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: const Text('Login As'), backgroundColor: background, elevation: 0),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF00A878)]), borderRadius: BorderRadius.circular(25)), child: const Row(children: [Icon(Icons.lock_open_rounded, color: Colors.white, size: 42), SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Choose your access', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)), SizedBox(height: 5), Text('Separate login pages for patients, hospitals and labs.', style: TextStyle(color: Colors.white70, height: 1.35))]))])),
        const SizedBox(height: 20),
        _card(context, Icons.person_rounded, 'User', 'Continue to patient login.', const Color(0xFF2878E8), () => Navigator.pop(context)),
        _card(context, Icons.local_hospital_rounded, 'Hospital', 'Open the dedicated hospital login.', const Color(0xFF00A878), () => _open(context, const HospitalLoginScreen())),
        _card(context, Icons.science_rounded, 'Lab Shop', 'Open the dedicated laboratory login.', const Color(0xFF7653D6), () => _open(context, const LabLoginScreen())),
        _card(context, Icons.emergency_rounded, 'Emergency Guest Mode', 'No login required for emergency tools.', const Color(0xFFD94A42), () => _open(context, EmergencyScreen(emergencyContact: emergencyContact))),
        const SizedBox(height: 10),
        const Text('Emergency Guest Mode does not replace professional emergency care.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: textSecondary, height: 1.4)),
      ])),
    );
  }

  Widget _card(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) => Card(
    elevation: 0, margin: const EdgeInsets.only(bottom: 12), color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22), side: const BorderSide(color: Color(0xFFE0ECE8))),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: color, size: 29)),
      const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textPrimary)), const SizedBox(height: 5), Text(subtitle, style: const TextStyle(fontSize: 12, height: 1.35, color: textSecondary))])),
      Icon(Icons.chevron_right_rounded, color: color),
    ]))),
  );
}
