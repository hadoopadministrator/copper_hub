import 'package:copper_hub/services/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyUserId = 'userId';
  static const _keyName = 'name';
  static const _keyEmail = 'email';
  static const _keyMobile = 'mobile';

  
  static const _keyRememberMe = 'rememberMe';
  static const _keyRememberUser = 'rememberUser';


  /// SAVE REMEMBER ME
  static Future<void> saveRememberMe({
    required bool remember,
    required String emailOrMobile,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_keyRememberMe, remember);

    if (remember) {
      await prefs.setString(_keyRememberUser, emailOrMobile);
      await SecureStorage.savePassword(password);
    } else {
      await prefs.remove(_keyRememberUser);
      await SecureStorage.deletePassword();
    }
  }

  /// GET REMEMBER ME STATUS
  static Future<bool> isRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }
  
  /// GET REMEMBER USER (EMAIL / MOBILE)
  static Future<String?> getRememberUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberUser);
  }

  /// GET SAVED PASSWORD FROM SECURE STORAGE
  static Future<String?> getRememberPassword() async {
    return await SecureStorage.getPassword();
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
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyMobile);
  }

  static Future<void> clearAllLocalData() async {
  final prefs = await SharedPreferences.getInstance();

  // Login/session data
  await prefs.remove(_keyIsLoggedIn);
  await prefs.remove(_keyUserId);
  await prefs.remove(_keyName);
  await prefs.remove(_keyEmail);
  await prefs.remove(_keyMobile);

  // Remember me data
  await prefs.remove(_keyRememberMe);
  await prefs.remove(_keyRememberUser);

  // Secure storage (password)
  await SecureStorage.deletePassword();
}

}
