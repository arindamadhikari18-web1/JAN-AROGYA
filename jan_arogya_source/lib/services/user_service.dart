import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // =====================================================
  // USER PROFILE KEYS
  // =====================================================

  static const String _nameKey = 'user_name';
  static const String _ageKey = 'user_age';
  static const String _genderKey = 'user_gender';
  static const String _cityKey = 'user_city';
  static const String _bloodGroupKey = 'blood_group';
  static const String _emergencyContactKey = 'emergency_contact';

  // =====================================================
  // APP SESSION KEYS
  // =====================================================

  static const String _isRegisteredKey = 'is_registered';
  static const String _isLoggedInKey = 'is_logged_in';

  // =====================================================
  // SAVE NEW USER + CREATE SESSION
  // =====================================================

  static Future<void> saveUser({
    required String userName,
    required String userAge,
    required String userGender,
    required String userCity,
    required String bloodGroup,
    required String emergencyContact,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, userName);
    await prefs.setString(_ageKey, userAge);
    await prefs.setString(_genderKey, userGender);
    await prefs.setString(_cityKey, userCity);
    await prefs.setString(_bloodGroupKey, bloodGroup);
    await prefs.setString(
      _emergencyContactKey,
      emergencyContact,
    );

    // User successfully registered
    await prefs.setBool(_isRegisteredKey, true);

    // Session starts automatically
    await prefs.setBool(_isLoggedInKey, true);
  }

  // =====================================================
  // GET SAVED USER DATA
  // =====================================================

  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isRegistered =
        prefs.getBool(_isRegisteredKey) ?? false;

    if (!isRegistered) {
      return null;
    }

    return {
      'userName': prefs.getString(_nameKey) ?? '',
      'userAge': prefs.getString(_ageKey) ?? '',
      'userGender': prefs.getString(_genderKey) ?? '',
      'userCity': prefs.getString(_cityKey) ?? '',
      'bloodGroup': prefs.getString(_bloodGroupKey) ?? '',
      'emergencyContact':
          prefs.getString(_emergencyContactKey) ?? '',
    };
  }

  // =====================================================
  // CHECK REGISTRATION STATUS
  // =====================================================

  static Future<bool> isUserRegistered() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_isRegisteredKey) ?? false;
  }

  // =====================================================
  // CHECK SESSION / LOGIN STATUS
  // =====================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // =====================================================
  // START SESSION AFTER LOGIN
  // =====================================================

  static Future<void> loginUser() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isRegistered =
        prefs.getBool(_isRegisteredKey) ?? false;

    if (isRegistered) {
      await prefs.setBool(_isLoggedInKey, true);
    }
  }

  // =====================================================
  // SET LOGIN STATUS
  // =====================================================

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, value);
  }

  // =====================================================
  // UPDATE USER PROFILE
  // =====================================================

  static Future<void> updateUser({
    required String userName,
    required String userAge,
    required String userGender,
    required String userCity,
    required String bloodGroup,
    required String emergencyContact,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, userName);
    await prefs.setString(_ageKey, userAge);
    await prefs.setString(_genderKey, userGender);
    await prefs.setString(_cityKey, userCity);
    await prefs.setString(_bloodGroupKey, bloodGroup);
    await prefs.setString(
      _emergencyContactKey,
      emergencyContact,
    );

    await prefs.setBool(_isRegisteredKey, true);
  }

  // =====================================================
  // LOGOUT - ONLY CLEAR SESSION
  // =====================================================

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();

    // Profile remains saved
    // Only session is cleared
    await prefs.setBool(_isLoggedInKey, false);
  }

  // =====================================================
  // DELETE COMPLETE ACCOUNT
  // =====================================================

  static Future<void> deleteUserAccount() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_nameKey);
    await prefs.remove(_ageKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_cityKey);
    await prefs.remove(_bloodGroupKey);
    await prefs.remove(_emergencyContactKey);

    await prefs.remove(_isRegisteredKey);
    await prefs.remove(_isLoggedInKey);
  }
}