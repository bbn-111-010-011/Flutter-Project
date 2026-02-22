import '../models/product.dart';
import '../models/category.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient api;
  ProductService(this.api);

  Future<List<Product>> fetchProducts({
    int offset = 0,
    int limit = 30,
    int? categoryId,
    int? priceMin,
    int? priceMax,
    String? title,
  }) async {
    final query = <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (categoryId != null) 'categoryId': categoryId,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (title != null && title.isNotEmpty) 'title': title,
    };

    final data = await api.get('/products', query: query);
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    }
    return [];
  }

  Future<Product> fetchProduct(int id) async {
    final data = await api.get('/products/$id');
    return Product.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<Category>> fetchCategories() async {
    final data = await api.get('/categories');
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    }
    return [];
  }

  Future<Product> createProduct({
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required List<String> images,
  }) async {
    final body = {
      'title': title,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'images': images,
    };
    final data = await api.post('/products', body: body, auth: true);
    return Product.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
