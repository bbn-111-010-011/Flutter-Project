import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/article_provider.dart';
import '../widgets/article_card.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<ArticleProvider>().loadArticles();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleProvider = context.watch<ArticleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => articleProvider.loadArticles(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/proposer'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Rechercher un article',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: articleProvider.setSearchText,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: articleProvider.selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'Toutes', child: Text('Toutes')),
                          ...articleProvider.categories.map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) articleProvider.setCategory(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _minPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix min',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: articleProvider.setMinPrice,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _maxPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix max',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: articleProvider.setMaxPrice,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    _minPriceController.clear();
                    _maxPriceController.clear();
                    articleProvider.clearFilters();
                  },
                  child: const Text('Réinitialiser les filtres'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (articleProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (articleProvider.errorMessage.isNotEmpty) {
                  return Center(child: Text(articleProvider.errorMessage));
                }

                final articles = articleProvider.filteredArticles;

                if (articles.isEmpty) {
                  return const Center(child: Text('Aucun article trouvé'));
                }

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    return ArticleCard(article: articles[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
