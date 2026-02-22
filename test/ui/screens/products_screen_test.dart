import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/products/products_screen.dart';
import 'package:flutter_projet/providers/product_provider.dart';
import 'package:flutter_projet/services/product_service.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/models/category.dart';

class MockProductService extends Mock implements ProductService {}

void main() {
  group('ProductsScreen', () {
    late MockProductService service;
    late ProductProvider provider;

    List<Product> sampleProducts() => [
          Product(
            id: 1,
            title: 'Produit A',
            price: 10.0,
            description: 'Desc',
            images: const [],
            category: Category(id: 1, name: 'Cat 1', image: ''),
          ),
          Product(
            id: 2,
            title: 'Produit B',
            price: 20.0,
            description: 'Desc',
            images: const [],
            category: Category(id: 2, name: 'Cat 2', image: ''),
          ),
        ];

    setUp(() {
      service = MockProductService();
      provider = ProductProvider(service);

      when(() => service.fetchProducts(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            priceMin: any(named: 'priceMin'),
            priceMax: any(named: 'priceMax'),
            title: any(named: 'title'),
          )).thenAnswer((_) async => sampleProducts());

      when(() => service.fetchCategories()).thenAnswer((_) async => <Category>[
            Category(id: 1, name: 'Cat 1', image: ''),
            Category(id: 2, name: 'Cat 2', image: ''),
          ]);
    });

    Widget wrap() {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: const ProductsScreen(),
        ),
      );
    }

    testWidgets('renders app bar and product tiles, supports search submit', (tester) async {
      await tester.pumpWidget(wrap());
      // initState triggers refresh/loadMore
      await tester.pumpAndSettle();

      expect(find.text('Produits'), findsOneWidget);
      expect(find.text('Produit A'), findsOneWidget);
      expect(find.text('Produit B'), findsOneWidget);

      // Search submit
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'phone');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // After search submit, provider.refresh() is called internally; list still renders
      expect(find.text('Produit A'), findsOneWidget);
      expect(find.text('Produit B'), findsOneWidget);

      // Open filters bottom sheet
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      expect(find.text('Filtres'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Réinitialiser'));
      await tester.pumpAndSettle();
      expect(find.text('Filtres'), findsNothing);
    });
  });
}
