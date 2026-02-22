import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';

// Screens
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/products/products_screen.dart';
import '../ui/screens/favorites/favorites_screen.dart';
import '../ui/screens/cart/cart_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/orders/orders_screen.dart';
import '../ui/screens/products/product_detail_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/product_form/new_product_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.onboarding, this.auth) {
    onboarding.addListener(_notify);
    auth.addListener(_notify);
  }

  final OnboardingProvider onboarding;
  final AuthProvider auth;

  bool get onboardingSeen => onboarding.seen;
  bool get isAuthenticated => auth.isAuthenticated;

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.uri.path;

    if (!onboardingSeen && loc != '/onboarding') {
      return '/onboarding';
    }
    final authOnly = <String>{
      '/cart',
      '/orders',
      '/new-product',
    };
    if (!isAuthenticated && authOnly.contains(loc)) {
      return '/login';
    }

    return null;
  }

  void _notify() => notifyListeners();

  @override
  void dispose() {
    onboarding.removeListener(_notify);
    auth.removeListener(_notify);
    super.dispose();
  }
}

class AppRouter {
  AppRouter({
    required RouterNotifier notifier,
  }) {
    _router = GoRouter(
      initialLocation: notifier.onboardingSeen ? '/home' : '/onboarding',
      refreshListenable: notifier,
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => _HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const ProductsScreen(),
            ),
            GoRoute(
              path: '/favorites',
              name: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: '/cart',
              name: 'cart',
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/product/:id',
          name: 'product',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return ProductDetailScreen(productId: id);
          },
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: '/new-product',
          name: 'new-product',
          builder: (context, state) => const NewProductScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
      redirect: notifier.redirect,
    );
  }

  late final GoRouter _router;
  GoRouter get router => _router;
}

// -------------------- Placeholders (remplacés par de vrais écrans ensuite) --------------------

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.child});
  final Widget child;

  int _currentIndexForLocation(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/favorites')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0; // /home
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/cart');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndexForLocation(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _ScaffoldPlaceholder extends StatelessWidget {
  const _ScaffoldPlaceholder({required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: trailing != null ? [trailing!] : null),
      body: Center(
        child: Text(
          '$title (placeholder)',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class _OnboardingPlaceholder extends StatelessWidget {
  const _OnboardingPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Onboarding');
}

class _ProductsPlaceholder extends StatelessWidget {
  const _ProductsPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Produits');
}

class _FavoritesPlaceholder extends StatelessWidget {
  const _FavoritesPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Favoris');
}

class _CartPlaceholder extends StatelessWidget {
  const _CartPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Panier');
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Profil');
}

class _OrdersPlaceholder extends StatelessWidget {
  const _OrdersPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Historique achats');
}

class _NewProductPlaceholder extends StatelessWidget {
  const _NewProductPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Nouveau produit');
}

class _LoginPlaceholder extends StatelessWidget {
  const _LoginPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Connexion');
}

class _RegisterPlaceholder extends StatelessWidget {
  const _RegisterPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const _ScaffoldPlaceholder(title: 'Création de compte');
}

class _ProductDetailPlaceholder extends StatelessWidget {
  const _ProductDetailPlaceholder({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return _ScaffoldPlaceholder(
      title: 'Produit #$id',
      trailing: IconButton(
        icon: const Icon(Icons.open_in_new),
        onPressed: () => context.go('/home'),
      ),
    );
  }
}
