import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/providers/cart_provider.dart';
import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/models/category.dart';
import 'package:flutter_projet/models/cart_item.dart';
import 'package:flutter_projet/models/user.dart';
import 'package:flutter_projet/providers/auth_provider.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

class TestAuthNotifier extends ChangeNotifier implements AuthProvider {
  AppUser? _user;

  @override
  AppUser? get user => _user;

  set testUser(AppUser? u) {
    _user = u;
    notifyListeners();
  }

  @override
  bool get isAuthenticated => _user != null;

  @override
  String? get token => null;

  @override
  bool get loading => false;

  @override
  String? get error => null;

  @override
  Future<void> hydrate() async {}

  @override
  Future<void> login(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  @override
  Future<String?> tokenProvider() async => null;

  @override
  Future<void> register(String name, String email, String password) async {
    throw UnimplementedError();
  }
}

void main() {
  group('CartProvider', () {
    late MockLocalStorage storage;
    late TestAuthNotifier auth;
    late CartProvider cart;

    final user = AppUser(
      id: 1,
      name: 'U',
      email: 'u@mail.com',
      avatar: '',
      role: 'customer',
    );

    Product p(int id, {double price = 10}) => Product(
          id: id,
          title: 'P$id',
          price: price,
          description: 'd',
          images: const [],
          category: Category(id: 1, name: 'C', image: ''),
        );

    setUp(() {
      storage = MockLocalStorage();
      auth = TestAuthNotifier();
      cart = CartProvider(storage, auth);

      // Default storage stubs
      when(() => storage.loadCart(any())).thenReturn(const <CartItem>[]);
      when(() => storage.saveCart(any(), any())).thenAnswer((_) async {});
    });

    test('hydrate loads empty if no user, loads user cart when user present', () async {
      await cart.hydrate();
      expect(cart.items, isEmpty);

      auth.testUser = user;
      when(() => storage.loadCart(user.id)).thenReturn(<CartItem>[
        CartItem(productId: 5, title: 'P5', price: 15, quantity: 2, image: ''),
      ]);

      await cart.hydrate();
      expect(cart.items.length, 1);
      expect(cart.items.first.productId, 5);
    });

    test('addProduct throws if unauthenticated', () async {
      expect(() => cart.addProduct(p(1)), throwsA(isA<UnauthenticatedException>()));
    });

    test('addProduct adds and increments quantities; persists each time', () async {
      auth.testUser = user;

      await cart.addProduct(p(2), quantity: 1);
      expect(cart.items.first.quantity, 1);
      verify(() => storage.saveCart(user.id, any())).called(1);

      await cart.addProduct(p(2), quantity: 3);
      expect(cart.items.first.quantity, 4);
      verify(() => storage.saveCart(user.id, any())).called(1);
    });

    test('updateQuantity updates, removes on 0 or less; persists', () async {
      auth.testUser = user;

      await cart.addProduct(p(3), quantity: 2);
      expect(cart.items.first.quantity, 2);

      await cart.updateQuantity(3, 5);
      expect(cart.items.first.quantity, 5);

      await cart.updateQuantity(3, 0);
      expect(cart.items, isEmpty);
    });

    test('removeProduct removes by id; clear empties entire cart', () async {
      auth.testUser = user;

      await cart.addProduct(p(4), quantity: 1);
      await cart.addProduct(p(5), quantity: 1);
      expect(cart.items.length, 2);

      await cart.removeProduct(4);
      expect(cart.items.map((e) => e.productId), [5]);

      await cart.clear();
      expect(cart.items, isEmpty);
    });

    test('total computes correctly', () async {
      auth.testUser = user;

      await cart.addProduct(p(10, price: 2.5), quantity: 2); // 5.0
      await cart.addProduct(p(11, price: 3), quantity: 3); // 9.0
      expect(cart.total, closeTo(14.0, 0.0001));
    });

    test('auth change triggers re-hydration', () async {
      // Initially unauthenticated: no items
      await cart.hydrate();
      expect(cart.items, isEmpty);

      // When auth changes to a user, the provider should load cart
      when(() => storage.loadCart(user.id)).thenReturn(<CartItem>[
        CartItem(productId: 6, title: 'P6', price: 1, quantity: 1, image: ''),
      ]);
      auth.testUser = user;

      // Wait a microtask for listener
      await Future<void>.delayed(Duration.zero);
      expect(cart.items.map((e) => e.productId), [6]);
    });
  });
}
