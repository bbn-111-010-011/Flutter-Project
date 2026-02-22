import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/providers/favorites_provider.dart';
import 'package:flutter_projet/repositories/local_storage.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  group('FavoritesProvider', () {
    late MockLocalStorage storage;
    late FavoritesProvider provider;

    setUp(() {
      storage = MockLocalStorage();
      when(() => storage.loadFavorites()).thenReturn(<int>[]);
      when(() => storage.saveFavorites(any())).thenAnswer((_) async {});
      provider = FavoritesProvider(storage);
    });

    test('initial favorites loaded from storage', () {
      expect(provider.favorites, isEmpty);
    });

    test('toggle adds when not present, then removes', () async {
      await provider.toggle(5);
      expect(provider.isFavorite(5), isTrue);
      verify(() => storage.saveFavorites(any(that: contains(5)))).called(1);

      await provider.toggle(5);
      expect(provider.isFavorite(5), isFalse);
      verify(() => storage.saveFavorites(any(that: isNot(contains(5))))).called(1);
    });

    test('remove deletes if present and persists', () async {
      await provider.toggle(3);
      expect(provider.isFavorite(3), isTrue);

      await provider.remove(3);
      expect(provider.isFavorite(3), isFalse);
      verify(() => storage.saveFavorites(any(that: isNot(contains(3))))).called(1);
    });

    test('clear empties favorites and persists', () async {
      await provider.toggle(1);
      await provider.toggle(2);
      expect(provider.favorites.length, 2);

      await provider.clear();
      expect(provider.favorites, isEmpty);
      verify(() => storage.saveFavorites(<int>[])).called(1);
    });

    test('hydrate reloads from storage', () async {
      when(() => storage.loadFavorites()).thenReturn(<int>[7, 9]);
      await provider.hydrate();
      expect(provider.favorites, [7, 9]);
    });
  });
}
