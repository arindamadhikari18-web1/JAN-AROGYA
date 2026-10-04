import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  static const String _appointmentKey = 'appointments';

  // =====================================================
  // SAVE APPOINTMENT
  // =====================================================

  static Future<bool> saveAppointment({
    String? id,
    String? doctorName,
    String? doctor,
    String? specialty,
    String? speciality,
    String? hospitalName,
    required String date,
    required String time,
    String? reason,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final appointments = await getAppointments();

      // Support both doctorName and doctor
      final selectedDoctor = doctorName ?? doctor ?? '';

      // Support both specialty and speciality
      final selectedSpecialty = specialty ?? speciality ?? '';

      final newAppointment = <String, dynamic>{
        'id': id ?? DateTime.now().microsecondsSinceEpoch.toString(),

        // Main appointment details
        'doctorName': selectedDoctor,
        'doctor': selectedDoctor,

        'specialty': selectedSpecialty,
        'speciality': selectedSpecialty,

        'hospitalName': hospitalName ?? 'JAN AROGYA Healthcare',
        'date': date,
        'time': time,
        'reason': reason ?? 'General Consultation',

        // Appointment status
        'status': 'Upcoming',

        // Date information
        'createdAt': DateTime.now().toIso8601String(),
      };

      appointments.add(newAppointment);

      return await prefs.setString(
        _appointmentKey,
        jsonEncode(appointments),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // GET ALL APPOINTMENTS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final appointmentsJson = prefs.getString(_appointmentKey);

      if (appointmentsJson == null || appointmentsJson.isEmpty) {
        return [];
      }

      final decodedData = jsonDecode(appointmentsJson);

      if (decodedData is! List) {
        return [];
      }

      return decodedData.map<Map<String, dynamic>>((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // GET ACTIVE APPOINTMENTS
  // Used by MyAppointmentsScreen
  // =====================================================

  static Future<List<Map<String, dynamic>>> getActiveAppointments() async {
    try {
      final appointments = await getAppointments();

      return appointments.where((appointment) {
        final status = appointment['status']
                ?.toString()
                .toLowerCase() ??
            'upcoming';

        return status != 'cancelled' && status != 'completed';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // GET UPCOMING APPOINTMENTS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    try {
      final appointments = await getAppointments();

      return appointments.where((appointment) {
        final status = appointment['status']
                ?.toString()
                .toLowerCase() ??
            '';

        return status == 'upcoming';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // GET COMPLETED APPOINTMENTS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getCompletedAppointments() async {
    try {
      final appointments = await getAppointments();

      return appointments.where((appointment) {
        final status = appointment['status']
                ?.toString()
                .toLowerCase() ??
            '';

        return status == 'completed';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // GET CANCELLED APPOINTMENTS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getCancelledAppointments() async {
    try {
      final appointments = await getAppointments();

      return appointments.where((appointment) {
        final status = appointment['status']
                ?.toString()
                .toLowerCase() ??
            '';

        return status == 'cancelled';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // UPDATE APPOINTMENT
  // =====================================================

  static Future<bool> updateAppointment({
    required String id,
    String? doctorName,
    String? doctor,
    String? specialty,
    String? speciality,
    String? hospitalName,
    required String date,
    required String time,
    String? reason,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final appointments = await getAppointments();

      final index = appointments.indexWhere(
        (appointment) => appointment['id'].toString() == id,
      );

      if (index == -1) {
        return false;
      }

      final selectedDoctor =
          doctorName ?? doctor ?? appointments[index]['doctorName'] ?? '';

      final selectedSpecialty =
          specialty ??
              speciality ??
              appointments[index]['specialty'] ??
              '';

      appointments[index]['doctorName'] = selectedDoctor;
      appointments[index]['doctor'] = selectedDoctor;

      appointments[index]['specialty'] = selectedSpecialty;
      appointments[index]['speciality'] = selectedSpecialty;

      appointments[index]['hospitalName'] =
          hospitalName ?? appointments[index]['hospitalName'] ?? '';

      appointments[index]['date'] = date;
      appointments[index]['time'] = time;

      appointments[index]['reason'] =
          reason ?? appointments[index]['reason'] ?? '';

      appointments[index]['updatedAt'] =
          DateTime.now().toIso8601String();

      return await prefs.setString(
        _appointmentKey,
        jsonEncode(appointments),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // UPDATE APPOINTMENT STATUS
  // =====================================================

  static Future<bool> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final appointments = await getAppointments();

      final index = appointments.indexWhere(
        (appointment) => appointment['id'].toString() == id,
      );

      if (index == -1) {
        return false;
      }

      appointments[index]['status'] = status;
      appointments[index]['updatedAt'] =
          DateTime.now().toIso8601String();

      return await prefs.setString(
        _appointmentKey,
        jsonEncode(appointments),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // CANCEL APPOINTMENT
  // =====================================================

  static Future<bool> cancelAppointment(
    String appointmentId,
  ) async {
    return updateAppointmentStatus(
      id: appointmentId,
      status: 'Cancelled',
    );
  }

  // =====================================================
  // MARK APPOINTMENT AS COMPLETED
  // =====================================================

  static Future<bool> completeAppointment(
    String appointmentId,
  ) async {
    return updateAppointmentStatus(
      id: appointmentId,
      status: 'Completed',
    );
  }

  // =====================================================
  // REACTIVATE APPOINTMENT
  // =====================================================

  static Future<bool> reactivateAppointment(
    String appointmentId,
  ) async {
    return updateAppointmentStatus(
      id: appointmentId,
      status: 'Upcoming',
    );
  }

  // =====================================================
  // DELETE APPOINTMENT
  // =====================================================

  static Future<bool> deleteAppointment(
    String appointmentId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final appointments = await getAppointments();

      final originalLength = appointments.length;

      appointments.removeWhere(
        (appointment) =>
            appointment['id'].toString() == appointmentId,
      );

      if (appointments.length == originalLength) {
        return false;
      }

      return await prefs.setString(
        _appointmentKey,
        jsonEncode(appointments),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // GET APPOINTMENT BY ID
  // =====================================================

  static Future<Map<String, dynamic>?> getAppointmentById(
    String appointmentId,
  ) async {
    try {
      final appointments = await getAppointments();

      final index = appointments.indexWhere(
        (appointment) =>
            appointment['id'].toString() == appointmentId,
      );

      if (index == -1) {
        return null;
      }

      return appointments[index];
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // CLEAR ALL APPOINTMENTS
  // =====================================================

  static Future<bool> clearAllAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return await prefs.remove(_appointmentKey);
    } catch (e) {
      return false;
    }
  }
}