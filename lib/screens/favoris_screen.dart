import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/article_provider.dart';
import '../providers/favoris_provider.dart';
import '../widgets/article_card.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articleProvider = context.watch<ArticleProvider>();
    final favorisProvider = context.watch<FavorisProvider>();

    final favoris = articleProvider.allArticles
        .where((article) => favorisProvider.isFavori(article.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: favoris.isEmpty
          ? const Center(child: Text('Aucun favori pour le moment'))
          : ListView.builder(
              itemCount: favoris.length,
              itemBuilder: (context, index) {
                return ArticleCard(article: favoris[index]);
              },
            ),
    );
  }
}
