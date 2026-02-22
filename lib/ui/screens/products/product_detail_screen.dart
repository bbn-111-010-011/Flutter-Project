import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/product_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await context.read<ProductProvider>().fetchProductById(widget.productId);
    setState(() {
      _product = p;
      _loading = false;
    });
  }

  void _toggleFavorite() {
    if (_product == null) return;
    context.read<FavoritesProvider>().toggle(_product!.id);
  }

  Future<void> _addToCart() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connectez-vous pour ajouter au panier')),
        );
        context.go('/login');
      }
      return;
    }
    if (_product == null) return;
    try {
      await context.read<CartProvider>().addProduct(_product!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajouté au panier')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final p = _product;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Article introuvable')),
      );
    }

    final isFav = context.select<FavoritesProvider, bool>((fp) => fp.isFavorite(p.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: _toggleFavorite,
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
          ),
        ],
      ),
      body: ListView(
        children: [
          if (p.images.isNotEmpty)
            SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: p.images.length,
                itemBuilder: (_, i) {
                  final img = p.images[i];
                  return CachedNetworkImage(
                    imageUrl: img,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE0E0E0),
                      child: Icon(Icons.broken_image),
                    ),
                  );
                },
              ),
            )
          else
            const SizedBox(
              height: 280,
              child: Center(child: Icon(Icons.image_not_supported, size: 48)),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              p.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Chip(
                  label: Text('${p.price.toStringAsFixed(2)} €'),
                  avatar: const Icon(Icons.sell, size: 18),
                ),
                const SizedBox(width: 8),
                if (p.category != null)
                  Chip(
                    label: Text(p.category!.name),
                    avatar: const Icon(Icons.category, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(p.description),
          ),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: cs.primary),
              onPressed: _addToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Ajouter au panier'),
            ),
          ),
        ),
      ),
    );
  }
}
