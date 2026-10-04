import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() =>
      _LabDashboardScreenState();
}

class _LabDashboardScreenState
    extends State<LabDashboardScreen> {
  static const Color _purple = Color(0xFF6C4AB6);
  static const Color _light = Color(0xFFF1ECFB);
  static const Color _text = Color(0xFF24202D);
  static const Color _secondary = Color(0xFF77727F);
  static const Color _green = Color(0xFF2E9D68);
  static const Color _orange = Color(0xFFE98B35);
  static const Color _red = Color(0xFFD9534F);

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
            'Are you sure you want to logout from the lab dashboard?',
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
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
              ),
              label: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      // Firebase logout
      await FirebaseAuth.instance.signOut();

      // Clear application login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      // Clear possible organisation/session values.
      await prefs.remove('userRole');
      await prefs.remove('accountType');
      await prefs.remove('loginType');
      await prefs.remove('labLoggedIn');

      if (!mounted) return;

      // Remove dashboard completely.
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
          content: Text(
            'Logout failed. Please try again.',
          ),
        ),
      );
    }
  }

  void _showMessage(
    BuildContext context,
    String title,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title is ready for backend integration.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _text,
        title: const Text(
          'Lab Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              _showMessage(
                context,
                'Notifications',
              );
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),

          // LOGOUT
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context),

              const SizedBox(height: 20),

              const Text(
                'Today at a glance',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),

              const SizedBox(height: 12),

              _buildStatistics(),

              const SizedBox(height: 24),

              const Text(
                'Lab Management',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),

              const SizedBox(height: 12),

              _item(
                context,
                Icons.science_outlined,
                'Available Tests',
                'Manage laboratory tests and pricing',
                '28 Tests',
              ),

              _item(
                context,
                Icons.calendar_month_rounded,
                'Test Bookings',
                'View upcoming patient bookings',
                '12 Today',
              ),

              _item(
                context,
                Icons.pending_actions_rounded,
                'Pending Reports',
                'Reports waiting for processing',
                '7 Pending',
              ),

              _item(
                context,
                Icons.upload_file_rounded,
                'Upload Reports',
                'Upload and share patient reports',
                '5 Due',
              ),

              _item(
                context,
                Icons.people_alt_outlined,
                'Patient Records',
                'View laboratory patient history',
                '146 Patients',
              ),

              _item(
                context,
                Icons.home_work_outlined,
                'Home Sample Collection',
                'Manage home collection requests',
                '4 Requests',
              ),

              const SizedBox(height: 24),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: _text,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      context,
                      Icons.add_circle_outline_rounded,
                      'Add Test',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickAction(
                      context,
                      Icons.file_upload_outlined,
                      'Upload Report',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      context,
                      Icons.person_search_outlined,
                      'Patients',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickAction(
                      context,
                      Icons.bar_chart_rounded,
                      'Analytics',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildLabInformation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C4AB6),
            Color(0xFF8D6BC7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
              ),
              child: Icon(
                Icons.biotech_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Lab Partner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage tests, bookings and patient reports.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
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

  Widget _buildStatistics() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.55,
      children: [
        _statCard(
          icon: Icons.calendar_today_rounded,
          title: 'Bookings',
          value: '12',
          color: _purple,
        ),
        _statCard(
          icon: Icons.pending_actions_rounded,
          title: 'Pending',
          value: '7',
          color: _orange,
        ),
        _statCard(
          icon: Icons.check_circle_outline_rounded,
          title: 'Completed',
          value: '34',
          color: _green,
        ),
        _statCard(
          icon: Icons.people_alt_outlined,
          title: 'Patients',
          value: '146',
          color: _red,
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E4ED),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: _secondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
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
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String value,
  ) {
    return Card(
      elevation: 0,
      margin:
          const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE6E0F5),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _light,
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _purple,
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: _purple,
              ),
            ),
            const SizedBox(height: 2),
            const Icon(
              Icons.chevron_right_rounded,
              color: _purple,
              size: 20,
            ),
          ],
        ),
        onTap: () {
          _showMessage(context, title);
        },
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(18),
      onTap: () {
        _showMessage(context, title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE6E0F5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _light,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: _purple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabInformation(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _light,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.biotech_rounded,
                color: _purple,
              ),
              SizedBox(width: 9),
              Text(
                'Lab Information',
                style: TextStyle(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'JAN AROGYA Diagnostic Laboratory',
            style: TextStyle(
              color: _text,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Laboratory partner dashboard • Demo data',
            style: TextStyle(
              color: _secondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showMessage(
                  context,
                  'Lab Profile',
                );
              },
              icon: const Icon(
                Icons.settings_outlined,
              ),
              label: const Text(
                'Manage Lab Profile',
              ),
            ),
          ),
        ],
      ),
    );
  }
}