import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class ArticleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SupabaseService _supabaseService = SupabaseService();

  List<Article> apiArticles = [];
  List<Article> supabaseArticles = [];
  List<String> categories = [];

  bool isLoading = false;
  String errorMessage = '';

  String searchText = '';
  String selectedCategory = 'Toutes';
  double? minPrice;
  double? maxPrice;

  // On affiche d'abord les articles de l'API Fake Platzi,
  // puis on ajoute les articles proposés depuis Supabase à la fin.
  List<Article> get allArticles => [...apiArticles, ...supabaseArticles];

  List<Article> get filteredArticles {
    return allArticles.where((article) {
      final matchSearch = article.title.toLowerCase().contains(searchText.toLowerCase());
      final matchCategory = selectedCategory == 'Toutes' || article.category == selectedCategory;
      final matchMinPrice = minPrice == null || article.price >= minPrice!;
      final matchMaxPrice = maxPrice == null || article.price <= maxPrice!;

      return matchSearch && matchCategory && matchMinPrice && matchMaxPrice;
    }).toList();
  }

  Future<void> loadArticles() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    // 1) Chargement prioritaire depuis l'API Fake Platzi.
    try {
      apiArticles = await _apiService.getArticles();
      categories = await _apiService.getCategories();
    } catch (e) {
      errorMessage = 'Erreur lors du chargement des articles API : $e';
      isLoading = false;
      notifyListeners();
      return;
    }

    // On affiche déjà les articles API, même si Supabase n'est pas prêt.
    isLoading = false;
    notifyListeners();

    // 2) Chargement secondaire depuis Supabase.
    // Si la table n'existe pas ou si Supabase a un souci, on ignore l'erreur.
    try {
      supabaseArticles = await _supabaseService.getArticlesProposes();
      notifyListeners();
    } catch (_) {
      supabaseArticles = [];
      notifyListeners();
    }
  }

  Article? findById(String id) {
    try {
      return allArticles.firstWhere((article) => article.id == id);
    } catch (_) {
      return null;
    }
  }

  void setSearchText(String value) {
    searchText = value;
    notifyListeners();
  }

  void setCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void setMinPrice(String value) {
    minPrice = double.tryParse(value);
    notifyListeners();
  }

  void setMaxPrice(String value) {
    maxPrice = double.tryParse(value);
    notifyListeners();
  }

  void clearFilters() {
    searchText = '';
    selectedCategory = 'Toutes';
    minPrice = null;
    maxPrice = null;
    notifyListeners();
  }
}
