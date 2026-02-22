import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/cart/cart_screen.dart';
import 'package:flutter_projet/providers/cart_provider.dart';
import 'package:flutter_projet/providers/orders_provider.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/models/cart_item.dart';
import 'package:flutter_projet/models/user.dart';

// Mocks
class MockLocalStorage extends Mock implements LocalStorage {}

// Lightweight AuthProvider test double
class TestAuthProvider extends ChangeNotifier implements AuthProvider {
  TestAuthProvider({this.authenticated = true, this.userId = 1});

  bool authenticated;
  int userId;

  @override
  bool get loading => false;

  @override
  AppUser? get user => authenticated
      ? AppUser(
          id: userId,
          name: 'User',
          email: 'user@mail.com',
          avatar: '',
          role: 'customer',
        )
      : null;

  @override
  String? get token => authenticated ? 'token' : null;

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
  group('CartScreen', () {
    late MockLocalStorage storage;
    late TestAuthProvider auth;
    late CartProvider cart;
    late OrdersProvider orders;

    setUp(() async {
      storage = MockLocalStorage();
      auth = TestAuthProvider(authenticated: true, userId: 99);

      // Default empty states
      when(() => storage.loadCart(any())).thenReturn(const []);
      when(() => storage.saveCart(any(), any())).thenAnswer((_) async {});
      when(() => storage.loadOrders(any())).thenReturn(const []);
      when(() => storage.saveOrders(any(), any())).thenAnswer((_) async {});

      cart = CartProvider(storage, auth);
      orders = OrdersProvider(storage, auth);

      await cart.hydrate();
      await orders.hydrate();
    });

    Widget buildApp() {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const CartScreen(),
          ),
        ],
      );
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<CartProvider>.value(value: cart),
          ChangeNotifierProvider<OrdersProvider>.value(value: orders),
        ],
        child: MaterialApp.router(routerConfig: router),
      );
    }

    testWidgets('shows empty state when cart is empty', (tester) async {
      when(() => storage.loadCart(any())).thenReturn(const []);
      await cart.hydrate();

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Votre panier est vide'), findsOneWidget);
      expect(find.textContaining('Total:'), findsNothing);
    });

    testWidgets('increment, decrement and remove update total', (tester) async {
      // Start with one line item: price 10, qty 2 => total 20
      final initial = [
        CartItem(productId: 1, title: 'Item', price: 10.0, image: '', quantity: 2),
      ];
      when(() => storage.loadCart(any())).thenReturn(initial);
      await cart.hydrate();

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('Total: 20.00 €'), findsOneWidget);

      // Tap + to increment to 3 => total 30
      await tester.tap(find.byTooltip('Plus').first);
      await tester.pump();
      expect(find.textContaining('Total: 30.00 €'), findsOneWidget);

      // Tap - twice: 3->2->1 => total 10
      await tester.tap(find.byTooltip('Moins').first);
      await tester.pump();
      await tester.tap(find.byTooltip('Moins').first);
      await tester.pump();
      expect(find.textContaining('Total: 10.00 €'), findsOneWidget);

      // Tap - once more to 0, triggers removal => empty
      await tester.tap(find.byTooltip('Moins').first);
      await tester.pumpAndSettle();
      expect(find.text('Votre panier est vide'), findsOneWidget);
    });

    testWidgets('checkout succeeds: creates order and clears cart', (tester) async {
      final initial = [
        CartItem(productId: 1, title: 'Item', price: 15.0, image: '', quantity: 2),
      ];
      when(() => storage.loadCart(any())).thenReturn(initial);
      await cart.hydrate();

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      // Validate purchase
      await tester.tap(find.widgetWithText(FilledButton, "Valider l'achat"));
      await tester.pump(); // show snackbar

      expect(find.text('Achat validé'), findsOneWidget);
      await tester.pumpAndSettle();

      // Cart cleared
      expect(find.text('Votre panier est vide'), findsOneWidget);
      // Orders persisted once
      expect(orders.orders.length, 1);
      expect(orders.orders.first.total, 30.0);
    });

    testWidgets('checkout unauthenticated shows snackbar', (tester) async {
      auth.authenticated = false;
      auth.notifyListeners();

      when(() => storage.loadCart(any())).thenReturn([
        CartItem(productId: 1, title: 'Item', price: 12.0, image: '', quantity: 1),
      ]);
      await cart.hydrate();

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, "Valider l'achat"));
      await tester.pump();

      expect(find.text('Veuillez vous connecter'), findsOneWidget);
    });
  });
}
