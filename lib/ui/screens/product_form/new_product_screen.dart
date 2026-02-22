import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/product_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/category.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _form = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _imagesCtrl = TextEditingController(text: 'https://picsum.photos/400');

  int? _categoryId;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProductProvider>();
    if (p.categories.isEmpty) {
      p.loadCategories();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imagesCtrl.dispose();
    super.dispose();
  }

  List<String> _parseImages(String raw) {
    // Accept comma or newline separated URLs, trim empties
    return raw
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté')),
        );
        context.go('/login');
      }
      return;
    }

    if (!_form.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.trim().replaceAll(',', '.')) ?? -1;
    final catId = _categoryId;
    final images = _parseImages(_imagesCtrl.text);

    if (price < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Prix invalide')));
      return;
    }
    if (catId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choisissez une catégorie')));
      return;
    }
    if (images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ajoutez au moins une image (URL)')));
      return;
    }

    setState(() => _submitting = true);
    try {
      final created = await context.read<ProductProvider>().createProduct(
            title: title,
            description: desc,
            price: price,
            categoryId: catId,
            images: images,
          );
      if (!mounted) return;
      if (created != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Produit créé')));
        context.go('/product/${created.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de la création du produit')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau produit')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Titre requis';
                  if (v.trim().length < 3) return 'Au moins 3 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Description requise';
                  if (v.trim().length < 5) return 'Au moins 5 caractères';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Prix (€)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Prix requis';
                  final p = double.tryParse(v.replaceAll(',', '.'));
                  if (p == null || p < 0) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _categoryId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: [
                  ...categories.map(
                    (Category c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Catégorie requise' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imagesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Images (URLs, séparées par virgule ou nouvelle ligne)',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Au moins une image';
                  }
                  final list = _parseImages(v);
                  if (list.isEmpty) return 'Au moins une image valide';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.save),
                label: Text(_submitting ? 'Création...' : 'Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
