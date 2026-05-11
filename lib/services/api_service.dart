import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/article.dart';

class ApiService {
  final String baseUrl = 'https://api.escuelajs.co/api/v1';

  Future<List<Article>> getArticles() async {
    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Article.fromApi(item)).toList();
    } else {
      throw Exception('Erreur lors du chargement des articles');
    }
  }

  Future<List<String>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => item['name'].toString()).toList();
    } else {
      throw Exception('Erreur lors du chargement des catégories');
    }
  }
}
