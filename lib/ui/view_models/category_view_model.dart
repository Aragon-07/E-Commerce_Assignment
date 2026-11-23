import 'package:flutter/foundation.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/catalog_repository.dart';

/// Paginated categories list ViewModel for the Categories tab.
class CategoryViewModel extends ChangeNotifier {
  CategoryViewModel({required this._catalogRepository});

  final CatalogRepository _catalogRepository;

  final List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> loadCategories({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _catalogRepository.getCategories(page: 1, count: 24);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _categories
        ..clear()
        ..addAll(res.data!.results);
      _hasMore = res.data!.nextPage != null;
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
    final res =
        await _catalogRepository.getCategories(page: nextPage, count: 24);
    _isLoadingMore = false;

    if (res.isSuccess && res.data != null) {
      _categories.addAll(res.data!.results);
      _currentPage = nextPage;
      _hasMore = res.data!.nextPage != null;
    }
    notifyListeners();
  }
}
