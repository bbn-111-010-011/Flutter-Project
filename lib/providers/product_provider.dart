import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../models/product.dart';
import '../models/category.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  ProductProvider(this._service);

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = false;
  String? _error;

  // Filters/search
  int? _categoryId;
  int? _priceMin;
  int? _priceMax;
  String _search = '';

  // Pagination (simple, optional)
  int _offset = 0;
  final int _limit = 30;
  bool _hasMore = true;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  int? get categoryId => _categoryId;
  int? get priceMin => _priceMin;
  int? get priceMax => _priceMax;
  String get search => _search;

  Future<void> loadCategories() async {
    try {
      final data = await _service.fetchCategories();
      _categories = data;
      notifyListeners();
    } catch (e) {
      // non-blocking
    }
  }

  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    _products = [];
    notifyListeners();
    await loadMore(reset: true);
  }

  Future<void> loadMore({bool reset = false}) async {
    if (_loading || !_hasMore) return;
    _setLoading(true);
    try {
      final data = await _service.fetchProducts(
        offset: _offset,
        limit: _limit,
        categoryId: _categoryId,
        priceMin: _priceMin,
        priceMax: _priceMax,
        title: _search.isNotEmpty ? _search : null,
      );
      if (reset) {
        _products = data;
      } else {
        _products = [..._products, ...data];
      }
      _hasMore = data.length >= _limit;
      if (_hasMore) _offset += _limit;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> applyFilters({
    int? categoryId,
    int? priceMin,
    int? priceMax,
    String? search,
  }) async {
    _categoryId = categoryId;
    _priceMin = priceMin;
    _priceMax = priceMax;
    _search = search ?? _search;
    await refresh();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void clearFilters() {
    _categoryId = null;
    _priceMin = null;
    _priceMax = null;
    _search = '';
    notifyListeners();
  }

  // Optional helper to fetch a single product by id
  Future<Product?> fetchProductById(int id) async {
    try {
      final p = await _service.fetchProduct(id);
      return p;
    } catch (_) {
      return null;
    }
  }

  // Create a new product (auth required at service level)
  Future<Product?> createProduct({
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required List<String> images,
  }) async {
    _setLoading(true);
    try {
      final created = await _service.createProduct(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        images: images,
      );
      // Refresh list to include the new item (best-effort)
      await refresh();
      return created;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
