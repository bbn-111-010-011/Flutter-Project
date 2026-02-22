import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/services/product_service.dart';
import 'package:flutter_projet/services/api_client.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/models/category.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('ProductService', () {
    late MockApiClient api;
    late ProductService service;

    setUp(() {
      api = MockApiClient();
      service = ProductService(api);
    });

    test('fetchProducts builds correct query and maps list', () async {
      when(() => api.get('/products', query: any(named: 'query')))
          .thenAnswer((_) async => [
                {
                  'id': 1,
                  'title': 'Item A',
                  'price': 10,
                  'description': 'desc',
                  'images': ['http://x'],
                  'category': {'id': 2, 'name': 'Cat', 'image': 'http://y'}
                },
              ]);

      final list = await service.fetchProducts(
        offset: 0,
        limit: 30,
        categoryId: 2,
        priceMin: 5,
        priceMax: 50,
        title: 'item',
      );

      expect(list, isA<List<Product>>());
      expect(list.first.id, 1);

      final captured = verify(() => api.get('/products', query: captureAny(named: 'query'))).captured.single
          as Map<String, dynamic>;

      expect(captured['offset'], '0');
      expect(captured['limit'], '30');
      expect(captured['categoryId'], '2');
      expect(captured['price_min'], '5');
      expect(captured['price_max'], '50');
      expect(captured['title'], 'item');
    });

    test('fetchProduct maps single item', () async {
      when(() => api.get('/products/42')).thenAnswer((_) async => {
            'id': 42,
            'title': 'Answer',
            'price': 42,
            'description': 'life',
            'images': ['http://x'],
            'category': {'id': 1, 'name': 'Books', 'image': 'http://y'}
          });

      final p = await service.fetchProduct(42);
      expect(p.id, 42);
      expect(p.title, 'Answer');
    });

    test('fetchCategories maps list', () async {
      when(() => api.get('/categories')).thenAnswer((_) async => [
            {'id': 1, 'name': 'A', 'image': 'http://a'},
            {'id': 2, 'name': 'B', 'image': 'http://b'},
          ]);

      final cats = await service.fetchCategories();
      expect(cats, isA<List<Category>>());
      expect(cats.length, 2);
      expect(cats.first.name, 'A');
    });
  });
}
