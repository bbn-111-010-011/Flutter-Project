import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/profile/profile_screen.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/models/user.dart';

// Lightweight AuthProvider double for testing ProfileScreen
class TestAuthProvider extends ChangeNotifier implements AuthProvider {
  TestAuthProvider({bool authenticated = false})
      : _authenticated = authenticated;

  bool _authenticated;
  AppUser? _user;

  @override
  bool get loading => false;

  @override
  AppUser? get user => _authenticated
      ? (_user ??
          (_user = AppUser(
            id: 1,
            name: 'John Doe',
            email: 'john@mail.com',
            avatar: '',
            role: 'customer',
          )))
      : null;

  @override
  String? get token => _authenticated ? 'token' : null;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  String? get error => null;

  @override
  Future<void> hydrate() async {}

  @override
  Future<void> login(String email, String password) async {
    _authenticated = true;
    notifyListeners();
  }

  @override
  Future<void> register(String name, String email, String password) async {
    _authenticated = true;
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _authenticated = false;
    notifyListeners();
  }

  @override
  Future<String?> tokenProvider() async => token;
}

void main() {
  group('ProfileScreen', () {
    Widget buildApp(AuthProvider auth, {String initialLocation = '/profile'}) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Home Page'))),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Login Page'))),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Register Page'))),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Orders Page'))),
          ),
          GoRoute(
            path: '/new-product',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('New Product Page'))),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      );

      return ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('guest view shows login/register buttons', (tester) async {
      final auth = TestAuthProvider(authenticated: false);

      await tester.pumpWidget(buildApp(auth));
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsOneWidget);
      expect(find.textContaining('Vous n’êtes pas connecté'), findsOneWidget);

      // Buttons exist
      expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Créer un compte'), findsOneWidget);

      // Navigate to login
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('authenticated view shows user info and allows logout', (tester) async {
      final auth = TestAuthProvider(authenticated: true);

      await tester.pumpWidget(buildApp(auth));
      await tester.pumpAndSettle();

      // Shows profile data
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@mail.com'), findsOneWidget);

      // Navigate to orders
      await tester.tap(find.widgetWithText(ListTile, 'Historique des achats'));
      await tester.pumpAndSettle();
      expect(find.text('Orders Page'), findsOneWidget);

      // Back to profile
      await tester.pumpWidget(buildApp(auth));
      await tester.pumpAndSettle();

      // Logout
      await tester.tap(find.widgetWithText(ListTile, 'Se déconnecter'));
      await tester.pump(); // show snackbar
      await tester.pumpAndSettle();

      // Navigated home and snackbar appears earlier
      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
