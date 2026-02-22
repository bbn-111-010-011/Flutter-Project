import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/favorites/favorites_screen.dart';
import 'package:flutter_projet/ui/screens/products/product_detail_screen.dart';
import 'package:flutter_projet/ui/widgets/product_tile.dart';
import 'package:flutter_projet/providers/favorites_provider.dart';
import 'package:flutter_projet/providers/product_provider.dart';
import 'package:flutter_projet/services/product_service.dart';
import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/models/category.dart';

class MockLocalStorage extends Mock implements LocalStorage {}
class MockProductService extends Mock implements ProductService {}

void main() {
  group('FavoritesScreen', () {
    late MockLocalStorage storage;
    late FavoritesProvider favorites;
    late MockProductService service;
    late ProductProvider productsProvider;

    Product p(int id, String title) => Product(
          id: id,
          title: title,
          price: 9.99 + id,
          description: 'Desc $id',
          images: const [],
          category: Category(id: 1, name: 'Cat', image: ''),
        );

    setUp(() async {
      storage = MockLocalStorage();
      when(() => storage.loadFavorites()).thenReturn(<int>[]);
      when(() => storage.saveFavorites(any())).thenAnswer((_) async {});
      favorites = FavoritesProvider(storage);

      service = MockProductService();
      when(() => service.fetchProducts(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            priceMin: any(named: 'priceMin'),
            priceMax: any(named: 'priceMax'),
            title: any(named: 'title'),
          )).thenAnswer((_) async => [p(1, 'A'), p(2, 'B')]);
      when(() => service.fetchCategories()).thenAnswer((_) async => <Category>[]);

      productsProvider = ProductProvider(service);
      // Preload some products for mapping
      await productsProvider.refresh();
    });

    Widget buildApp({String initialLocation = '/favorites'}) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/product/:id',
            builder: (context, state) => ProductDetailScreen(
              productId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      );

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoritesProvider>.value(value: favorites),
          ChangeNotifierProvider<ProductProvider>.value(value: productsProvider),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('shows empty state when no favorites', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Favoris'), findsOneWidget);
      expect(find.text('Aucun favori'), findsOneWidget);
    });

    testWidgets('renders favorite products and navigates to detail on tap', (tester) async {
      // Add some favorites (ids match preloaded products)
      await favorites.toggle(1);
      await favorites.toggle(2);

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Two product tiles should be shown
      expect(find.byType(ProductTile), findsNWidgets(2));
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      // Tap first tile navigates to product detail
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      // ProductDetailScreen shows loader/title eventually; ensure screen navigated
      expect(find.byType(ProductDetailScreen), findsOneWidget);
    });
  });
}
