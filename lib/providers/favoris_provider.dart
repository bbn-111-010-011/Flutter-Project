import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class FavorisProvider extends ChangeNotifier {
  final PreferencesService _preferencesService = PreferencesService();

  List<String> favorisIds = [];

  FavorisProvider() {
    loadFavoris();
  }

  Future<void> loadFavoris() async {
    favorisIds = await _preferencesService.getFavorisIds();
    notifyListeners();
  }

  bool isFavori(String articleId) {
    return favorisIds.contains(articleId);
  }

  Future<void> toggleFavori(String articleId) async {
    if (favorisIds.contains(articleId)) {
      favorisIds.remove(articleId);
    } else {
      favorisIds.add(articleId);
    }

    await _preferencesService.saveFavorisIds(favorisIds);
    notifyListeners();
  }
}
