import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/appointment_service.dart';
import '../../main.dart';
import 'book_appointment_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState
    extends State<MyAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  // =====================================================
  // LANGUAGE TEXT
  // =====================================================

  String _t(
    BuildContext context,
    String en,
    String hi,
  ) {
    final languageCode =
        JanArogyaApp.of(context)?.currentLanguageCode ?? 'en';

    return languageCode == 'hi' ? hi : en;
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // =====================================================
  // LOAD APPOINTMENTS
  // =====================================================

  Future<void> _loadAppointments() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final appointments =
        await AppointmentService.getAppointments();

    if (!mounted) return;

    setState(() {
      _appointments = appointments;
      _isLoading = false;
    });
  }

  // =====================================================
  // FILTER APPOINTMENTS
  // =====================================================

  List<Map<String, dynamic>> _getAppointmentsByStatus(
    String status,
  ) {
    return _appointments.where((appointment) {
      final appointmentStatus =
          appointment['status']?.toString().toLowerCase() ??
              'upcoming';

      return appointmentStatus == status.toLowerCase();
    }).toList();
  }

  // =====================================================
  // BOOK NEW APPOINTMENT
  // =====================================================

  Future<void> _bookNewAppointment() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BookAppointmentScreen(),
      ),
    );

    await _loadAppointments();
  }

  // =====================================================
  // CANCEL APPOINTMENT
  // =====================================================

  Future<void> _cancelAppointment(
    Map<String, dynamic> appointment,
  ) async {
    final appointmentId =
        appointment['id']?.toString() ?? '';

    if (appointmentId.isEmpty) {
      _showMessage(
        _t(
          context,
          'Invalid appointment',
          'अमान्य अपॉइंटमेंट',
        ),
      );
      return;
    }

    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            _t(
              dialogContext,
              'Cancel Appointment?',
              'अपॉइंटमेंट रद्द करें?',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            _t(
              dialogContext,
              'Are you sure you want to cancel this appointment?',
              'क्या आप इस अपॉइंटमेंट को रद्द करना चाहते हैं?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                _t(
                  dialogContext,
                  'No, Keep It',
                  'नहीं, रहने दें',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                _t(
                  dialogContext,
                  'Yes, Cancel',
                  'हाँ, रद्द करें',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    final bool isCancelled =
        await AppointmentService.cancelAppointment(
      appointmentId,
    );

    if (!mounted) return;

    if (isCancelled) {
      _showMessage(
        _t(
          context,
          'Appointment cancelled successfully',
          'अपॉइंटमेंट सफलतापूर्वक रद्द कर दिया गया',
        ),
      );

      await _loadAppointments();
    } else {
      _showMessage(
        _t(
          context,
          'Could not cancel appointment',
          'अपॉइंटमेंट रद्द नहीं किया जा सका',
        ),
      );
    }
  }

  // =====================================================
  // COMPLETE APPOINTMENT
  // =====================================================

  Future<void> _completeAppointment(
    Map<String, dynamic> appointment,
  ) async {
    final appointmentId =
        appointment['id']?.toString() ?? '';

    if (appointmentId.isEmpty) return;

    final bool isCompleted =
        await AppointmentService.completeAppointment(
      appointmentId,
    );

    if (!mounted) return;

    if (isCompleted) {
      _showMessage(
        _t(
          context,
          'Appointment marked as completed',
          'अपॉइंटमेंट को पूरा किया गया',
        ),
      );

      await _loadAppointments();
    }
  }

  // =====================================================
  // DELETE APPOINTMENT
  // =====================================================

  Future<void> _deleteAppointment(
    Map<String, dynamic> appointment,
  ) async {
    final appointmentId =
        appointment['id']?.toString() ?? '';

    if (appointmentId.isEmpty) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            _t(
              dialogContext,
              'Delete Appointment?',
              'अपॉइंटमेंट हटाएं?',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            _t(
              dialogContext,
              'This appointment will be permanently deleted.',
              'यह अपॉइंटमेंट स्थायी रूप से हटा दिया जाएगा।',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                _t(
                  dialogContext,
                  'Cancel',
                  'रद्द करें',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                _t(
                  dialogContext,
                  'Delete',
                  'हटाएं',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final bool isDeleted =
        await AppointmentService.deleteAppointment(
      appointmentId,
    );

    if (!mounted) return;

    if (isDeleted) {
      _showMessage(
        _t(
          context,
          'Appointment deleted successfully',
          'अपॉइंटमेंट सफलतापूर्वक हटा दिया गया',
        ),
      );

      await _loadAppointments();
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
  // STATUS COLOR
  // =====================================================

  Color _getStatusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green.shade50;

      case 'cancelled':
        return Colors.red.shade50;

      default:
        return AppTheme.primaryLight;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      default:
        return AppTheme.primary;
    }
  }

  // =====================================================
  // TRANSLATE STATUS
  // =====================================================

  String _getStatusText(
    BuildContext context,
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'completed':
        return _t(context, 'Completed', 'पूर्ण');

      case 'cancelled':
        return _t(context, 'Cancelled', 'रद्द');

      default:
        return _t(context, 'Upcoming', 'आगामी');
    }
  }

  // =====================================================
  // APPOINTMENT CARD
  // =====================================================

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
  ) {
    final String doctor =
        appointment['doctorName']?.toString() ??
            appointment['doctor']?.toString() ??
            _t(context, 'Doctor', 'डॉक्टर');

    final String speciality =
        appointment['specialty']?.toString() ??
            appointment['speciality']?.toString() ??
            '';

    final String hospital =
        appointment['hospitalName']?.toString() ??
            'JAN AROGYA Healthcare';

    final String date =
        appointment['date']?.toString() ?? '';

    final String time =
        appointment['time']?.toString() ?? '';

    final String status =
        appointment['status']?.toString() ?? 'Upcoming';

    final bool isUpcoming =
        status.toLowerCase() == 'upcoming';

    final bool isCompleted =
        status.toLowerCase() == 'completed';

    final bool isCancelled =
        status.toLowerCase() == 'cancelled';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE8EDF2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primary,
                  size: 34,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      speciality,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      _getStatusBackgroundColor(status),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(context, status),
                  style: TextStyle(
                    color:
                        _getStatusTextColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.local_hospital_rounded,
                size: 18,
                color: AppTheme.primary,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  hospital,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon:
                      Icons.calendar_month_rounded,
                  title:
                      _t(context, 'Date', 'तारीख'),
                  value: date,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildInfoItem(
                  icon:
                      Icons.access_time_rounded,
                  title:
                      _t(context, 'Time', 'समय'),
                  value: time,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          if (isUpcoming)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _completeAppointment(
                        appointment,
                      );
                    },
                    icon: const Icon(
                      Icons
                          .check_circle_outline_rounded,
                    ),
                    label: Text(
                      _t(
                        context,
                        'Complete',
                        'पूर्ण करें',
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _cancelAppointment(
                        appointment,
                      );
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                    ),
                    label: Text(
                      _t(
                        context,
                        'Cancel',
                        'रद्द करें',
                      ),
                    ),
                  ),
                ),
              ],
            ),

          if (isCompleted || isCancelled)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  _deleteAppointment(appointment);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
                label: Text(
                  _t(
                    context,
                    'Delete Appointment',
                    'अपॉइंटमेंट हटाएं',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // INFO ITEM
  // =====================================================

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 22,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
    bool showBookButton = false,
  }) {
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
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: 42,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            if (showBookButton) ...[
              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _bookNewAppointment,
                  icon: const Icon(
                    Icons
                        .add_circle_outline_rounded,
                  ),
                  label: Text(
                    _t(
                      context,
                      'Book Appointment',
                      'अपॉइंटमेंट बुक करें',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // APPOINTMENT LIST
  // =====================================================

  Widget _buildAppointmentList(
    List<Map<String, dynamic>> appointments, {
    required String emptyTitle,
    required String emptyMessage,
    required IconData emptyIcon,
    bool showBookButton = false,
  }) {
    if (appointments.isEmpty) {
      return _buildEmptyState(
        title: emptyTitle,
        message: emptyMessage,
        icon: emptyIcon,
        showBookButton: showBookButton,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          32,
        ),
        children: [
          ...appointments.map(
            (appointment) =>
                _buildAppointmentCard(
              appointment,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // MAIN UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final upcomingAppointments =
        _getAppointmentsByStatus('Upcoming');

    final completedAppointments =
        _getAppointmentsByStatus('Completed');

    final cancelledAppointments =
        _getAppointmentsByStatus('Cancelled');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF8FAFC),

        appBar: AppBar(
          title: Text(
            _t(
              context,
              'My Appointments',
              'मेरी अपॉइंटमेंट',
            ),
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

          bottom: TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primary,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            tabs: [
              Tab(
                text:
                    '${_t(context, 'Upcoming', 'आगामी')} (${upcomingAppointments.length})',
              ),
              Tab(
                text:
                    '${_t(context, 'Completed', 'पूर्ण')} (${completedAppointments.length})',
              ),
              Tab(
                text:
                    '${_t(context, 'Cancelled', 'रद्द')} (${cancelledAppointments.length})',
              ),
            ],
          ),
        ),

        floatingActionButton:
            FloatingActionButton.extended(
          onPressed: _bookNewAppointment,
          backgroundColor: AppTheme.primary,
          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
          ),
          label: Text(
            _t(
              context,
              'Book New',
              'नई बुकिंग',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        body: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              )
            : TabBarView(
                children: [
                  _buildAppointmentList(
                    upcomingAppointments,
                    emptyTitle: _t(
                      context,
                      'No Upcoming Appointments',
                      'कोई आगामी अपॉइंटमेंट नहीं',
                    ),
                    emptyMessage: _t(
                      context,
                      'You do not have any upcoming appointments. Book one to get started.',
                      'आपकी कोई आगामी अपॉइंटमेंट नहीं है। शुरू करने के लिए नई अपॉइंटमेंट बुक करें।',
                    ),
                    emptyIcon:
                        Icons.calendar_today_outlined,
                    showBookButton: true,
                  ),

                  _buildAppointmentList(
                    completedAppointments,
                    emptyTitle: _t(
                      context,
                      'No Completed Appointments',
                      'कोई पूर्ण अपॉइंटमेंट नहीं',
                    ),
                    emptyMessage: _t(
                      context,
                      'Your completed appointments will appear here.',
                      'आपकी पूरी हुई अपॉइंटमेंट यहां दिखाई देंगी।',
                    ),
                    emptyIcon:
                        Icons.check_circle_outline_rounded,
                  ),

                  _buildAppointmentList(
                    cancelledAppointments,
                    emptyTitle: _t(
                      context,
                      'No Cancelled Appointments',
                      'कोई रद्द अपॉइंटमेंट नहीं',
                    ),
                    emptyMessage: _t(
                      context,
                      'Cancelled appointments will appear here.',
                      'रद्द की गई अपॉइंटमेंट यहां दिखाई देंगी।',
                    ),
                    emptyIcon:
                        Icons.cancel_outlined,
                  ),
                ],
              ),
      ),
    );
  }
}