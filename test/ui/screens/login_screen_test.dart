import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/auth/login_screen.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/models/user.dart';

// A lightweight fake AuthProvider for widget testing
class TestAuthProvider extends ChangeNotifier implements AuthProvider {
  bool shouldFail = false;

  @override
  bool get loading => false;

  @override
  AppUser? get user => null;

  @override
  String? get token => null;

  @override
  bool get isAuthenticated => false;

  @override
  String? get error => null;

  @override
  Future<void> hydrate() async {}

  @override
  Future<void> login(String email, String password) async {
    if (shouldFail) {
      throw Exception('invalid credentials');
    }
    // success noop
  }

  @override
  Future<void> register(String name, String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> tokenProvider() async => null;
}

void main() {
  group('LoginScreen', () {
    Widget buildApp(AuthProvider auth) {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Home Page'))),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
        ],
      );

      return ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('shows validation errors on empty submit', (tester) async {
      final auth = TestAuthProvider();
      await tester.pumpWidget(buildApp(auth));

      expect(find.text('Connexion'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pump();

      expect(find.text('Email requis'), findsOneWidget);
      expect(find.text('Mot de passe requis'), findsOneWidget);
    });

    testWidgets('login error shows snackbar', (tester) async {
      final auth = TestAuthProvider()..shouldFail = true;
      await tester.pumpWidget(buildApp(auth));

      // Fill valid fields
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user@mail.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), '123456');

      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Erreur:'), findsOneWidget);
    });

    testWidgets('successful login navigates to /home', (tester) async {
      final auth = TestAuthProvider();
      await tester.pumpWidget(buildApp(auth));

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user@mail.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), '123456');

      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
