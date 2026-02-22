import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/services/auth_service.dart';
import 'package:flutter_projet/services/api_client.dart';
import 'package:flutter_projet/models/user.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('AuthService', () {
    late MockApiClient api;
    late AuthService service;

    setUp(() {
      api = MockApiClient();
      service = AuthService(api);
    });

    test('login returns access token', () async {
      when(() => api.post('/auth/login', body: any(named: 'body')))
          .thenAnswer((_) async => {'access_token': 'token123'});

      final token = await service.login(email: 'a@b.c', password: 'x');
      expect(token, 'token123');

      final captured = verify(() => api.post('/auth/login', body: captureAny(named: 'body'))).captured.single
          as Map<String, dynamic>;
      expect(captured['email'], 'a@b.c');
      expect(captured['password'], 'x');
    });

    test('getProfile maps to AppUser', () async {
      when(() => api.get('/auth/profile', auth: true)).thenAnswer(
        (_) async => {
          'id': 1,
          'name': 'John',
          'email': 'john@mail.com',
          'avatar': 'http://img',
          'role': 'customer',
        },
      );

      final user = await service.getProfile();
      expect(user, isA<AppUser>());
      expect(user.email, 'john@mail.com');
    });

    test('register returns user', () async {
      when(() => api.post('/users', body: any(named: 'body'))).thenAnswer(
        (_) async => {
          'id': 5,
          'name': 'Jane',
          'email': 'jane@mail.com',
          'avatar': 'http://a',
          'role': 'customer',
        },
      );

      final u = await service.register(name: 'Jane', email: 'jane@mail.com', password: 'xx');
      expect(u.name, 'Jane');
      expect(u.email, 'jane@mail.com');
    });
  });
}
