import 'article.dart';

class CartItem {
  final String id;
  final Article article;
  final int quantity;

  CartItem({
    required this.id,
    required this.article,
    required this.quantity,
  });

  double get total => article.price * quantity;

  factory CartItem.fromSupabase(Map<String, dynamic> json) {
    final article = Article(
      id: json['article_id'].toString(),
      title: json['title']?.toString() ?? 'Sans titre',
      price: double.tryParse(json['price'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Sans catégorie',
      imageUrl: json['image_url']?.toString() ?? '',
      fromSupabase: json['from_supabase'] == true,
    );

    return CartItem(
      id: json['id'].toString(),
      article: article,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
    );
  }

  Map<String, dynamic> toSupabaseJson(String userId) {
    return {
      'user_id': userId,
      'article_id': article.id,
      'title': article.title,
      'price': article.price,
      'description': article.description,
      'category': article.category,
      'image_url': article.imageUrl,
      'from_supabase': article.fromSupabase,
      'quantity': quantity,
    };
  }

  Map<String, dynamic> toSimpleJson() {
    return {
      'article_id': article.id,
      'title': article.title,
      'price': article.price,
      'category': article.category,
      'quantity': quantity,
    };
  }
}
