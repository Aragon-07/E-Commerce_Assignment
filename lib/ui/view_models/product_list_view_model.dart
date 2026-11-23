import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/catalog_repository.dart';

/// Paginated product grid ViewModel supporting category, brand, tag, or search query filtering.
class ProductListViewModel extends ChangeNotifier {
  ProductListViewModel({
    required this._catalogRepository,
    this.categoryId,
    this.brandId,
    this.tag,
    this.searchQuery,
    this.fallbackPage,
  });

  final CatalogRepository _catalogRepository;
  final String? categoryId;
  final String? brandId;
  final String? tag;
  final String? searchQuery;
  final int? fallbackPage;

  final List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadProducts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final hasSearch = searchQuery != null && searchQuery!.trim().isNotEmpty;
    final res = await _catalogRepository.getProducts(
      page: 1,
      count: hasSearch ? 60 : 18,
      categoryId: categoryId,
      brandId: brandId,
      tag: tag,
    );

    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      var list = res.data!.results;
      if (list.isEmpty && fallbackPage != null) {
        final fb = await _catalogRepository.getProducts(
          page: fallbackPage!,
          count: 18,
        );
        if (fb.isSuccess && fb.data != null) {
          list = fb.data!.results;
          _hasMore = fb.data!.nextPage != null;
        }
      } else {
        _hasMore = !hasSearch && res.data!.nextPage != null;
      }

      if (hasSearch) {
        final q = searchQuery!.trim().toLowerCase();
        list = list
            .where((p) =>
                p.title.toLowerCase().contains(q) ||
                p.description.toLowerCase().contains(q))
            .toList();
      }

      _products
        ..clear()
        ..addAll(list);
      _currentPage = 1;
    } else {
      _errorMessage = res.message;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _currentPage + 1;
    final res = await _catalogRepository.getProducts(
      page: nextPage,
      count: 18,
      categoryId: categoryId,
      brandId: brandId,
      tag: tag,
    );
    _isLoadingMore = false;

    if (res.isSuccess && res.data != null) {
      _products.addAll(res.data!.results);
      _currentPage = nextPage;
      _hasMore = res.data!.nextPage != null;
    }
    notifyListeners();
  }
}
