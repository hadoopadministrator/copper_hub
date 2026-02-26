import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyUserId = 'userId';
  static const _keyName = 'name';
  static const _keyEmail = 'email';
  static const _keyMobile = 'mobile';
  static const _keyRememberMe = 'rememberMe';
  static const _keyRememberPassword = 'rememberPassword';

  /// SAVE REMEMBER ME
  static Future<void> saveRememberMe({
    required bool remember,
    required String emailOrMobile,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyRememberMe, remember);

    if (remember) {
      await prefs.setString(_keyEmail, emailOrMobile);
      await prefs.setString(_keyRememberPassword, password);
    } else {
      await prefs.remove(_keyRememberPassword);
    }
  }

  /// GET REMEMBER ME STATUS
  static Future<bool> isRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// GET SAVED PASSWORD
  static Future<String?> getRememberPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberPassword);
  }

  static Future<void> saveLoginData({
    required int userId,
    required String name,
    required String email,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyMobile, mobile);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  static Future<String?> getMobile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMobile);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName);
  }

  /// NEW LOGOUT METHOD (IMPORTANT)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyName);
    await prefs.remove(_keyMobile);

  }
}
