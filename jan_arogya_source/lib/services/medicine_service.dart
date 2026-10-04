import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MedicineService {
  static const String _medicineKey = 'medicines';

  // =====================================================
  // GET ALL MEDICINES
  // =====================================================

  static Future<List<Map<String, dynamic>>> getMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? medicinesJson = prefs.getString(_medicineKey);

      if (medicinesJson == null || medicinesJson.isEmpty) {
        return [];
      }

      final dynamic decodedData = jsonDecode(medicinesJson);

      if (decodedData is! List) {
        return [];
      }

      return decodedData
          .whereType<Map>()
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // SAVE MEDICINE
  // =====================================================

  static Future<bool> saveMedicine({
    required String name,
    required String dosage,
    required String time,
    required String frequency,
    required int notificationId,
    required String memberId,
    required String memberName,
    required String relation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicines = await getMedicines();

      final now = DateTime.now();

      final newMedicine = <String, dynamic>{
        'id': now.microsecondsSinceEpoch.toString(),

        // Medicine details
        'name': name,
        'dosage': dosage,
        'time': time,
        'frequency': frequency,

        // Family member details
        'memberId': memberId,
        'memberName': memberName,
        'relation': relation,

        // Notification
        'notificationId': notificationId,

        // Status
        'isTaken': false,
        'takenAt': null,

        // Dates
        'createdAt': now.toIso8601String(),
        'updatedAt': null,
      };

      medicines.add(newMedicine);

      return await prefs.setString(
        _medicineKey,
        jsonEncode(medicines),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // UPDATE MEDICINE
  // =====================================================

  static Future<bool> updateMedicine({
    required String id,
    required int notificationId,
    required String name,
    required String dosage,
    required String time,
    required String frequency,
    required String memberId,
    required String memberName,
    required String relation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicines = await getMedicines();

      final index = medicines.indexWhere(
        (medicine) => medicine['id']?.toString() == id,
      );

      if (index == -1) {
        return false;
      }

      medicines[index] = {
        ...medicines[index],

        // Updated medicine details
        'name': name,
        'dosage': dosage,
        'time': time,
        'frequency': frequency,

        // Updated person details
        'memberId': memberId,
        'memberName': memberName,
        'relation': relation,

        // Notification
        'notificationId': notificationId,

        // Date
        'updatedAt': DateTime.now().toIso8601String(),
      };

      return await prefs.setString(
        _medicineKey,
        jsonEncode(medicines),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // TOGGLE MEDICINE TAKEN STATUS
  // =====================================================

  static Future<bool> toggleMedicineTaken({
    required String id,
    required bool isTaken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicines = await getMedicines();

      final index = medicines.indexWhere(
        (medicine) => medicine['id']?.toString() == id,
      );

      if (index == -1) {
        return false;
      }

      medicines[index]['isTaken'] = isTaken;

      medicines[index]['takenAt'] = isTaken
          ? DateTime.now().toIso8601String()
          : null;

      medicines[index]['updatedAt'] =
          DateTime.now().toIso8601String();

      return await prefs.setString(
        _medicineKey,
        jsonEncode(medicines),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // DELETE MEDICINE
  // =====================================================

  static Future<bool> deleteMedicine(
    String medicineId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicines = await getMedicines();

      final originalLength = medicines.length;

      medicines.removeWhere(
        (medicine) =>
            medicine['id']?.toString() == medicineId,
      );

      if (medicines.length == originalLength) {
        return false;
      }

      return await prefs.setString(
        _medicineKey,
        jsonEncode(medicines),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // GET SINGLE MEDICINE BY ID
  // =====================================================

  static Future<Map<String, dynamic>?> getMedicineById(
    String medicineId,
  ) async {
    try {
      final medicines = await getMedicines();

      final index = medicines.indexWhere(
        (medicine) =>
            medicine['id']?.toString() == medicineId,
      );

      if (index == -1) {
        return null;
      }

      return medicines[index];
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // GET MEDICINES FOR SPECIFIC MEMBER
  // =====================================================

  static Future<List<Map<String, dynamic>>>
      getMedicinesForMember(
    String memberId,
  ) async {
    try {
      final medicines = await getMedicines();

      return medicines.where(
        (medicine) =>
            medicine['memberId']?.toString() == memberId,
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // GET SELF MEDICINES
  // =====================================================

  static Future<List<Map<String, dynamic>>>
      getSelfMedicines() async {
    try {
      return await getMedicinesForMember('self');
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // GET TAKEN MEDICINES
  // =====================================================

  static Future<List<Map<String, dynamic>>>
      getTakenMedicines() async {
    try {
      final medicines = await getMedicines();

      return medicines.where(
        (medicine) => medicine['isTaken'] == true,
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // GET PENDING MEDICINES
  // =====================================================

  static Future<List<Map<String, dynamic>>>
      getPendingMedicines() async {
    try {
      final medicines = await getMedicines();

      return medicines.where(
        (medicine) => medicine['isTaken'] != true,
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // RESET ALL MEDICINE STATUS
  // =====================================================

  static Future<bool> resetAllMedicineTakenStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medicines = await getMedicines();

      for (final medicine in medicines) {
        medicine['isTaken'] = false;
        medicine['takenAt'] = null;
        medicine['updatedAt'] =
            DateTime.now().toIso8601String();
      }

      return await prefs.setString(
        _medicineKey,
        jsonEncode(medicines),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // DELETE ALL MEDICINES
  // =====================================================

  static Future<bool> clearAllMedicines() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return await prefs.remove(_medicineKey);
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // TOTAL MEDICINE COUNT
  // =====================================================

  static Future<int> getMedicineCount() async {
    try {
      final medicines = await getMedicines();
      return medicines.length;
    } catch (e) {
      return 0;
    }
  }
}