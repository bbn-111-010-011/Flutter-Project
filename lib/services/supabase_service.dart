import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/article.dart';
import '../models/cart_item.dart';
import '../models/achat.dart';
import 'supabase_config.dart';

class SupabaseService {
  static bool get isConfigured {
    return SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty;
      // =========================================================
  // PANIER - SUPABASE
  // Table : panier
  // =========================================================

  Future<List<CartItem>> getPanier() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await Supabase.instance.client
        .from('panier')
        .select()
        .eq('utilisateur_id', user.id)
        .order('date_creation', ascending: false);

    return response.map<CartItem>((item) {
      return CartItem.fromSupabase({
        'id': item['id'],
        'article_id': item['article_id'],
        'title': item['titre'],
        'price': item['prix'],
        'description': item['description'],
        'category': item['categorie'],
        'image_url': item['image'],
        'from_supabase': item['depuis_supabase'],
        'quantity': item['quantite'],
      });
    }).toList();
  }

  Future<void> addToPanier(Article article) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      throw Exception('Vous devez être connecté pour ajouter un article au panier.');
    }

    final existing = await Supabase.instance.client
        .from('panier')
        .select()
        .eq('utilisateur_id', user.id)
        .eq('article_id', article.id)
        .maybeSingle();

    if (existing != null) {
      final quantiteActuelle =
          int.tryParse(existing['quantite'].toString()) ?? 1;

      await Supabase.instance.client
          .from('panier')
          .update({
            'quantite': quantiteActuelle + 1,
          })
          .eq('id', existing['id']);
    } else {
      await Supabase.instance.client.from('panier').insert({
        'utilisateur_id': user.id,
        'article_id': article.id,
        'titre': article.title,
        'prix': article.price,
        'description': article.description,
        'categorie': article.category,
        'image': article.imageUrl,
        'depuis_supabase': article.fromSupabase,
        'quantite': 1,
      });
    }
  }

  Future<void> removeFromPanier(String cartItemId) async {
    await Supabase.instance.client
        .from('panier')
        .delete()
        .eq('id', cartItemId);
  }

  Future<void> clearPanier() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return;
    }

    await Supabase.instance.client
        .from('panier')
        .delete()
        .eq('utilisateur_id', user.id);
  }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  User? get currentUser {
    return client.auth.currentUser;
  }

  String? get currentUserId {
    return currentUser?.id;
  }

  // =========================================================
  // AUTHENTIFICATION
  // =========================================================

  Future<void> signUp(String email, String password) async {
    await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signIn(String email, String password) async {
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // =========================================================
  // ARTICLES PROPOSÉS
  // Table Supabase : articles_proposes
  // Colonnes françaises :
  // id, utilisateur_id, titre, prix, description, categorie, image, date_creation
  // =========================================================

  Future<List<Article>> getArticlesProposes() async {
    try {
      final response = await client
          .from('articles_proposes')
          .select()
          .order('date_creation', ascending: false);

      return response.map<Article>((item) {
        return Article(
          id: item['id'].toString(),
          title: item['titre']?.toString() ?? 'Sans titre',
          price: double.tryParse(item['prix'].toString()) ?? 0,
          description: item['description']?.toString() ?? '',
          category: item['categorie']?.toString() ?? 'Sans catégorie',
          imageUrl: item['image']?.toString() ?? '',
          fromSupabase: true,
        );
      }).toList();
    } catch (e) {
      // Si la table Supabase n'existe pas encore,
      // l'application garde quand même les articles de l'API Fake Platzi.
      return [];
    }
  }

  Future<void> proposerArticle(Article article) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Vous devez être connecté pour proposer un article.');
    }

    await client.from('articles_proposes').insert({
      'utilisateur_id': userId,
      'titre': article.title,
      'prix': article.price,
      'description': article.description,
      'categorie': article.category,
      'image': article.imageUrl,
    });
  }

  // =========================================================
  // PANIER
  // Table Supabase : panier
  // Colonnes françaises :
  // id, utilisateur_id, article_id, titre, prix, description,
  // categorie, image, depuis_supabase, quantite, date_creation
  // =========================================================

  Future<List<CartItem>> getPanier() async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    final response = await client
        .from('panier')
        .select()
        .eq('utilisateur_id', userId)
        .order('date_creation', ascending: false);

    return response.map<CartItem>((item) {
      return CartItem.fromSupabase({
        'id': item['id'],
        'article_id': item['article_id'],
        'title': item['titre'],
        'price': item['prix'],
        'description': item['description'],
        'category': item['categorie'],
        'image_url': item['image'],
        'from_supabase': item['depuis_supabase'],
        'quantity': item['quantite'],
      });
    }).toList();
  }

  Future<void> addToPanier(Article article) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Vous devez être connecté pour ajouter un article au panier.');
    }

    final existing = await client
        .from('panier')
        .select()
        .eq('utilisateur_id', userId)
        .eq('article_id', article.id)
        .maybeSingle();

    if (existing != null) {
      final quantiteActuelle =
          int.tryParse(existing['quantite'].toString()) ?? 1;

      await client.from('panier').update({
        'quantite': quantiteActuelle + 1,
      }).eq('id', existing['id']);
    } else {
      await client.from('panier').insert({
        'utilisateur_id': userId,
        'article_id': article.id,
        'titre': article.title,
        'prix': article.price,
        'description': article.description,
        'categorie': article.category,
        'image': article.imageUrl,
        'depuis_supabase': article.fromSupabase,
        'quantite': 1,
      });
    }
  }

  Future<void> removeFromPanier(String cartItemId) async {
    await client.from('panier').delete().eq('id', cartItemId);
  }

  Future<void> clearPanier() async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    await client.from('panier').delete().eq('utilisateur_id', userId);
  }

  // =========================================================
  // HISTORIQUE DES ACHATS
  // Table Supabase : achats
  // Colonnes françaises :
  // id, utilisateur_id, montant_total, articles, date_achat
  // =========================================================

  Future<void> createAchat(double total, List<CartItem> items) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('Vous devez être connecté pour valider un achat.');
    }

    await client.from('achats').insert({
      'utilisateur_id': userId,
      'montant_total': total,
      'articles': items.map((item) => item.toSimpleJson()).toList(),
    });
  }

  Future<List<Achat>> getAchats() async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    final response = await client
        .from('achats')
        .select()
        .eq('utilisateur_id', userId)
        .order('date_achat', ascending: false);

    return response.map<Achat>((item) {
      return Achat.fromSupabase({
        'id': item['id'],
        'created_at': item['date_achat'],
        'total': item['montant_total'],
        'articles': item['articles'],
      });
    }).toList();
  }

  // =========================================================
  // COMPATIBILITÉ ANCIENS NOMS
  // =========================================================

  Future<void> createPurchase(double total, List<CartItem> items) async {
    await createAchat(total, items);
  }

  Future<List<Achat>> getPurchases() async {
    return getAchats();
  }
}