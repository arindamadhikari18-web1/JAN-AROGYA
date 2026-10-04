import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';

class HospitalDashboardScreen extends StatefulWidget {
  const HospitalDashboardScreen({super.key});

  @override
  State<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  static const Color _green = Color(0xFF0F766E);
  static const Color _light = Color(0xFFE7F8F4);
  static const Color _text = Color(0xFF102A43);
  static const Color _secondary = Color(0xFF62758A);

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout from the hospital dashboard?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool('isLoggedIn', false);

      await prefs.remove('userRole');
      await prefs.remove('accountType');
      await prefs.remove('loginType');
      await prefs.remove('hospitalLoggedIn');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
        ),
      );
    }
  }

  void _showMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title is ready for backend integration.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF9),

      appBar: AppBar(
        title: const Text(
          'Hospital Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _text,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              _showMessage('Notifications');
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),

          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          4,
          18,
          30,
        ),
        children: [
          _hero(),

          const SizedBox(height: 20),

          const Text(
            'Hospital overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),

          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.22,
            children: const [
              _Stat(
                icon: Icons.calendar_month_rounded,
                value: '18',
                label: 'Appointments',
              ),
              _Stat(
                icon: Icons.people_alt_outlined,
                value: '42',
                label: 'Patients today',
              ),
              _Stat(
                icon: Icons.bed_outlined,
                value: '24',
                label: 'Beds available',
              ),
              _Stat(
                icon: Icons.emergency_rounded,
                value: '6',
                label: 'Emergency cases',
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Hospital management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),

          const SizedBox(height: 12),

          _item(
            Icons.bed_outlined,
            'Bed Availability',
            'General, ICU and emergency beds',
            '24 available',
          ),

          _item(
            Icons.calendar_month_rounded,
            'Appointments',
            'Manage patient appointment requests',
            '18 today',
          ),

          _item(
            Icons.people_alt_outlined,
            'Patients',
            'View and manage patient visits',
            '42 today',
          ),

          _item(
            Icons.medical_services_outlined,
            'Doctors & Departments',
            'Manage hospital care services',
            '12 departments',
          ),

          _item(
            Icons.emergency_rounded,
            'Emergency Requests',
            'Monitor urgent care requests',
            '6 active',
          ),

          _item(
            Icons.analytics_outlined,
            'Reports & Analytics',
            'View hospital activity summaries',
            'Open reports',
          ),

          const SizedBox(height: 8),

          _beds(),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF075E54),
            Color(0xFF0F9D8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JAN AROGYA Hospital Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  'Manage hospital operations, beds and patient care.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(
    IconData icon,
    String title,
    String subtitle,
    String value,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE0ECE8),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),

        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _light,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _green,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: _text,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11.5,
            color: _secondary,
          ),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: _green,
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: _green,
            ),
          ],
        ),

        onTap: () {
          _showMessage(title);
        },
      ),
    );
  }

  Widget _beds() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _light,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live bed status',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _text,
            ),
          ),

          const SizedBox(height: 12),

          const _BedRow(
            name: 'General beds',
            available: '16 available',
            total: '40 total',
          ),

          const _BedRow(
            name: 'ICU beds',
            available: '5 available',
            total: '12 total',
          ),

          const _BedRow(
            name: 'Emergency beds',
            available: '3 available',
            total: '8 total',
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Bed management opened.',
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit_outlined,
              ),
              label: const Text(
                'Update bed availability',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
  });

  static const Color green = Color(0xFF0F766E);
  static const Color text = Color(0xFF102A43);
  static const Color secondary = Color(0xFF62758A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0ECE8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: green,
            size: 27,
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: text,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: secondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BED ROW
// ============================================================

class _BedRow extends StatelessWidget {
  final String name;
  final String available;
  final String total;

  const _BedRow({
    required this.name,
    required this.available,
    required this.total,
  });

  static const Color green = Color(0xFF0F766E);
  static const Color text = Color(0xFF102A43);
  static const Color secondary = Color(0xFF62758A);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
          ),

          Text(
            available,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: green,
            ),
          ),

          const SizedBox(width: 8),

          Text(
            total,
            style: const TextStyle(
              fontSize: 11,
              color: secondary,
            ),
          ),
        ],
      ),
    );
  }
}