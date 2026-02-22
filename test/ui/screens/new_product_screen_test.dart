import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/product_form/new_product_screen.dart';
import 'package:flutter_projet/providers/product_provider.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/services/product_service.dart';
import 'package:flutter_projet/models/category.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/models/user.dart';

// Mocks
class MockProductService extends Mock implements ProductService {}

// Auth test double
class TestAuthProvider extends ChangeNotifier implements AuthProvider {
  TestAuthProvider({bool authenticated = false}) : _authenticated = authenticated;
  bool _authenticated;

  @override
  bool get loading => false;

  @override
  AppUser? get user => _authenticated
      ? AppUser(
          id: 1,
          name: 'User',
          email: 'user@mail.com',
          avatar: '',
          role: 'customer',
        )
      : null;

  @override
  String? get token => _authenticated ? 't' : null;

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
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('NewProductScreen', () {
    late MockProductService service;
    late ProductProvider products;

    setUp(() {
      service = MockProductService();
      products = ProductProvider(service);
    });

    Widget buildApp(AuthProvider auth) {
      final router = GoRouter(
        initialLocation: '/new-product',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Login Page'))),
          ),
          GoRoute(
            path: '/new-product',
            builder: (context, state) => const NewProductScreen(),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: Text('Produit #${state.pathParameters['id']}')),
              body: const Center(child: Text('Detail Product Page')),
            ),
          ),
        ],
      );

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ProductProvider>.value(value: products),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('unauthenticated submit shows snackbar and redirects to /login', (tester) async {
      // Categories fetched (dropdown renders)
      when(() => service.fetchCategories()).thenAnswer((_) async => [Category(id: 1, name: 'Cat1', image: '')]);

      final auth = TestAuthProvider(authenticated: false);
      await tester.pumpWidget(buildApp(auth));

      await tester.pumpAndSettle();

      // Directly submit without filling → auth gate triggers first
      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pump(); // show snackbar

      expect(find.text('Vous devez être connecté'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('client-side validators show on empty submit', (tester) async {
      when(() => service.fetchCategories()).thenAnswer((_) async => [Category(id: 1, name: 'Cat1', image: '')]);

      final auth = TestAuthProvider(authenticated: true);
      await tester.pumpWidget(buildApp(auth));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pump();

      expect(find.text('Titre requis'), findsOneWidget);
      expect(find.text('Description requise'), findsOneWidget);
      expect(find.text('Prix requis'), findsOneWidget);
      expect(find.text('Catégorie requise'), findsOneWidget);
      expect(find.text('Au moins une image'), findsOneWidget);
    });

    testWidgets('successful creation navigates to product detail with success snackbar', (tester) async {
      when(() => service.fetchCategories()).thenAnswer((_) async => [Category(id: 1, name: 'Cat1', image: '')]);

      // When creating product via provider/service
      when(() => service.createProduct(
            title: any(named: 'title'),
            description: any(named: 'description'),
            price: any(named: 'price'),
            categoryId: any(named: 'categoryId'),
            images: any(named: 'images'),
          )).thenAnswer((_) async => Product(
                id: 123,
                title: 'Nouveau',
                price: 9.99,
                description: 'Desc',
                images: const ['https://a'],
                category: Category(id: 1, name: 'Cat1', image: ''),
              ));

      final auth = TestAuthProvider(authenticated: true);
      await tester.pumpWidget(buildApp(auth));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.widgetWithText(TextFormField, 'Titre'), 'Nouveau');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Belle description');
      await tester.enterText(find.widgetWithText(TextFormField, 'Prix (€)'), '19.90');

      // Select category
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cat1').last);
      await tester.pump();

      // Images: comma or newline separated supported
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Images (URLs, séparées par virgule ou nouvelle ligne)'),
        'https://a, https://b',
      );

      // Submit
      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pump(); // show snackbar
      expect(find.text('Produit créé'), findsOneWidget);

      await tester.pumpAndSettle();

      // Navigated to detail page for id 123
      expect(find.text('Produit #123'), findsOneWidget);
      expect(find.text('Detail Product Page'), findsOneWidget);
    });

    testWidgets('service error shows error snackbar', (tester) async {
      when(() => service.fetchCategories()).thenAnswer((_) async => [Category(id: 1, name: 'Cat1', image: '')]);
      when(() => service.createProduct(
            title: any(named: 'title'),
            description: any(named: 'description'),
            price: any(named: 'price'),
            categoryId: any(named: 'categoryId'),
            images: any(named: 'images'),
          )).thenThrow(Exception('backend down'));

      final auth = TestAuthProvider(authenticated: true);
      await tester.pumpWidget(buildApp(auth));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Titre'), 'Nouveau');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'Belle description');
      await tester.enterText(find.widgetWithText(TextFormField, 'Prix (€)'), '19.90');

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cat1').last);
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Images (URLs, séparées par virgule ou nouvelle ligne)'),
        'https://a',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
      await tester.pump();

      expect(find.textContaining('Erreur:'), findsOneWidget);
    });
  });
}
