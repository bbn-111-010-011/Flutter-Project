import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/favoris_provider.dart';
import '../providers/panier_provider.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final favorisProvider = context.watch<FavorisProvider>();
    final isFavori = favorisProvider.isFavori(article.id);

    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: article.imageUrl.isEmpty
                    ? Container(
                        height: 220,
                        color: Colors.grey.shade300,
                        child: const Center(child: Icon(Icons.image_not_supported, size: 60)),
                      )
                    : Image.network(
                        article.imageUrl,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            color: Colors.grey.shade300,
                            child: const Center(child: Icon(Icons.image_not_supported, size: 60)),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Prix : ${article.price.toStringAsFixed(2)} €'),
            Text('Catégorie : ${article.category}'),
            if (article.fromSupabase) const Text('Article proposé par un utilisateur'),
            const SizedBox(height: 16),
            Text(article.description),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(isFavori ? Icons.favorite : Icons.favorite_border),
                    label: Text(isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                    onPressed: () => favorisProvider.toggleFavori(article.id),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ajouter au panier'),
                onPressed: () async {
                  final success = await context.read<PanierProvider>().addArticle(article);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Article ajouté au panier'
                            : 'Connectez-vous et configurez Supabase pour utiliser le panier',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
