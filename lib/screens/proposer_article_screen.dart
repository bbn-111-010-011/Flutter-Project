import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/auth_provider.dart';
import '../providers/article_provider.dart';
import '../services/supabase_service.dart';

class ProposerArticleScreen extends StatefulWidget {
  const ProposerArticleScreen({super.key});

  @override
  State<ProposerArticleScreen> createState() => _ProposerArticleScreenState();
}

class _ProposerArticleScreenState extends State<ProposerArticleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final article = Article(
      id: '',
      title: _titleController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      imageUrl: _imageController.text.trim(),
      fromSupabase: true,
    );

    try {
      await SupabaseService().proposerArticle(article);
      if (!mounted) return;

      await context.read<ArticleProvider>().loadArticles();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article proposé avec succès')),
      );
      context.go('/articles');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Proposer un article')),
      body: !authProvider.isLoggedIn
          ? const Center(child: Text('Vous devez être connecté pour proposer un article'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Titre obligatoire' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Prix obligatoire';
                        if (double.tryParse(value) == null) return 'Prix invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Catégorie obligatoire' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'URL image',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Description obligatoire' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage.isNotEmpty)
                      Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Enregistrer l’article'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
