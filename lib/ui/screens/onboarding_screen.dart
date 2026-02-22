import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _dontShowAgain = true;

  Future<void> _continue() async {
    if (_dontShowAgain) {
      await context.read<OnboardingProvider>().setSeen(true);
    }
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(Icons.storefront, size: 72, color: cs.primary),
              const SizedBox(height: 16),
              Text(
                'Bienvenue sur Marketplace',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Achetez et vendez des articles entre particuliers. '
                'Recherchez, ajoutez aux favoris, gérez votre panier et validez vos achats.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _FeatureRow(
                icon: Icons.search,
                title: 'Recherche et filtres',
                subtitle: 'Trouvez des articles par titre, catégorie, prix.',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.favorite_border,
                title: 'Favoris persistants',
                subtitle: 'Ajoutez/retirez facilement et retrouvez-les plus tard.',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.shopping_cart_outlined,
                title: 'Panier et achats',
                subtitle: 'Ajoutez au panier, validez et consultez l’historique.',
              ),
              const Spacer(),
              CheckboxListTile(
                value: _dontShowAgain,
                onChanged: (v) => setState(() => _dontShowAgain = v ?? true),
                title: const Text('Ne plus afficher cet écran à l’ouverture'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _continue,
                  child: const Text('Commencer'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cs.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
