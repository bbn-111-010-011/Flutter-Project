import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../../providers/auth_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final orders = context.read<OrdersProvider>();
    final auth = context.read<AuthProvider>();

    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter')),
      );
      return;
    }

    final items = cart.items;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Panier vide')),
      );
      return;
    }

    await orders.addFromCart(items);
    await cart.clear();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Achat validé')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = context.watch<CartProvider>().items;
    final total = context.watch<CartProvider>().total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
      ),
      body: items.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final it = items[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: it.image.isNotEmpty ? NetworkImage(it.image) : null,
                          child: it.image.isEmpty ? const Icon(Icons.image_not_supported) : null,
                        ),
                        title: Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('${it.price.toStringAsFixed(2)} €'),
                        trailing: SizedBox(
                          width: 130,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                tooltip: 'Retirer',
                                onPressed: () => context.read<CartProvider>().removeProduct(it.productId),
                                icon: const Icon(Icons.delete_outline),
                              ),
                              IconButton(
                                tooltip: 'Moins',
                                onPressed: () => context
                                    .read<CartProvider>()
                                    .updateQuantity(it.productId, it.quantity - 1),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text('${it.quantity}'),
                              IconButton(
                                tooltip: 'Plus',
                                onPressed: () => context
                                    .read<CartProvider>()
                                    .updateQuantity(it.productId, it.quantity + 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total: ${total.toStringAsFixed(2)} €',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _checkout(context),
                        icon: const Icon(Icons.check),
                        label: const Text('Valider l\'achat'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
