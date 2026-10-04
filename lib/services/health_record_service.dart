import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HealthRecordService {
  static const String _recordsKey = 'health_records';

  // =====================================================
  // SAVE HEALTH RECORD
  // =====================================================

  static Future<bool> saveHealthRecord({
    required String recordType,
    required String title,
    required String date,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> records =
          await getHealthRecords();

      final Map<String, dynamic> newRecord = {
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'recordType': recordType,
        'title': title,
        'date': date,
        'description': description,
        'createdAt': DateTime.now().toIso8601String(),
      };

      records.add(newRecord);

      return await prefs.setString(
        _recordsKey,
        jsonEncode(records),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // GET ALL HEALTH RECORDS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getHealthRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? recordsJson = prefs.getString(_recordsKey);

      if (recordsJson == null || recordsJson.isEmpty) {
        return [];
      }

      final dynamic decodedData = jsonDecode(recordsJson);

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
  // DELETE HEALTH RECORD
  // =====================================================

  static Future<bool> deleteHealthRecord(String recordId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> records =
          await getHealthRecords();

      final int originalLength = records.length;

      records.removeWhere(
        (record) => record['id'].toString() == recordId,
      );

      if (records.length == originalLength) {
        return false;
      }

      return await prefs.setString(
        _recordsKey,
        jsonEncode(records),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // CLEAR ALL HEALTH RECORDS
  // =====================================================

  static Future<bool> clearAllHealthRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return await prefs.remove(_recordsKey);
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // CHECK IF RECORDS EXIST
  // =====================================================

  static Future<bool> hasHealthRecords() async {
    final records = await getHealthRecords();
    return records.isNotEmpty;
  }
}