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
  static const String _isGuestKey = 'is_guest';

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

    // User is registered
    await prefs.setBool(_isRegisteredKey, true);

    // User is not a guest
    await prefs.setBool(_isGuestKey, false);

    // Start session
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
  // CHECK LOGIN STATUS
  // =====================================================

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // =====================================================
  // CHECK GUEST STATUS
  // =====================================================

  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_isGuestKey) ?? false;
  }

  // =====================================================
  // LOGIN EXISTING REGISTERED USER
  // =====================================================

  static Future<void> loginUser() async {
    final prefs = await SharedPreferences.getInstance();

    final bool isRegistered =
        prefs.getBool(_isRegisteredKey) ?? false;

    if (isRegistered) {
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setBool(_isGuestKey, false);
    }
  }

  // =====================================================
  // EMERGENCY GUEST LOGIN
  // =====================================================

  static Future<void> loginAsGuest() async {
    final prefs = await SharedPreferences.getInstance();

    // Guest does NOT have a registered profile
    await prefs.setBool(_isRegisteredKey, false);

    // Guest session is active
    await prefs.setBool(_isLoggedInKey, true);

    // Mark as guest
    await prefs.setBool(_isGuestKey, true);
  }

  // =====================================================
  // SET LOGIN STATUS
  // =====================================================

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, value);

    if (!value) {
      await prefs.setBool(_isGuestKey, false);
    }
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
    await prefs.setBool(_isGuestKey, false);
  }

  // =====================================================
  // LOGOUT
  // =====================================================
  //
  // Profile remains saved for registered users.
  // Guest session is also cleared.
  // =====================================================

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setBool(_isGuestKey, false);
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
    await prefs.remove(_isGuestKey);
  }
}