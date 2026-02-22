import 'product.dart';

class CartItem {
  final int productId;
  final String title;
  final double price;
  final String image;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  factory CartItem.fromProduct(Product p, {int quantity = 1}) {
    return CartItem(
      productId: p.id,
      title: p.title,
      price: p.price,
      image: p.images.isNotEmpty ? p.images.first : '',
      quantity: quantity,
    );
  }

  CartItem copyWith({
    int? productId,
    String? title,
    double? price,
    String? image,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final priceNum = json['price'];
    final parsedPrice = priceNum is num ? priceNum.toDouble() : 0.0;
    return CartItem(
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
}
