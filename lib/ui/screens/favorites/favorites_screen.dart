import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../models/product.dart';
import '../../widgets/product_tile.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  List<Product> _resolveFavorites(
    List<int> ids,
    List<Product> loadedProducts,
  ) {
    final map = {for (final p in loadedProducts) p.id: p};
    final result = <Product>[];
    for (final id in ids) {
      final p = map[id];
      if (p != null) result.add(p);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final favIds = context.watch<FavoritesProvider>().favorites;
    final products = context.watch<ProductProvider>().products;
    final favProducts = _resolveFavorites(favIds, products);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
      ),
      body: favProducts.isEmpty
          ? const Center(child: Text('Aucun favori'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: favProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: .64,
              ),
              itemBuilder: (context, index) {
                final p = favProducts[index];
                return ProductTile(
                  product: p,
                  onTap: () => context.go('/product/${p.id}'),
                );
              },
            ),
    );
  }
}
