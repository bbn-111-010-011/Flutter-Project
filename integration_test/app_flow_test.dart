import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'package:flutter_projet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App flow (Chrome)', () {
    testWidgets('Onboarding -> Home -> Cart redirect to Login -> Register', (tester) async {
      // Launch the full app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Onboarding screen should show
      expect(find.textContaining('Bienvenue sur Marketplace'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);

      // Continue
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Home/Products screen AppBar title
      expect(find.text('Produits'), findsWidgets);

      // Tap BottomNavigationBar "Panier" (Cart)
      // Find by text label in bottom nav
      expect(find.text('Panier'), findsOneWidget);
      await tester.tap(find.text('Panier'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be redirected to Login
      expect(find.text('Connexion'), findsOneWidget);

      // Navigate to Register
      expect(find.text('Créer un compte'), findsOneWidget);
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Register screen AppBar
      expect(find.text('Créer un compte'), findsWidgets);
    });
  });
}
