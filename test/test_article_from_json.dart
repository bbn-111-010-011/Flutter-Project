// test_article_from_json.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/models/article.dart';

void main() {
  test('Conversion JSON vers Article', () {
    final json = {'id': 2, 'title': 'JSON Article', 'price': 50.0};
    final article = Article.fromJson(json);

    expect(article.id, 2);
    expect(article.title, 'JSON Article');
    expect(article.price, 50.0);
  });
}