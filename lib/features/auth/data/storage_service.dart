import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _fullNameKey = 'full_name';
  static const _emailKey = 'email';
  static const _languageKey = 'language_code';
  static const _scanLocalModelKey = 'scan.local.selected_model';

  static Future<void> saveAuth({
    required String token,
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  static Future<void> saveUserProfile({
    String? userName,
    String? fullName,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (userName != null) {
      await prefs.setString(_userNameKey, userName);
    }
    if (fullName != null) {
      await prefs.setString(_fullNameKey, fullName);
    }
    if (email != null) {
      await prefs.setString(_emailKey, email);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullNameKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_emailKey);
  }

  static Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }

  static Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<void> setScanLocalModel(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_scanLocalModelKey, modelId);
  }

  static Future<String?> getScanLocalModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scanLocalModelKey);
  }
}
