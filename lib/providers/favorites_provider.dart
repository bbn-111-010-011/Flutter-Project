import 'package:flutter/foundation.dart';
import '../repositories/local_storage.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._storage) {
    _favorites = _storage.loadFavorites();
  }

  final LocalStorage _storage;
  List<int> _favorites = [];

  List<int> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(int productId) => _favorites.contains(productId);

  Future<void> toggle(int productId) async {
    if (_favorites.contains(productId)) {
      _favorites.remove(productId);
    } else {
      _favorites.add(productId);
    }
    await _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> remove(int productId) async {
    _favorites.remove(productId);
    await _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> clear() async {
    _favorites = [];
    await _storage.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> hydrate() async {
    _favorites = _storage.loadFavorites();
    notifyListeners();
  }
}
