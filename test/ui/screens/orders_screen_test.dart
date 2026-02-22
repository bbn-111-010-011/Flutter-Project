import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_projet/ui/screens/orders/orders_screen.dart';
import 'package:flutter_projet/providers/orders_provider.dart';
import 'package:flutter_projet/models/order.dart';

class TestOrdersProvider extends ChangeNotifier implements OrdersProvider {
  // Implement minimal surface used by the screen
  List<Order> _orders = [];

  @override
  List<Order> get orders => List.unmodifiable(_orders);

  set testOrders(List<Order> value) {
    _orders = value;
    notifyListeners();
  }

  // Unused methods for this widget test
  @override
  Future<void> addFromCart(List items) async => throw UnimplementedError();
  @override
  Future<void> clear() async => throw UnimplementedError();
  @override
  Future<void> hydrate() async => throw UnimplementedError();
  @override
  String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute}';
}

void main() {
  Widget _wrap(Widget child, TestOrdersProvider p) {
    return MaterialApp(
      home: ChangeNotifierProvider<OrdersProvider>.value(
        value: p,
        child: child,
      ),
    );
  }

  testWidgets('OrdersScreen renders empty state', (tester) async {
    final p = TestOrdersProvider();
    await tester.pumpWidget(_wrap(const OrdersScreen(), p));
    expect(find.text('Aucun achat pour le moment'), findsOneWidget);
  });

  testWidgets('OrdersScreen renders orders and expands items', (tester) async {
    final p = TestOrdersProvider();
    p.testOrders = [
      Order(
        id: 'o1',
        date: DateTime(2025, 1, 1, 10, 0),
        items: const [
          OrderItem(productId: 1, title: 'Item 1', price: 2.5, image: '', quantity: 2),
          OrderItem(productId: 2, title: 'Item 2', price: 3.0, image: '', quantity: 1),
        ],
      ),
    ];

    await tester.pumpWidget(_wrap(const OrdersScreen(), p));

    expect(find.textContaining('Commande #o1'), findsOneWidget);
    // Expand
    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.textContaining('2.50 €'), findsWidgets);
  });
}
