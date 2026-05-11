import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class OnboardingProvider extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();

  bool hideHomeScreen = false;

  OnboardingProvider() {
    loadPreference();
  }

  Future<void> loadPreference() async {
    hideHomeScreen = await _preferencesService.getHideHomeScreen();
    notifyListeners();
  }

  Future<void> setHideHomeScreen(bool value) async {
    hideHomeScreen = value;
    await _preferencesService.saveHideHomeScreen(value);
    notifyListeners();
  }
}
