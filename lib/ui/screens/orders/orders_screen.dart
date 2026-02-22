import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/orders_provider.dart';
import '../../../models/order.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;
    final df = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des achats')),
      body: orders.isEmpty
          ? const Center(child: Text('Aucun achat pour le moment'))
          : ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final Order order = orders[index];
                return ExpansionTile(
                  title: Text('Commande #${order.id}'),
                  subtitle: Text('${df.format(order.date)} • Total ${order.total.toStringAsFixed(2)} €'),
                  children: [
                    ...order.items.map(
                      (it) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: it.image.isNotEmpty ? NetworkImage(it.image) : null,
                          child: it.image.isEmpty ? const Icon(Icons.image_not_supported) : null,
                        ),
                        title: Text(it.title),
                        subtitle: Text(
                          '${it.price.toStringAsFixed(2)} €  × ${it.quantity}  = ${(it.price * it.quantity).toStringAsFixed(2)} €',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
    );
  }
}
