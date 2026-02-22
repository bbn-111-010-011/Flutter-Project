import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/auth/register_screen.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/models/user.dart';

// Minimal fake AuthProvider for register flow
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
    throw UnimplementedError();
  }

  @override
  Future<void> register(String name, String email, String password) async {
    if (shouldFail) {
      throw Exception('register failed');
    }
    // otherwise success
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String?> tokenProvider() async => null;
}

void main() {
  group('RegisterScreen', () {
    Widget buildApp(AuthProvider auth) {
      final router = GoRouter(
        initialLocation: '/register',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Home Page'))),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
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

      expect(find.text('Créer un compte'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Créer le compte'));
      await tester.pump();

      expect(find.text('Nom requis'), findsOneWidget);
      expect(find.text('Email requis'), findsOneWidget);
      expect(find.text('Mot de passe requis'), findsOneWidget);
    });

    testWidgets('invalid email shows validation error', (tester) async {
      final auth = TestAuthProvider();
      await tester.pumpWidget(buildApp(auth));

      await tester.enterText(find.widgetWithText(TextFormField, 'Nom'), 'User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), '123456');

      await tester.tap(find.widgetWithText(FilledButton, 'Créer le compte'));
      await tester.pump();

      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('register error shows snackbar', (tester) async {
      final auth = TestAuthProvider()..shouldFail = true;
      await tester.pumpWidget(buildApp(auth));

      await tester.enterText(find.widgetWithText(TextFormField, 'Nom'), 'User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user@mail.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), '123456');

      await tester.tap(find.widgetWithText(FilledButton, 'Créer le compte'));
      await tester.pump(); // start async
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Erreur:'), findsOneWidget);
    });

    testWidgets('successful register navigates to /home', (tester) async {
      final auth = TestAuthProvider();
      await tester.pumpWidget(buildApp(auth));

      await tester.enterText(find.widgetWithText(TextFormField, 'Nom'), 'User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user@mail.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mot de passe'), '123456');

      await tester.tap(find.widgetWithText(FilledButton, 'Créer le compte'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
