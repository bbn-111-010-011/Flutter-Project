import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class CompteScreen extends StatelessWidget {
  const CompteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Compte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!authProvider.supabaseReady)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Supabase n’est pas encore configuré. Lancez l’application avec SUPABASE_URL et SUPABASE_ANON_KEY.',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (authProvider.isLoggedIn) ...[
              Text('Connecté : ${authProvider.userEmail}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                },
                child: const Text('Se déconnecter'),
              ),
            ] else ...[
              const Text('Vous n’êtes pas connecté.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Connexion'),
              ),
              OutlinedButton(
                onPressed: () => context.push('/register'),
                child: const Text('Créer un compte'),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.push('/proposer'),
              icon: const Icon(Icons.add),
              label: const Text('Proposer un article'),
            ),
          ],
        ),
      ),
    );
  }
}
