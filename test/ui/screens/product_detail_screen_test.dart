import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/products/product_detail_screen.dart';
import 'package:flutter_projet/providers/product_provider.dart';
import 'package:flutter_projet/providers/favorites_provider.dart';
import 'package:flutter_projet/providers/cart_provider.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/services/product_service.dart';
import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/models/category.dart';
import 'package:flutter_projet/models/user.dart';

// Mocks
class MockProductService extends Mock implements ProductService {}
class MockLocalStorage extends Mock implements LocalStorage {}

// Lightweight AuthProvider test double
class TestAuthProvider extends ChangeNotifier implements AuthProvider {
  TestAuthProvider({this.authenticated = false, this.userId});
  bool authenticated;
  int? userId;

  @override
  bool get loading => false;

  @override
  AppUser? get user => authenticated
      ? AppUser(
          id: userId ?? 1,
          name: 'User',
          email: 'user@mail.com',
          avatar: '',
          role: 'customer',
        )
      : null;

  @override
  String? get token => authenticated ? 't' : null;

  @override
  bool get isAuthenticated => authenticated;

  @override
  String? get error => null;

  @override
  Future<void> hydrate() async {}

  @override
  Future<void> login(String email, String password) async {
    authenticated = true;
    notifyListeners();
  }

  @override
  Future<void> register(String name, String email, String password) async {
    authenticated = true;
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    authenticated = false;
    notifyListeners();
  }

  @override
  Future<String?> tokenProvider() async => token;
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  Product sampleProduct() => Product(
        id: 1,
        title: 'Produit X',
        price: 42.0,
        description: 'Description du produit X',
        images: const ['https://picsum.photos/400'],
        category: Category(id: 5, name: 'Cat 5', image: ''),
      );

  group('ProductDetailScreen', () {
    testWidgets('renders product details and toggles favorite', (tester) async {
      // Arrange
      final mockService = MockProductService();
      when(() => mockService.fetchProduct(1)).thenAnswer((_) async => sampleProduct());

      final productProvider = ProductProvider(mockService);

      final storage = MockLocalStorage();
      when(() => storage.loadFavorites()).thenReturn(<int>[]);
      when(() => storage.saveFavorites(any())).thenAnswer((_) async {});

      final favorites = FavoritesProvider(storage);

      final auth = TestAuthProvider(authenticated: true, userId: 10);

      when(() => storage.loadCart(any())).thenReturn(const []);
      when(() => storage.saveCart(any(), any())).thenAnswer((_) async {});
      final cart = CartProvider(storage, auth);
      await cart.hydrate();

      final router = GoRouter(
        initialLocation: '/product/1',
        routes: [
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => ProductDetailScreen(
              productId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: productProvider),
            ChangeNotifierProvider.value(value: favorites),
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider.value(value: cart),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      // First frame (shows loader), then resolve product
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert details
      expect(find.text('Produit X'), findsWidgets);
      expect(find.text('42.00 €'), findsOneWidget);
      expect(find.text('Description du produit X'), findsOneWidget);
      expect(find.text('Cat 5'), findsOneWidget);

      // Favorite toggle
      final favBtn = find.byIcon(Icons.favorite_border);
      expect(favBtn, findsOneWidget);
      await tester.tap(favBtn);
      await tester.pump();
      expect(favorites.isFavorite(1), isTrue);
    });

    testWidgets('unauthenticated add-to-cart shows snackbar and redirects to /login', (tester) async {
      // Arrange
      final mockService = MockProductService();
      when(() => mockService.fetchProduct(1)).thenAnswer((_) async => sampleProduct());
      final productProvider = ProductProvider(mockService);

      final storage = MockLocalStorage();
      when(() => storage.loadFavorites()).thenReturn(<int>[]);
      when(() => storage.saveFavorites(any())).thenAnswer((_) async {});
      when(() => storage.loadCart(any())).thenReturn(const []);
      when(() => storage.saveCart(any(), any())).thenAnswer((_) async {});

      final favorites = FavoritesProvider(storage);

      final auth = TestAuthProvider(authenticated: false);

      // Even if provided, CartProvider will not be used due to auth guard
      final cart = CartProvider(storage, auth);
      await cart.hydrate();

      final router = GoRouter(
        initialLocation: '/product/1',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Center(child: Text('Login Page'))),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => ProductDetailScreen(
              productId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: productProvider),
            ChangeNotifierProvider.value(value: favorites),
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider.value(value: cart),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Tap add to cart
      final addBtn = find.widgetWithText(FilledButton, 'Ajouter au panier');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pump(); // show snackbar

      // Snackbar and redirect
      expect(find.textContaining('Connectez-vous'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);
    });

    testWidgets('authenticated add-to-cart shows success snackbar', (tester) async {
      // Arrange
      final mockService = MockProductService();
      when(() => mockService.fetchProduct(1)).thenAnswer((_) async => sampleProduct());
      final productProvider = ProductProvider(mockService);

      final storage = MockLocalStorage();
      when(() => storage.loadFavorites()).thenReturn(<int>[]);
      when(() => storage.saveFavorites(any())).thenAnswer((_) async {});
      when(() => storage.loadCart(any())).thenReturn(const []);
      when(() => storage.saveCart(any(), any())).thenAnswer((_) async {});

      final favorites = FavoritesProvider(storage);

      final auth = TestAuthProvider(authenticated: true, userId: 7);
      final cart = CartProvider(storage, auth);
      await cart.hydrate();

      final router = GoRouter(
        initialLocation: '/product/1',
        routes: [
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => ProductDetailScreen(
              productId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: productProvider),
            ChangeNotifierProvider.value(value: favorites),
            ChangeNotifierProvider<AuthProvider>.value(value: auth),
            ChangeNotifierProvider.value(value: cart),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Tap add to cart
      final addBtn = find.widgetWithText(FilledButton, 'Ajouter au panier');
      expect(addBtn, findsOneWidget);
      await tester.tap(addBtn);
      await tester.pump(); // snackbar

      expect(find.text('Ajouté au panier'), findsOneWidget);
    });
  });
}
