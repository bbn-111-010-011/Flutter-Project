import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class LocalStorage {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) {
      throw StateError('LocalStorage not initialized. Call init() first.');
    }
    return p;
  }

  // Onboarding
  Future<void> setOnboardingSeen(bool seen) async {
    await _p.setBool(Constants.spOnboardingSeen, seen);
  }

  bool getOnboardingSeen() {
    return _p.getBool(Constants.spOnboardingSeen) ?? false;
  }

  // Auth token
  Future<void> setToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _p.remove(Constants.spToken);
    } else {
      await _p.setString(Constants.spToken, token);
    }
  }

  String? getToken() {
    return _p.getString(Constants.spToken);
  }

  // User profile
  Future<void> setUser(AppUser? user) async {
    if (user == null) {
      await _p.remove(Constants.spUser);
    } else {
      await _p.setString(Constants.spUser, jsonEncode(user.toJson()));
    }
  }

  AppUser? getUser() {
    final s = _p.getString(Constants.spUser);
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return AppUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // Favorites (global, not per-user)
  Future<void> saveFavorites(List<int> favorites) async {
    await _p.setString(Constants.spFavorites, jsonEncode(favorites));
  }

  List<int> loadFavorites() {
    final s = _p.getString(Constants.spFavorites);
    if (s == null) return const [];
    try {
      final list = (jsonDecode(s) as List).map((e) => (e as num).toInt()).toList();
      return list;
    } catch (_) {
      return const [];
    }
  }

  // Cart (per user)
  String _cartKey(int userId) => '${Constants.spCart}_$userId';

  Future<void> saveCart(int userId, List<CartItem> items) async {
    final key = _cartKey(userId);
    final data = items.map((e) => e.toJson()).toList();
    await _p.setString(key, jsonEncode(data));
  }

  List<CartItem> loadCart(int userId) {
    final key = _cartKey(userId);
    final s = _p.getString(key);
    if (s == null) return const [];
    try {
      final list = (jsonDecode(s) as List)
          .whereType<Map<String, dynamic>>()
          .map(CartItem.fromJson)
          .toList();
      return list;
    } catch (_) {
      return const [];
    }
  }

  // Orders (per user)
  String _ordersKey(int userId) => '${Constants.spOrders}_$userId';

  Future<void> saveOrders(int userId, List<Order> orders) async {
    final key = _ordersKey(userId);
    final data = orders.map((e) => e.toJson()).toList();
    await _p.setString(key, jsonEncode(data));
  }

  List<Order> loadOrders(int userId) {
    final key = _ordersKey(userId);
    final s = _p.getString(key);
    if (s == null) return const [];
    try {
      final list = (jsonDecode(s) as List)
          .whereType<Map<String, dynamic>>()
          .map(Order.fromJson)
          .toList();
      return list;
    } catch (_) {
      return const [];
    }
  }
}
