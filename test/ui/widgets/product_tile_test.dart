import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/models/category.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/providers/favorites_provider.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/repositories/auth_repository.dart';
import 'package:flutter_projet/services/api_client.dart';
import 'package:flutter_projet/services/auth_service.dart';
import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/ui/widgets/product_tile.dart';

class MockLocalStorage extends Mock implements LocalStorage {}
class MockAuthService extends Mock implements AuthService {}
class MockHttpClientProvider extends Mock {
  Future<String?> call();
}

void main() {
  group('ProductTile', () {
    late MockLocalStorage storage;
    late FavoritesProvider favorites;
    late AuthRepository authRepo;
    late AuthProvider authProvider;

    final product = Product(
      id: 1,
      title: 'Produit Test',
      price: 12.5,
      description: 'Desc',
      images: const ['https://picsum.photos/200'],
      category: Category(id: 2, name: 'Cat', image: ''),
    );

    setUp(() async {
      storage = MockLocalStorage();
      when(() => storage.loadFavorites()).thenReturn(<int>[]);
      when(() => storage.saveFavorites(any())).thenAnswer((_) async {});
      when(() => storage.getToken()).thenReturn(null);
      when(() => storage.getUser()).thenReturn(null);

      favorites = FavoritesProvider(storage);

      final mockAuthService = MockAuthService();
      authRepo = AuthRepository(storage: storage, service: mockAuthService);

      final tokenProvider = () async => storage.getToken();
      final apiClient = ApiClient(tokenProvider: tokenProvider);

      authProvider = AuthProvider(authRepo, apiClient);
      await authProvider.hydrate();
    });

    Widget _buildApp(Widget body) {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(body: body),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(body: Text('Login Page'))),
        ],
      );

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoritesProvider>.value(value: favorites),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('renders title, price and image', (tester) async {
      await tester.pumpWidget(_buildApp(ProductTile(product: product)));

      expect(find.text('Produit Test'), findsOneWidget);
      expect(find.text('12.50 €'), findsOneWidget);
      // Image widget exists (CachedNetworkImage)
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('toggle favorite updates provider', (tester) async {
      await tester.pumpWidget(_buildApp(ProductTile(product: product)));

      final favBtn = find.byIcon(Icons.favorite_border);
      expect(favBtn, findsOneWidget);

      await tester.tap(favBtn);
      await tester.pump();

      expect(favorites.isFavorite(product.id), isTrue);
    });

    testWidgets('add to cart unauthenticated shows snackbar and routes to /login', (tester) async {
      await tester.pumpWidget(_buildApp(ProductTile(product: product)));

      // Button label 'Ajouter'
      final addBtn = find.widgetWithText(FilledButton, 'Ajouter');
      expect(addBtn, findsOneWidget);

      await tester.tap(addBtn);
      await tester.pump();

      // Should show snackbar about login
      expect(find.textContaining('Connectez-vous'), findsOneWidget);

      // GoRouter navigated to /login
      await tester.pumpAndSettle();
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
