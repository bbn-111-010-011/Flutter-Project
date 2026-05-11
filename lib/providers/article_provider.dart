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

  List<Article> get allArticles => [...supabaseArticles, ...apiArticles];

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

    try {
      apiArticles = await _apiService.getArticles();
      supabaseArticles = await _supabaseService.getArticlesProposes();
      categories = await _apiService.getCategories();
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
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
