class Article {
  final String id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final bool fromSupabase;

  Article({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.fromSupabase = false,
  });

  factory Article.fromApi(Map<String, dynamic> json) {
    String image = '';

    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      image = json['images'][0].toString();
    }

    String categoryName = 'Sans catégorie';
    if (json['category'] is Map && json['category']['name'] != null) {
      categoryName = json['category']['name'].toString();
    }

    return Article(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? 'Sans titre',
      price: double.tryParse(json['price'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      category: categoryName,
      imageUrl: image,
      fromSupabase: false,
    );
  }

  factory Article.fromSupabase(Map<String, dynamic> json) {
    return Article(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? 'Sans titre',
      price: double.tryParse(json['price'].toString()) ?? 0,
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Sans catégorie',
      imageUrl: json['image_url']?.toString() ?? '',
      fromSupabase: true,
    );
  }

  Map<String, dynamic> toSupabaseJson(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image_url': imageUrl,
    };
  }
}
