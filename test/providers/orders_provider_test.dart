import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_projet/providers/orders_provider.dart';
import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/models/cart_item.dart';
import 'package:flutter_projet/models/order.dart';
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
  group('OrdersProvider', () {
    late MockLocalStorage storage;
    late TestAuthNotifier auth;
    late OrdersProvider orders;

    final user = AppUser(
      id: 42,
      name: 'Buyer',
      email: 'buyer@mail.com',
      avatar: '',
      role: 'customer',
    );

    setUp(() {
      storage = MockLocalStorage();
      auth = TestAuthNotifier();
      orders = OrdersProvider(storage, auth);

      when(() => storage.loadOrders(any())).thenReturn(const <Order>[]);
      when(() => storage.saveOrders(any(), any())).thenAnswer((_) async {});
    });

    test('hydrate loads empty when unauthenticated; loads for user when present', () async {
      // No user
      await orders.hydrate();
      expect(orders.orders, isEmpty);

      // With user -> storage consulted
      auth.testUser = user;
      final mockOrders = <Order>[
        Order(id: 'o1', date: DateTime(2024, 1, 10, 12, 30), items: const [
          OrderItem(productId: 1, title: 'P1', price: 5.0, image: '', quantity: 2),
        ]),
      ];
      when(() => storage.loadOrders(user.id)).thenReturn(mockOrders);

      await orders.hydrate();
      expect(orders.orders.length, 1);
      expect(orders.orders.first.id, 'o1');
    });

    test('addFromCart creates order with items and persists', () async {
      // Must be authenticated
      auth.testUser = user;

      final cartItems = <CartItem>[
        CartItem(productId: 1, title: 'A', price: 2.5, quantity: 2, image: ''),
        CartItem(productId: 2, title: 'B', price: 3.0, quantity: 1, image: ''),
      ];

      await orders.addFromCart(cartItems);

      expect(orders.orders, isNotEmpty);
      final created = orders.orders.first;
      expect(created.items.length, 2);
      expect(created.total, closeTo(2.5 * 2 + 3.0 * 1, 0.0001));
      verify(() => storage.saveOrders(user.id, any(that: isNotEmpty))).called(1);
    });

    test('addFromCart does nothing when unauthenticated or empty cart', () async {
      // unauthenticated
      await orders.addFromCart(const <CartItem>[]);
      expect(orders.orders, isEmpty);

      // authenticated but empty list
      auth.testUser = user;
      await orders.addFromCart(const <CartItem>[]);
      expect(orders.orders, isEmpty);
    });

    test('clear empties and persists', () async {
      auth.testUser = user;

      // Seed one order
      await orders.addFromCart([
        CartItem(productId: 1, title: 'X', price: 1.0, quantity: 1, image: ''),
      ]);
      expect(orders.orders, isNotEmpty);

      await orders.clear();
      expect(orders.orders, isEmpty);
      verify(() => storage.saveOrders(user.id, <Order>[])).called(1);
    });

    test('formatDate returns expected pattern "dd/MM/yyyy HH:mm"', () {
      final d = DateTime(2026, 2, 21, 14, 35);
      final s = orders.formatDate(d);
      // Basic pattern check
      final reg = RegExp(r'^\d{2}/\d{2}/\d{4} \d{2}:\d{2}$');
      expect(reg.hasMatch(s), isTrue);
    });

    test('auth change triggers re-hydration', () async {
      await orders.hydrate();
      expect(orders.orders, isEmpty);

      when(() => storage.loadOrders(user.id)).thenReturn(<Order>[
        Order(id: 'z', date: DateTime.now(), items: const [
          OrderItem(productId: 9, title: 'T', price: 1.0, image: '', quantity: 1),
        ])
      ]);

      auth.testUser = user;
      await Future<void>.delayed(Duration.zero);
      expect(orders.orders.first.id, 'z');
    });
  });
}
