import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final ApiClient _api;

  AuthProvider(this._repo, this._api);

  AppUser? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => (_token ?? '').isNotEmpty;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> hydrate() async {
    _user = _repo.user;
    _token = _repo.token;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _repo.login(email, password);
      _user = _repo.user;
      _token = _repo.token;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _repo.registerAndLogin(name: name, email: email, password: password);
      _user = _repo.user;
      _token = _repo.token;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _repo.clearAuth();
      _user = null;
      _token = null;
      _error = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Token provider for ApiClient
  Future<String?> tokenProvider() async => _repo.token;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
