import 'cart_item.dart';

class OrderItem {
  final int productId;
  final String title;
  final double price;
  final String image;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final priceNum = json['price'];
    final parsedPrice = priceNum is num ? priceNum.toDouble() : 0.0;
    return OrderItem(
      productId: (json['productId'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: parsedPrice,
      image: json['image'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'price': price,
        'image': image,
        'quantity': quantity,
      };

  double get lineTotal => price * quantity;

  factory OrderItem.fromCartItem(CartItem c) => OrderItem(
        productId: c.productId,
        title: c.title,
        price: c.price,
        image: c.image,
        quantity: c.quantity,
      );
}

class Order {
  final String id; // locally generated id
  final DateTime date;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.items,
  });

  double get total =>
      items.fold(0.0, (sum, it) => sum + (it.price * it.quantity));

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? const [];
    return Order(
      id: json['id']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(OrderItem.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };
}
