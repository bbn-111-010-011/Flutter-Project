import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/achat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/panier_provider.dart';

class PanierScreen extends StatefulWidget {
  const PanierScreen({super.key});

  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PanierProvider>().loadPanier());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final panierProvider = context.watch<PanierProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: !authProvider.isLoggedIn
          ? const Center(child: Text('Connectez-vous pour utiliser le panier'))
          : panierProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : panierProvider.items.isEmpty
                  ? const Center(child: Text('Votre panier est vide'))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: panierProvider.items.length,
                            itemBuilder: (context, index) {
                              final item = panierProvider.items[index];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(item.article.title),
                                  subtitle: Text(
                                    '${item.quantity} x ${item.article.price.toStringAsFixed(2)} €',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => panierProvider.removeItem(item.id),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Total : ${panierProvider.total.toStringAsFixed(2)} €',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final achatProvider = context.read<AchatProvider>();
                                    final success = await achatProvider.validerAchat(
                                      panierProvider.total,
                                      panierProvider.items,
                                    );

                                    if (success) {
                                      await panierProvider.clearPanier();
                                    }

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Achat validé'
                                              : 'Erreur lors de la validation',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Valider le panier'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
