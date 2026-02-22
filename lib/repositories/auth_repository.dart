import '../models/user.dart';
import '../repositories/local_storage.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final LocalStorage storage;
  final AuthService service;

  AuthRepository({required this.storage, required this.service});

  Future<bool> get isAuthenticated async {
    return (storage.getToken() ?? '').isNotEmpty;
  }

  String? get token => storage.getToken();

  AppUser? get user => storage.getUser();

  Future<void> saveToken(String? token) async {
    await storage.setToken(token);
  }

  Future<void> saveUser(AppUser? user) async {
    await storage.setUser(user);
  }

  Future<void> clearAuth() async {
    await storage.setToken(null);
    await storage.setUser(null);
  }

  Future<void> login(String email, String password) async {
    final t = await service.login(email: email, password: password);
    await saveToken(t);
    final profile = await service.getProfile();
    await saveUser(profile);
  }

  Future<void> registerAndLogin({
    required String name,
    required String email,
    required String password,
  }) async {
    await service.register(name: name, email: email, password: password);
    await login(email, password);
  }
}
