# PROJET 2TSSL — Application Flutter Marketplace

## Étudiants

À compléter : nom et prénom des étudiants du groupe.

Projet de fin d'année Flutter réalisé avec une logique proche du **TD6 SérieListe** : séparation en couches, `Provider / ChangeNotifier`, services, persistance locale, injection de dépendances et tests.

## Objectif

L'application permet de consulter, rechercher, mettre en favori, ajouter au panier et acheter fictivement des articles issus de l'API **Platzi Fake Store**.

## Fonctionnalités développées

| Fonctionnalité | Statut | Détail |
|---|---:|---|
| Consultation des articles | ✅ | Liste de produits via API + catalogue local de secours |
| Favoris | ✅ | Ajout/retrait depuis la liste et la fiche détail |
| Persistance favoris | ✅ | `SharedPreferences`, liste JSON de produits complets |
| Panier | ✅ | Ajout, retrait, quantité, total |
| Persistance panier | ✅ | `sqflite`, table locale `cart_items`, panier séparé par utilisateur |
| Validation panier | ✅ | Simulation d'achat, création d'une commande, vidage du panier |
| Historique achats | ✅ | `Supabase`, table distante `orders`, visible dans le dashboard Supabase |
| Authentification | ✅ | Connexion, création de compte, sauvegarde token/utilisateur |
| Accès panier sécurisé | ✅ | Connexion obligatoire pour panier, commandes, création produit |
| Écran d'accueil | ✅ | Présentation + case “ne plus afficher” |
| Proposer un article | ✅ | Formulaire avec validations avant appel API |
| Recherche et filtres | ✅ | Recherche titre, filtre catégorie, prix min/max |
| Navigation | ✅ | `go_router`, barre de navigation desktop/mobile, bouton quitter |
| Tests | ✅ | 1 test widget + 1 test d’intégration simples |

## Choix de persistance par fonctionnalité

| Élément | Persistance choisie | Pourquoi |
|---|---|---|
| Écran d'accueil déjà vu | `SharedPreferences` | Booléen simple `true/false`, donc clé/valeur suffit. |
| Token de connexion | `SharedPreferences` | Texte simple à relire au lancement. |
| Utilisateur connecté | `SharedPreferences` | Petit objet JSON, peu de volume. |
| Favoris | `SharedPreferences` | Liste simple de produits favoris, même logique que les favoris du TD6. |
| Panier | `sqflite` | Données structurées : utilisateur, produit, prix, quantité. Plus propre pour modifier les quantités. |
| Historique achats | `Supabase` | Historique distant : après validation du panier, la commande est insérée dans la table `orders`. |
| Produits API | API + catalogue local de secours | Les produits viennent de l'API Platzi, non sauvegardés en base. |
| Recherche/filtres | Mémoire uniquement | Données temporaires de l'écran. |

## Architecture

```text
lib/
├── core/                 # constantes globales, config Supabase, setup SQLite
├── models/               # Product, Category, CartItem, Order, AppUser
├── services/             # ApiClient, AuthService, ProductService, OrderService Supabase
├── repositories/         # LocalStorage, CartStorage sqflite, AuthRepository
├── providers/            # ChangeNotifier : Product, Favorites, Cart, Auth, Orders...
├── router/               # go_router + guards auth/onboarding
└── ui/
    ├── screens/          # écrans de l'application
    └── widgets/          # composants réutilisables
```

## Logique reprise du TD6

### Provider / ChangeNotifier

Chaque fonctionnalité importante possède son provider :

- `ProductProvider` : catalogue, recherche, filtres, création produit.
- `FavoritesProvider` : état des favoris + sauvegarde locale.
- `CartProvider` : état du panier + sauvegarde SQLite par utilisateur.
- `OrdersProvider` : historique d'achats + envoi/lecture des commandes Supabase.
- `AuthProvider` : connexion, inscription, déconnexion.
- `OnboardingProvider` : affichage de l'écran d'accueil.

L'interface utilise `context.watch`, `context.read`, `Consumer` ou `context.select` selon le besoin, comme dans le TD6.

### Persistance locale

- `LocalStorage` utilise `SharedPreferences` pour les données simples.
- `CartStorage` utilise `sqflite` pour le panier local.
- `SupabaseOrderService` envoie les achats validés dans Supabase.
- Sur Windows/macOS/Linux, `sqflite_common_ffi` est initialisé via `core/sqlite_setup.dart` pour permettre l'exécution desktop.

### Injection de dépendances

Les services et repositories sont créés dans `main.dart`, puis injectés dans les providers avec `MultiProvider`. Cette organisation rend les providers testables avec des mocks, comme dans le TD6.

## Packages utilisés

- `provider` : gestion d'état.
- `go_router` : navigation et guards.
- `http` : appels API.
- `shared_preferences` : persistance clé/valeur.
- `sqflite` : base SQLite locale.
- `sqflite_common_ffi` : compatibilité SQLite sur Windows/macOS/Linux.
- `cached_network_image` : affichage des images réseau.
- `intl` : formatage des dates.
- `supabase_flutter` : historique des achats distant.
- `mocktail` : mocks pour les tests.
- `integration_test` : test de parcours applicatif.

## Lancer le projet

```bash
flutter clean
flutter pub get
flutter run
```

Sur Windows :

```bash
flutter run -d windows
```

## Lancer les tests

```bash
flutter test
```

Pour vérifier la qualité du code :

```bash
flutter analyze
```

## Comptes de test

L'écran de connexion contient par défaut les identifiants de démonstration de l'API Platzi :

```text
Email : john@mail.com
Mot de passe : changeme
```

## Remarques importantes

- Les achats restent fictifs : aucune transaction réelle n'est effectuée, mais chaque panier validé est envoyé dans Supabase.
- La création de produit passe par l'API Platzi. Les données peuvent être temporaires selon le comportement de l'API.
- Les images de l'API Platzi peuvent parfois ne pas correspondre parfaitement aux titres, car c'est une API de démonstration.
- Les favoris sauvegardent les produits complets dans `SharedPreferences`, ce qui évite d'avoir une page Favoris vide après redémarrage si la liste API n'est pas encore chargée.

---

## Documentation complète ajoutée

Une documentation détaillée est disponible dans :

- `DOCUMENTATION_COMPLETE.md`
- `docs/01_STRUCTURE_PROJET.md`
- `docs/02_PERSISTANCE.md`
- `docs/03_FLUX_FONCTIONNELS.md`
- `docs/04_GUIDE_FICHIER_PAR_FICHIER.md`
- `docs/05_EXPLICATION_CODE_PAR_COUCHE.md`
- `docs/06_COMMANDES_ET_DEBUG.md`

Ces fichiers expliquent l’architecture, le rôle de chaque dossier, le rôle de chaque fichier, la persistance utilisée, les flux fonctionnels et les commandes de lancement/debug.


## Supabase

La configuration Supabase est centralisée dans :

```text
lib/core/app_config.dart
```

Le script SQL de création de la table est disponible dans :

```text
SUPABASE_SQL.md
```

Après validation du panier, l’historique est visible dans Supabase :

```text
Table Editor → public → orders
```
