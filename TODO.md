# Flutter Marketplace App — TODO

This checklist tracks the implementation of the peer-to-peer marketplace app using Flutter, Platzi Fake Store API, go_router, Provider, and SharedPreferences.

## 1) Dependencies and Setup
- [x] Update pubspec.yaml dependencies:
  - [x] http
  - [x] provider
  - [x] shared_preferences
  - [x] go_router
  - [x] cached_network_image
  - [x] intl
- [x] Run `flutter pub get`

## 2) Core and Models
- [x] lib/core/constants.dart
  - [x] API base URL (https://api.escuelajs.co/api/v1)
  - [x] SharedPreferences keys (onboarding, token, user, favorites, cart, orders)
- [x] lib/models/
  - [x] product.dart
  - [x] category.dart
  - [x] user.dart
  - [x] cart_item.dart
  - [x] order.dart

## 3) Services (HTTP and API)
- [x] lib/services/api_client.dart
  - [x] Base client with baseUrl, JSON decoding, auth header, error handling
- [x] lib/services/auth_service.dart
  - [x] login, register, getProfile
- [x] lib/services/product_service.dart
  - [x] fetchProducts, fetchProductDetail, fetchCategories, createProduct

## 4) Repositories (Persistence and Orchestration)
- [x] lib/repositories/local_storage.dart (SharedPreferences wrapper)
  - [x] onboarding seen flag
  - [x] token
  - [x] user (profile)
  - [x] favorites (by product id)
  - [x] cart (per user)
  - [x] orders (per user)
- [x] lib/repositories/auth_repository.dart
  - [x] save/clear token and user
- [ ] lib/repositories/product_repository.dart
  - [ ] combine services + local caching if needed

## 5) Providers (State Management with Provider)
- [x] lib/providers/onboarding_provider.dart
  - [x] get/set seen flag
- [x] lib/providers/auth_provider.dart
  - [x] login/register/logout, current user/token
- [x] lib/providers/product_provider.dart
  - [x] product list, detail, loading states, categories, filters, search text
- [x] lib/providers/favorites_provider.dart
  - [x] toggle favorite, hydrate/persist
- [x] lib/providers/cart_provider.dart
  - [x] add/remove/update qty; guard add with auth; hydrate/persist per user
- [x] lib/providers/orders_provider.dart
  - [x] list of orders; add order on checkout; persist per user

## 6) Routing and App Bootstrap
- [x] lib/router/app_router.dart (go_router)
  - [x] routes: onboarding, login, register, home shell, product detail, favorites, cart, profile, orders, new product
  - [x] redirect unauthenticated users for cart actions and new product
  - [x] initial route depends on onboarding seen flag
- [x] Replace lib/main.dart
  - [x] MultiProvider setup
  - [x] Initialize router
  - [x] App Theme

## 7) UI — Screens
- [x] lib/ui/screens/onboarding_screen.dart
  - [x] Intro + "Ne plus afficher" checkbox + Continue
- [x] lib/ui/screens/auth/login_screen.dart
- [x] lib/ui/screens/auth/register_screen.dart
- [x] lib/ui/screens/home/home_shell.dart
  - [x] BottomNavigationBar: Produits, Favoris, Panier, Profil
- [x] lib/ui/screens/products/products_screen.dart (list/grid + search)
- [x] lib/ui/screens/products/product_detail_screen.dart
- [x] lib/ui/screens/favorites/favorites_screen.dart
- [x] lib/ui/screens/cart/cart_screen.dart
  - [x] Validate cart (simulate purchase) → adds order and clears cart
- [x] lib/ui/screens/orders/orders_screen.dart
- [x] lib/ui/screens/profile/profile_screen.dart
- [x] lib/ui/screens/product_form/new_product_screen.dart
  - [x] Form with field validation

## 8) UI — Widgets
- [x] lib/ui/widgets/product_tile.dart
  - [x] favorite toggle
  - [x] add-to-cart button (auth required)
- [ ] lib/ui/widgets/price_chip.dart
- [ ] lib/ui/widgets/qty_stepper.dart
- [ ] lib/ui/widgets/empty_state.dart
- [ ] lib/ui/widgets/search/search_delegate.dart
  - [ ] Integrate filters (category, price range) + text search

## 9) Features Integration
- [x] Product listing via API (http)
- [x] Product details screen
- [x] Favorites add/remove from list and detail
- [x] Cart add/remove/update from list and detail
- [x] Persist favorites and cart across restarts (per user where relevant)
- [x] Auth required for cart and checkout
- [x] Onboarding only first time (checkbox: do not show again)
- [x] Checkout creates order with date, price, items
- [x] Orders history screen
- [x] New product form with client-side validation
- [x] Search + filters (categories, price range)
- [x] Navigation guards with go_router

## 10) Persistence Strategy
- [x] SharedPreferences keys and data shapes
- [x] Migrations or default initializations

## 11) QA Checklist
- [ ] Onboarding skip works and persists
- [ ] Login/Register flows work; token saved; profile loaded
- [ ] Add to favorites from tile and detail; persists
- [ ] Add to cart requires login; persists
- [ ] Checkout simulates purchase; creates order and clears cart
- [ ] Orders history correct with totals and dates (intl)
- [ ] New product form validation and submission
- [ ] Search and filters update list correctly
- [ ] Deep links/navigation work and guard unauth routes

## 12) Stretch Goals
- [ ] Switch API to Supabase or Firebase for full realism (users, products, cart, images)
- [ ] Image upload for new products
- [ ] Replace http with Dio/Retrofit
- [ ] Unit and widget tests
