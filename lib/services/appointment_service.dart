import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  static const String _appointmentKey = 'appointments';

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
    String consultationMode = 'In-clinic',
    String? meetingUrl,
    String facilityType = 'Healthcare Centre',
    String? patientNote,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointments = await getAppointments();
      final selectedDoctor = doctorName ?? doctor ?? '';
      final selectedSpecialty = specialty ?? speciality ?? '';
      final newAppointment = <String, dynamic>{
        'id': id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        'doctorName': selectedDoctor,
        'doctor': selectedDoctor,
        'specialty': selectedSpecialty,
        'speciality': selectedSpecialty,
        'hospitalName': hospitalName ?? 'JAN AROGYA Healthcare',
        'facilityType': facilityType,
        'date': date,
        'time': time,
        'reason': reason ?? 'General Consultation',
        'patientNote': patientNote ?? '',
        'consultationMode': consultationMode,
        'meetingUrl': meetingUrl ?? '',
        'status': 'Upcoming',
        'createdAt': DateTime.now().toIso8601String(),
      };
      appointments.add(newAppointment);
      return await prefs.setString(_appointmentKey, jsonEncode(appointments));
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_appointmentKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map<Map<String, dynamic>>((item) =>
          Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getActiveAppointments() async {
    final appointments = await getAppointments();
    return appointments.where((a) {
      final status = a['status']?.toString().toLowerCase() ?? 'upcoming';
      return status != 'cancelled' && status != 'completed';
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    final appointments = await getAppointments();
    return appointments.where((a) =>
        (a['status']?.toString().toLowerCase() ?? '') == 'upcoming').toList();
  }

  static Future<List<Map<String, dynamic>>> getCompletedAppointments() async {
    final appointments = await getAppointments();
    return appointments.where((a) =>
        (a['status']?.toString().toLowerCase() ?? '') == 'completed').toList();
  }

  static Future<List<Map<String, dynamic>>> getCancelledAppointments() async {
    final appointments = await getAppointments();
    return appointments.where((a) =>
        (a['status']?.toString().toLowerCase() ?? '') == 'cancelled').toList();
  }

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
    String? consultationMode,
    String? meetingUrl,
    String? facilityType,
    String? patientNote,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointments = await getAppointments();
      final index = appointments.indexWhere((a) => a['id'].toString() == id);
      if (index == -1) return false;
      final a = appointments[index];
      final selectedDoctor = doctorName ?? doctor ?? a['doctorName'] ?? '';
      final selectedSpecialty = specialty ?? speciality ?? a['specialty'] ?? '';
      a['doctorName'] = selectedDoctor;
      a['doctor'] = selectedDoctor;
      a['specialty'] = selectedSpecialty;
      a['speciality'] = selectedSpecialty;
      a['hospitalName'] = hospitalName ?? a['hospitalName'] ?? '';
      a['facilityType'] = facilityType ?? a['facilityType'] ?? 'Healthcare Centre';
      a['date'] = date;
      a['time'] = time;
      a['reason'] = reason ?? a['reason'] ?? '';
      a['patientNote'] = patientNote ?? a['patientNote'] ?? '';
      a['consultationMode'] = consultationMode ?? a['consultationMode'] ?? 'In-clinic';
      a['meetingUrl'] = meetingUrl ?? a['meetingUrl'] ?? '';
      a['updatedAt'] = DateTime.now().toIso8601String();
      return await prefs.setString(_appointmentKey, jsonEncode(appointments));
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateAppointmentStatus({
    required String id,
    required String status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointments = await getAppointments();
      final index = appointments.indexWhere((a) => a['id'].toString() == id);
      if (index == -1) return false;
      appointments[index]['status'] = status;
      appointments[index]['updatedAt'] = DateTime.now().toIso8601String();
      return await prefs.setString(_appointmentKey, jsonEncode(appointments));
    } catch (_) {
      return false;
    }
  }

  static Future<bool> cancelAppointment(String appointmentId) =>
      updateAppointmentStatus(id: appointmentId, status: 'Cancelled');

  static Future<bool> completeAppointment(String appointmentId) =>
      updateAppointmentStatus(id: appointmentId, status: 'Completed');

  static Future<bool> reactivateAppointment(String appointmentId) =>
      updateAppointmentStatus(id: appointmentId, status: 'Upcoming');

  static Future<bool> deleteAppointment(String appointmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final appointments = await getAppointments();
      final oldLength = appointments.length;
      appointments.removeWhere((a) => a['id'].toString() == appointmentId);
      if (oldLength == appointments.length) return false;
      return await prefs.setString(_appointmentKey, jsonEncode(appointments));
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getAppointmentById(String appointmentId) async {
    final appointments = await getAppointments();
    for (final a in appointments) {
      if (a['id'].toString() == appointmentId) return a;
    }
    return null;
  }

  static Future<bool> clearAllAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_appointmentKey);
    } catch (_) {
      return false;
    }
  }
}
