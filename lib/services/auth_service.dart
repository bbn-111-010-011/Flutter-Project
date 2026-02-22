import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient api;

  AuthService(this.api);

  // POST /auth/login -> { access_token, refresh_token? }
  Future<String> login({required String email, required String password}) async {
    final data = await api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    final token = data['access_token']?.toString();
    if (token == null || token.isEmpty) {
      throw Exception('Token manquant dans la réponse de login');
    }
    return token;
  }

  // GET /auth/profile -> user
  Future<AppUser> getProfile() async {
    final data = await api.get('/auth/profile', auth: true);
    return AppUser.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // POST /users -> user
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? avatar,
    String role = 'customer',
  }) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar ??
          'https://api.dicebear.com/7.x/identicon/svg?seed=${Uri.encodeComponent(email)}',
      'role': role,
    };
    final data = await api.post('/users', body: body);
    return AppUser.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
