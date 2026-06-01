// test_achat.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/models/article.dart';
import 'package:your_app/models/achat.dart';

void main() {
  test('Création d\'un Achat', () {
    final article = Article(id: 1, title: 'Test Article', price: 100.0);
    final achat = Achat(article: article, quantity: 2);

    expect(achat.article.id, 1);
    expect(achat.article.title, 'Test Article');
    expect(achat.quantity, 2);
  });

  test('Calcul du total', () {
    final article = Article(id: 1, title: 'Test Article', price: 100.0);
    final achat = Achat(article: article, quantity: 3);

    expect(achat.totalPrice(), 300.0);
  });
}