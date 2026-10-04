import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FamilyService {
  static const String _familyKey = 'family_profiles';

  // =====================================================
  // GET ALL FAMILY MEMBERS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? familyJson = prefs.getString(_familyKey);

      if (familyJson == null || familyJson.isEmpty) {
        return [];
      }

      final dynamic decodedData = jsonDecode(familyJson);

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
  // ADD FAMILY MEMBER
  // =====================================================

  static Future<bool> addFamilyMember({
    required String name,
    required String age,
    required String gender,
    required String bloodGroup,
    required String city,
    String relation = 'Family Member',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final members = await getFamilyMembers();

      final newMember = <String, dynamic>{
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'name': name.trim(),
        'age': age.trim(),
        'gender': gender.trim(),
        'bloodGroup': bloodGroup.trim(),
        'city': city.trim(),
        'relation': relation.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
      };

      members.add(newMember);

      return await prefs.setString(
        _familyKey,
        jsonEncode(members),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // UPDATE FAMILY MEMBER
  // =====================================================

  static Future<bool> updateFamilyMember({
    required String id,
    required String name,
    required String age,
    required String gender,
    required String bloodGroup,
    required String city,
    required String relation,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final members = await getFamilyMembers();

      final index = members.indexWhere(
        (member) => member['id']?.toString() == id,
      );

      if (index == -1) {
        return false;
      }

      members[index] = {
        ...members[index],
        'name': name.trim(),
        'age': age.trim(),
        'gender': gender.trim(),
        'bloodGroup': bloodGroup.trim(),
        'city': city.trim(),
        'relation': relation.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      return await prefs.setString(
        _familyKey,
        jsonEncode(members),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // DELETE FAMILY MEMBER
  // =====================================================

  static Future<bool> deleteFamilyMember(
    String memberId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final members = await getFamilyMembers();

      final originalLength = members.length;

      members.removeWhere(
        (member) => member['id']?.toString() == memberId,
      );

      if (members.length == originalLength) {
        return false;
      }

      return await prefs.setString(
        _familyKey,
        jsonEncode(members),
      );
    } catch (e) {
      return false;
    }
  }

  // =====================================================
  // GET FAMILY MEMBER BY ID
  // =====================================================

  static Future<Map<String, dynamic>?> getFamilyMemberById(
    String memberId,
  ) async {
    try {
      final members = await getFamilyMembers();

      final index = members.indexWhere(
        (member) => member['id']?.toString() == memberId,
      );

      if (index == -1) {
        return null;
      }

      return members[index];
    } catch (e) {
      return null;
    }
  }

  // =====================================================
  // TOTAL FAMILY MEMBER COUNT
  // =====================================================

  static Future<int> getFamilyMemberCount() async {
    try {
      final members = await getFamilyMembers();
      return members.length;
    } catch (e) {
      return 0;
    }
  }

  // =====================================================
  // CLEAR ALL FAMILY MEMBERS
  // =====================================================

  static Future<bool> clearAllFamilyMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_familyKey);
    } catch (e) {
      return false;
    }
  }
}