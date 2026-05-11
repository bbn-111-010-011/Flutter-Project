import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/achat_provider.dart';
import '../providers/auth_provider.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AchatProvider>().loadAchats());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final achatProvider = context.watch<AchatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des achats')),
      body: !authProvider.isLoggedIn
          ? const Center(child: Text('Connectez-vous pour voir l’historique'))
          : achatProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : achatProvider.achats.isEmpty
                  ? const Center(child: Text('Aucun achat pour le moment'))
                  : ListView.builder(
                      itemCount: achatProvider.achats.length,
                      itemBuilder: (context, index) {
                        final achat = achatProvider.achats[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text('Achat du ${achat.date.day}/${achat.date.month}/${achat.date.year}'),
                            subtitle: Text('${achat.articles.length} article(s)'),
                            trailing: Text('${achat.total.toStringAsFixed(2)} €'),
                          ),
                        );
                      },
                    ),
    );
  }
}
