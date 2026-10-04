import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';

class EmergencyScreen extends StatelessWidget {
  final String emergencyContact;

  const EmergencyScreen({
    super.key,
    required this.emergencyContact,
  });

  // ============================================================
  // OPEN PHONE DIALER
  // ============================================================

  Future<void> _callEmergencyContact(BuildContext context) async {
    if (emergencyContact.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add an emergency contact in your profile',
          ),
        ),
      );
      return;
    }

    // Remove spaces, brackets, hyphens etc.
    final String phoneNumber =
        emergencyContact.replaceAll(RegExp(r'[^0-9+]'), '');

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      final bool launched = await launchUrl(phoneUri);

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open phone dialer'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to call emergency contact'),
          ),
        );
      }
    }
  }

  // ============================================================
  // FIND NEAREST HOSPITAL
  // ============================================================

  Future<void> _findNearestHospital(BuildContext context) async {
    final Uri hospitalUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=hospitals+near+me',
    );

    try {
      final bool launched = await launchUrl(
        hospitalUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open nearby hospitals'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Google Maps'),
          ),
        );
      }
    }
  }

  // ============================================================
  // SHARE LOCATION
  // ============================================================

  Future<void> _shareLocation(BuildContext context) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps',
    );

    try {
      final bool launched = await launchUrl(
        mapsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open Maps'),
          ),
        );
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Google Maps opened. You can use the Share option to share your location.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share location'),
          ),
        );
      }
    }
  }

  // ============================================================
  // SOS DIALOG
  // ============================================================

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Emergency SOS'),
              ),
            ],
          ),
          content: Text(
            emergencyContact.trim().isEmpty
                ? 'Emergency assistance has been requested. Please contact local emergency services or the nearest hospital immediately.'
                : 'An emergency has been detected. You can immediately contact your emergency contact: $emergencyContact',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SOS Alert Activated!'),
                    backgroundColor: Colors.red,
                  ),
                );

                if (emergencyContact.trim().isNotEmpty) {
                  await _callEmergencyContact(context);
                }
              },
              child: const Text('Send SOS'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // MEDICAL INFORMATION
  // ============================================================

  void _showMedicalInformation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.medical_services_rounded,
                color: Colors.purple,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Emergency Medical Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MedicalInfoRow(
                  icon: Icons.bloodtype_rounded,
                  title: 'Blood Group',
                  value: 'Check your Profile',
                ),
                SizedBox(height: 14),
                _MedicalInfoRow(
                  icon: Icons.person_rounded,
                  title: 'Patient Information',
                  value: 'Check your Profile',
                ),
                SizedBox(height: 14),
                _MedicalInfoRow(
                  icon: Icons.medical_information_rounded,
                  title: 'Health Records',
                  value: 'Available in Health Records section',
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // EMERGENCY OPTION CARD
  // ============================================================

  Widget _buildEmergencyOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.red,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8EDF2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Emergency Help',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // SOS CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.red.shade100,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emergency_rounded,
                    color: Colors.red,
                    size: 70,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Need Immediate Help?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use the SOS button to quickly request emergency assistance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEmergencyDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.warning_rounded,
                      ),
                      label: const Text(
                        'SEND SOS ALERT',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // EMERGENCY CONTACT
            _buildEmergencyOption(
              context: context,
              icon: Icons.call_rounded,
              title: 'Emergency Contact',
              subtitle: emergencyContact.isEmpty
                  ? 'No emergency contact added'
                  : emergencyContact,
              onTap: () {
                _callEmergencyContact(context);
              },
            ),

            const SizedBox(height: 14),

            // NEAREST HOSPITAL
            _buildEmergencyOption(
              context: context,
              icon: Icons.local_hospital_rounded,
              title: 'Find Nearest Hospital',
              subtitle:
                  'Open Maps to locate nearby hospitals and healthcare facilities',
              onTap: () {
                _findNearestHospital(context);
              },
              iconColor: AppTheme.primary,
            ),

            const SizedBox(height: 14),

            // SHARE LOCATION
            _buildEmergencyOption(
              context: context,
              icon: Icons.location_on_rounded,
              title: 'Share My Location',
              subtitle:
                  'Open Maps and share your current location during an emergency',
              onTap: () {
                _shareLocation(context);
              },
              iconColor: Colors.orange,
            ),

            const SizedBox(height: 14),

            // MEDICAL INFORMATION
            _buildEmergencyOption(
              context: context,
              icon: Icons.medical_services_rounded,
              title: 'Emergency Medical Information',
              subtitle:
                  'Quick access to important health information',
              onTap: () {
                _showMedicalInformation(context);
              },
              iconColor: Colors.purple,
            ),

            const SizedBox(height: 30),

            Text(
              'In case of a life-threatening emergency, contact your local emergency services immediately.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MEDICAL INFO ROW
// ============================================================

class _MedicalInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MedicalInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}