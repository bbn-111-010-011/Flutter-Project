import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool isLoading = false;
  String errorMessage = '';

  bool get isLoggedIn => _supabaseService.currentUser != null;
  String get userEmail => _supabaseService.currentUser?.email ?? '';
  bool get supabaseReady => SupabaseService.isConfigured;

  Future<bool> register(String email, String password) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _supabaseService.signUp(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await _supabaseService.signIn(email, password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _supabaseService.signOut();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}
