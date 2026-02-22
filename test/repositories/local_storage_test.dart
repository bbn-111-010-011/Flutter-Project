import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/models/user.dart';

void main() {
  group('LocalStorage', () {
    late LocalStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorage();
      await storage.init();
    });

    test('onboarding seen flag persists', () async {
      expect(storage.getOnboardingSeen(), isFalse);

      await storage.setOnboardingSeen(true);
      expect(storage.getOnboardingSeen(), isTrue);

      await storage.setOnboardingSeen(false);
      expect(storage.getOnboardingSeen(), isFalse);
    });

    test('token persists and clears', () async {
      expect(storage.getToken(), isNull);

      await storage.setToken('abc');
      expect(storage.getToken(), 'abc');

      await storage.setToken(null);
      expect(storage.getToken(), isNull);
    });

    test('user persists and clears', () async {
      final u = AppUser(
        id: 1,
        name: 'John',
        email: 'john@mail.com',
        avatar: 'http://img',
        role: 'customer',
      );

      await storage.setUser(u);
      final loaded = storage.getUser();
      expect(loaded, isNotNull);
      expect(loaded!.email, 'john@mail.com');

      await storage.setUser(null);
      expect(storage.getUser(), isNull);
    });

    test('favorites list persists', () async {
      expect(storage.loadFavorites(), isEmpty);

      await storage.saveFavorites([1, 2, 3]);
      expect(storage.loadFavorites(), [1, 2, 3]);

      await storage.saveFavorites([]);
      expect(storage.loadFavorites(), isEmpty);
    });
  });
}
