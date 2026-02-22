import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../repositories/local_storage.dart';
import 'auth_provider.dart';

class OrdersProvider extends ChangeNotifier {
  final LocalStorage _storage;
  final AuthProvider _auth;

  OrdersProvider(this._storage, this._auth) {
    _auth.addListener(_onAuthChanged);
  }

  List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  int get _userId => _auth.user?.id ?? -1;
  bool get _hasUser => _auth.user != null;

  Future<void> hydrate() async {
    if (_hasUser) {
      _orders = _storage.loadOrders(_userId);
    } else {
      _orders = [];
    }
    notifyListeners();
  }

  Future<void> addFromCart(List<CartItem> items) async {
    if (!_hasUser) return;
    if (items.isEmpty) return;
    final orderItems = items.map(OrderItem.fromCartItem).toList();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final order = Order(
      id: id,
      date: DateTime.now(),
      items: orderItems,
    );
    _orders = [order, ..._orders];
    await _persist();
  }

  String formatDate(DateTime d) {
    // Example: 21/02/2026 14:35
    return DateFormat('dd/MM/yyyy HH:mm').format(d);
  }

  Future<void> clear() async {
    if (!_hasUser) return;
    _orders = [];
    await _persist();
  }

  Future<void> _persist() async {
    await _storage.saveOrders(_userId, _orders);
    notifyListeners();
  }

  void _onAuthChanged() {
    hydrate();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
