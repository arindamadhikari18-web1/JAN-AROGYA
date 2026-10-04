import 'package:flutter/material.dart';

class RolePortalScreen extends StatelessWidget {
  final String role;

  const RolePortalScreen({
    super.key,
    required this.role,
  });

  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF62758A);
  static const Color background = Color(0xFFF7FAF9);

  @override
  Widget build(BuildContext context) {
    final bool hospital = role == 'Hospital';
    final Color accent = hospital ? const Color(0xFF00A878) : const Color(0xFF7653D6);

    final List<Map<String, dynamic>> items = hospital
        ? [
            {'icon': Icons.calendar_month_rounded, 'title': 'Appointment Queue', 'value': '18'},
            {'icon': Icons.people_alt_outlined, 'title': 'Patients Today', 'value': '42'},
            {'icon': Icons.meeting_room_outlined, 'title': 'OPD Services', 'value': '8'},
            {'icon': Icons.bed_outlined, 'title': 'Beds Available', 'value': '24'},
          ]
        : [
            {'icon': Icons.science_outlined, 'title': 'Test Bookings', 'value': '16'},
            {'icon': Icons.home_work_outlined, 'title': 'Home Collections', 'value': '7'},
            {'icon': Icons.pending_actions_rounded, 'title': 'Pending Reports', 'value': '5'},
            {'icon': Icons.receipt_long_outlined, 'title': 'Reports Ready', 'value': '11'},
          ];

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('$role Portal'),
        backgroundColor: background,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(hospital ? Icons.local_hospital_rounded : Icons.science_rounded, color: Colors.white, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$role Management', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 5),
                      const Text('Prototype partner dashboard for the Jan Arogya ecosystem.', style: TextStyle(color: Colors.white70, height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 145,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0ECE8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item['icon'] as IconData, color: accent, size: 28),
                    const Spacer(),
                    Text(item['value'].toString(), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800, color: textPrimary)),
                    const SizedBox(height: 3),
                    Text(item['title'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: textSecondary)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          _actionTile(context, accent, Icons.notifications_active_outlined, 'Notifications', 'View important workflow updates.'),
          _actionTile(context, accent, Icons.settings_outlined, 'Service Settings', 'Manage availability and service information.'),
          _actionTile(context, accent, Icons.analytics_outlined, 'Reports & Analytics', 'Review operational summaries.'),
        ],
      ),
    );
  }

  Widget _actionTile(BuildContext context, Color accent, IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE0ECE8)),
      ),
      child: ListTile(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title is ready for backend integration.')),
          );
        },
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: accent.withOpacity(.10), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: accent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: textSecondary)),
        trailing: Icon(Icons.chevron_right_rounded, color: accent),
      ),
    );
  }
}
