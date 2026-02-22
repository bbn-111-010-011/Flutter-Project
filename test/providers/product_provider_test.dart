import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/providers/product_provider.dart';
import 'package:flutter_projet/services/product_service.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/models/category.dart';

class MockProductService extends Mock implements ProductService {}

Product _fakeProduct(int id) => Product(
      id: id,
      title: 'P$id',
      price: 10.0 * id,
      description: 'desc',
      images: const [],
      category: Category(id: 1, name: 'Cat', image: ''),
    );

void main() {
  group('ProductProvider', () {
    late MockProductService service;
    late ProductProvider provider;

    setUp(() {
      service = MockProductService();
      provider = ProductProvider(service);
    });

    test('initial state', () {
      expect(provider.products, isEmpty);
      expect(provider.categories, isEmpty);
      expect(provider.loading, isFalse);
      expect(provider.hasMore, isTrue);
      expect(provider.search, '');
      expect(provider.categoryId, isNull);
    });

    test('loadCategories populates categories (non-blocking on error)', () async {
      when(() => service.fetchCategories())
          .thenAnswer((_) async => [Category(id: 1, name: 'A', image: '')]);

      await provider.loadCategories();

      expect(provider.categories.length, 1);
      expect(provider.categories.first.name, 'A');
    });

    test('refresh resets pagination and loads first page', () async {
      when(() => service.fetchProducts(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            priceMin: any(named: 'priceMin'),
            priceMax: any(named: 'priceMax'),
            title: any(named: 'title'),
          )).thenAnswer((_) async => List.generate(5, (i) => _fakeProduct(i + 1)));

      await provider.refresh();

      expect(provider.products.length, 5);
      expect(provider.hasMore, isFalse); // because returned < limit (30)
    });

    test('loadMore appends and updates hasMore/offset', () async {
      // First page returns 30 items (limit), second returns 10
      when(() => service.fetchProducts(
            offset: 0,
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            priceMin: any(named: 'priceMin'),
            priceMax: any(named: 'priceMax'),
            title: any(named: 'title'),
          )).thenAnswer((_) async => List.generate(30, (i) => _fakeProduct(i + 1)));

      when(() => service.fetchProducts(
            offset: 30,
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            priceMin: any(named: 'priceMin'),
            priceMax: any(named: 'priceMax'),
            title: any(named: 'title'),
          )).thenAnswer((_) async => List.generate(10, (i) => _fakeProduct(31 + i)));

      await provider.loadMore(reset: true);
      expect(provider.products.length, 30);
      expect(provider.hasMore, isTrue);

      await provider.loadMore();
      expect(provider.products.length, 40);
      expect(provider.hasMore, isFalse);
    });

    test('applyFilters stores filters and triggers refresh', () async {
      when(() => service.fetchProducts(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            categoryId: any(named: 'categoryId'),
            priceMin: any(named: 'priceMin'),
            priceMax: any(named: 'priceMax'),
            title: any(named: 'title'),
          )).thenAnswer((_) async => []);

      await provider.applyFilters(
        categoryId: 2,
        priceMin: 10,
        priceMax: 50,
        search: 'abc',
      );

      final captured = verify(() => service.fetchProducts(
            offset: captureAny(named: 'offset'),
            limit: captureAny(named: 'limit'),
            categoryId: captureAny(named: 'categoryId'),
            priceMin: captureAny(named: 'priceMin'),
            priceMax: captureAny(named: 'priceMax'),
            title: captureAny(named: 'title'),
          )).captured;

      // Order: offset, limit, categoryId, priceMin, priceMax, title
      expect(captured[2], 2);
      expect(captured[3], 10);
      expect(captured[4], 50);
      expect(captured[5], 'abc');

      expect(provider.categoryId, 2);
      expect(provider.priceMin, 10);
      expect(provider.priceMax, 50);
      expect(provider.search, 'abc');
    });

    test('fetchProductById returns product or null on error', () async {
      when(() => service.fetchProduct(7)).thenAnswer((_) async => _fakeProduct(7));
      final p = await provider.fetchProductById(7);
      expect(p?.id, 7);

      when(() => service.fetchProduct(8)).thenThrow(Exception('nope'));
      final q = await provider.fetchProductById(8);
      expect(q, isNull);
    });
  });
}
