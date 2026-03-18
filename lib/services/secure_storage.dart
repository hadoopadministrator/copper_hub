

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {

  static const _storage = FlutterSecureStorage();

  static const passwordKey = "rememberPassword";

  static Future<void> savePassword(String password) async {
    await _storage.write(key: passwordKey, value: password);
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: passwordKey);
  }

  static Future<void> deletePassword() async {
    await _storage.delete(key: passwordKey);
  }
}
