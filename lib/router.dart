import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/article.dart';
import 'providers/article_provider.dart';
import 'screens/home_screen.dart';
import 'screens/articles_screen.dart';
import 'screens/article_detail_screen.dart';
import 'screens/favoris_screen.dart';
import 'screens/panier_screen.dart';
import 'screens/historique_screen.dart';
import 'screens/compte_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/proposer_article_screen.dart';
import 'widgets/app_shell.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/articles',
          builder: (context, state) => const ArticlesScreen(),
        ),
        GoRoute(
          path: '/favoris',
          builder: (context, state) => const FavorisScreen(),
        ),
        GoRoute(
          path: '/panier',
          builder: (context, state) => const PanierScreen(),
        ),
        GoRoute(
          path: '/historique',
          builder: (context, state) => const HistoriqueScreen(),
        ),
        GoRoute(
          path: '/compte',
          builder: (context, state) => const CompteScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/article/:id',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is Article) {
          return ArticleDetailScreen(article: extra);
        }

        final id = state.pathParameters['id'] ?? '';
        final article = context.read<ArticleProvider>().findById(id);

        if (article == null) {
          return const Scaffold(
            body: Center(child: Text('Article introuvable')),
          );
        }

        return ArticleDetailScreen(article: article);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/proposer',
      builder: (context, state) => const ProposerArticleScreen(),
    ),
  ],
);
