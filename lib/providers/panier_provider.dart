import 'package:flutter/material.dart';

import '../models/article.dart';
import '../models/cart_item.dart';
import '../services/supabase_service.dart';

class PanierProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CartItem> items = [];
  bool isLoading = false;
  String errorMessage = '';

  int get count => items.length;

  double get total {
    double somme = 0;

    for (final item in items) {
      somme += item.total;
    }

    return somme;
  }

  Future<void> loadPanier() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      items = await _supabaseService.getPanier();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addArticle(Article article) async {
    errorMessage = '';

    try {
      await _supabaseService.addToPanier(article);
      await loadPanier();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> removeItem(dynamic cartItemId) async {
    await _supabaseService.removeFromPanier(cartItemId.toString());
    await loadPanier();
  }

  Future<void> clearPanier() async {
    await _supabaseService.clearPanier();
    items.clear();
    notifyListeners();
  }

  // Méthodes en français si certains écrans les utilisent plus tard
  Future<void> chargerPanier() async {
    await loadPanier();
  }

  Future<void> viderPanier() async {
    await clearPanier();
  }
}