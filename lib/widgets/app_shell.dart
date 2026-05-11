import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  int _getIndex(String location) {
    if (location.startsWith('/favoris')) return 1;
    if (location.startsWith('/panier')) return 2;
    if (location.startsWith('/historique')) return 3;
    if (location.startsWith('/compte')) return 4;
    return 0;
  }

  void _goToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/articles');
        break;
      case 1:
        context.go('/favoris');
        break;
      case 2:
        context.go('/panier');
        break;
      case 3:
        context.go('/historique');
        break;
      case 4:
        context.go('/compte');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getIndex(location),
        onTap: (index) => _goToPage(context, index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Articles'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Achats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }
}
