import 'package:shared_preferences/shared_preferences.dart';

class SettingsStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _themeKey = 'theme';
  static const String _bigIconsKey = 'big_icons';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<void> saveBigIcons(bool state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bigIconsKey, state);
  }

  static Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
  static Future<bool?> loadBigIcons() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bigIconsKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }
}
