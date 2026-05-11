import 'package:flutter/material.dart';

import '../models/achat.dart';
import '../models/cart_item.dart';
import '../services/supabase_service.dart';

class AchatProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Achat> achats = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> loadAchats() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      achats = await _supabaseService.getAchats();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> validerAchat(double total, List<CartItem> items) async {
    errorMessage = '';

    try {
      await _supabaseService.createAchat(total, items);
      await loadAchats();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
