import 'category.dart';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final Category? category;
  final DateTime? creationAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    this.category,
    this.creationAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // images can be List<dynamic> that may contain nulls or invalid URLs
    final imgs = (json['images'] as List?)
            ?.whereType<dynamic>()
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];
    // price might be int or double
    final priceNum = json['price'];
    final parsedPrice = priceNum is num ? priceNum.toDouble() : 0.0;

    return Product(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: parsedPrice,
      description: json['description'] as String? ?? '',
      images: imgs,
      category: json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      creationAt: json['creationAt'] != null
          ? DateTime.tryParse(json['creationAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'images': images,
        'category': category?.toJson(),
        'creationAt': creationAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    List<String>? images,
    Category? category,
    DateTime? creationAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      creationAt: creationAt ?? this.creationAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
