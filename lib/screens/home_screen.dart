import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = context.watch<OnboardingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store, size: 80),
            const SizedBox(height: 24),
            Text(
              'Bienvenue sur Marketplace Articles',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Cette application permet de consulter des articles, ajouter des favoris, gérer un panier et proposer des articles.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CheckboxListTile(
              title: const Text('Ne plus afficher cet écran'),
              value: onboardingProvider.hideHomeScreen,
              onChanged: (value) {
                onboardingProvider.setHideHomeScreen(value ?? false);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/articles'),
              child: const Text('Entrer dans l’application'),
            ),
          ],
        ),
      ),
    );
  }
}
