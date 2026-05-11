import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/favoris_provider.dart';
import '../providers/panier_provider.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final favorisProvider = context.watch<FavorisProvider>();
    final isFavori = favorisProvider.isFavori(article.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        onTap: () => context.push('/article/${article.id}', extra: article),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: article.imageUrl.isEmpty
              ? Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image_not_supported),
                )
              : Image.network(
                  article.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
        ),
        title: Text(
          article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${article.price.toStringAsFixed(2)} € - ${article.category}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isFavori ? Icons.favorite : Icons.favorite_border),
              color: isFavori ? Colors.red : null,
              onPressed: () {
                favorisProvider.toggleFavori(article.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_shopping_cart),
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
          ],
        ),
      ),
    );
  }
}
