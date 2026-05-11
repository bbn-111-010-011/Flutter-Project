import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String favorisKey = 'favoris_ids';
  static const String hideHomeKey = 'hide_home_screen';

  Future<List<String>> getFavorisIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(favorisKey) ?? [];
  }

  Future<void> saveFavorisIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(favorisKey, ids);
  }

  Future<bool> getHideHomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hideHomeKey) ?? false;
  }

  Future<void> saveHideHomeScreen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hideHomeKey, value);
  }
}
