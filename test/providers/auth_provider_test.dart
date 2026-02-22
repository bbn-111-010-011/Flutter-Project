import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/repositories/auth_repository.dart';
import 'package:flutter_projet/services/api_client.dart';
import 'package:flutter_projet/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('AuthProvider', () {
    late MockAuthRepository repo;
    late ApiClient apiClient;
    late AuthProvider provider;

    final user = AppUser(
      id: 1,
      name: 'John',
      email: 'john@mail.com',
      avatar: 'http://img',
      role: 'customer',
    );

    setUp(() {
      repo = MockAuthRepository();
      // ApiClient is not used directly by AuthProvider in these methods,
      // pass a trivial instance.
      apiClient = ApiClient(tokenProvider: () async => null);
      provider = AuthProvider(repo, apiClient);
    });

    test('hydrate reads user/token from repository', () async {
      when(() => repo.user).thenReturn(user);
      when(() => repo.token).thenReturn('tkn');

      await provider.hydrate();

      expect(provider.user?.email, 'john@mail.com');
      expect(provider.token, 'tkn');
      expect(provider.isAuthenticated, isTrue);
    });

    test('login success updates user/token and clears error', () async {
      // repo.login will set getters to return values used by provider
      when(() => repo.login(any(), any())).thenAnswer((_) async {
        when(() => repo.user).thenReturn(user);
        when(() => repo.token).thenReturn('abc');
      });

      expect(provider.loading, isFalse);
      await provider.login('john@mail.com', 'x');
      expect(provider.loading, isFalse);

      expect(provider.user?.name, 'John');
      expect(provider.token, 'abc');
      expect(provider.error, isNull);
      expect(provider.isAuthenticated, isTrue);
    });

    test('login failure sets error and rethrows', () async {
      when(() => repo.login(any(), any()))
          .thenThrow(Exception('invalid credentials'));
      expect(() => provider.login('x@y.z', 'bad'),
          throwsA(isA<Exception>()));
      expect(provider.error, contains('invalid'));
      expect(provider.isAuthenticated, isFalse);
    });

    test('register success updates user/token', () async {
      when(() => repo.registerAndLogin(
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
        when(() => repo.user).thenReturn(user);
        when(() => repo.token).thenReturn('regtok');
      });

      await provider.register('John', 'john@mail.com', 'pw');
      expect(provider.user?.email, 'john@mail.com');
      expect(provider.token, 'regtok');
      expect(provider.error, isNull);
    });

    test('logout clears user/token', () async {
      when(() => repo.clearAuth()).thenAnswer((_) async {});

      // Pretend authenticated before logout
      when(() => repo.user).thenReturn(user);
      when(() => repo.token).thenReturn('abc');
      await provider.hydrate();
      expect(provider.isAuthenticated, isTrue);

      await provider.logout();
      expect(provider.user, isNull);
      expect(provider.token, isNull);
      expect(provider.isAuthenticated, isFalse);
    });
  });
}
