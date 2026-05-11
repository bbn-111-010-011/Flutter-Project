import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/article.dart';
import '../models/cart_item.dart';
import '../models/achat.dart';

class SupabaseService {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!isConfigured) return;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  User? get currentUser {
    if (!isConfigured) return null;
    return client.auth.currentUser;
  }

  String? get currentUserId => currentUser?.id;

  Future<void> signUp(String email, String password) async {
    if (!isConfigured) throw Exception('Supabase n’est pas configuré');
    await client.auth.signUp(email: email, password: password);
  }

  Future<void> signIn(String email, String password) async {
    if (!isConfigured) throw Exception('Supabase n’est pas configuré');
    await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    if (!isConfigured) return;
    await client.auth.signOut();
  }

  Future<List<Article>> getArticlesProposes() async {
    if (!isConfigured) return [];

    final response = await client
        .from('articles_proposes')
        .select()
        .order('created_at', ascending: false);

    return response.map<Article>((item) => Article.fromSupabase(item)).toList();
  }

  Future<void> proposerArticle(Article article) async {
    if (!isConfigured) throw Exception('Supabase n’est pas configuré');
    final userId = currentUserId;
    if (userId == null) throw Exception('Vous devez être connecté');

    await client.from('articles_proposes').insert(article.toSupabaseJson(userId));
  }

  Future<List<CartItem>> getPanier() async {
    if (!isConfigured) return [];
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('panier')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map<CartItem>((item) => CartItem.fromSupabase(item)).toList();
  }

  Future<void> addToPanier(Article article) async {
    if (!isConfigured) throw Exception('Supabase n’est pas configuré');
    final userId = currentUserId;
    if (userId == null) throw Exception('Vous devez être connecté');

    await client.from('panier').insert({
      'user_id': userId,
      'article_id': article.id,
      'title': article.title,
      'price': article.price,
      'description': article.description,
      'category': article.category,
      'image_url': article.imageUrl,
      'from_supabase': article.fromSupabase,
      'quantity': 1,
    });
  }

  Future<void> removeFromPanier(String cartItemId) async {
    if (!isConfigured) return;
    await client.from('panier').delete().eq('id', cartItemId);
  }

  Future<void> clearPanier() async {
    if (!isConfigured) return;
    final userId = currentUserId;
    if (userId == null) return;

    await client.from('panier').delete().eq('user_id', userId);
  }

  Future<void> createAchat(double total, List<CartItem> items) async {
    if (!isConfigured) throw Exception('Supabase n’est pas configuré');
    final userId = currentUserId;
    if (userId == null) throw Exception('Vous devez être connecté');

    await client.from('achats').insert({
      'user_id': userId,
      'total': total,
      'articles': items.map((item) => item.toSimpleJson()).toList(),
    });
  }

  Future<List<Achat>> getAchats() async {
    if (!isConfigured) return [];
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await client
        .from('achats')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map<Achat>((item) => Achat.fromSupabase(item)).toList();
  }
}
