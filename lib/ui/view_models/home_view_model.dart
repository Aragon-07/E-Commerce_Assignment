import 'package:flutter/foundation.dart';
import '../../core/constants/api_urls.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/slide_model.dart';
import '../../data/repositories/catalog_repository.dart';

/// Loads and manages home screen slides, categories, and Popular/Special/New product shelves.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this._catalogRepository});

  final CatalogRepository _catalogRepository;

  List<SlideModel> _slides = const [];
  List<CategoryModel> _categories = const [];
  List<ProductModel> _popularProducts = const [];
  List<ProductModel> _specialProducts = const [];
  List<ProductModel> _newProducts = const [];

  bool _isLoading = false;
  String? _errorMessage;

  List<SlideModel> get slides => _slides;
  List<CategoryModel> get categories => _categories;
  List<ProductModel> get popularProducts => _popularProducts;
  List<ProductModel> get specialProducts => _specialProducts;
  List<ProductModel> get newProducts => _newProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _catalogRepository.getSlides(),
        _catalogRepository.getCategories(page: 1, count: 10),
        _loadPopular(),
        _loadSpecial(),
        _loadNew(),
      ]);

      final slidesRes = results[0] as dynamic;
      if (slidesRes.isSuccess && slidesRes.data != null) {
        _slides = slidesRes.data as List<SlideModel>;
      }

      final catRes = results[1] as dynamic;
      if (catRes.isSuccess && catRes.data != null) {
        _categories = (catRes.data.results as List<CategoryModel>);
      }

      _popularProducts = results[2] as List<ProductModel>;
      _specialProducts = results[3] as List<ProductModel>;
      _newProducts = results[4] as List<ProductModel>;

      if (_slides.isEmpty &&
          _categories.isEmpty &&
          _popularProducts.isEmpty &&
          _specialProducts.isEmpty &&
          _newProducts.isEmpty) {
        _errorMessage = 'Unable to load store items. Pull down to retry.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ProductModel>> _loadPopular() async {
    final byCat = await _catalogRepository.getProducts(
      categoryId: ApiUrls.popularCategoryId,
      count: 10,
    );
    if (byCat.isSuccess &&
        byCat.data != null &&
        byCat.data!.results.isNotEmpty) {
      return byCat.data!.results;
    }
    final fallback = await _catalogRepository.getProducts(page: 1, count: 10);
    return fallback.data?.results ?? const [];
  }

  Future<List<ProductModel>> _loadSpecial() async {
    final byCat = await _catalogRepository.getProducts(
      categoryId: ApiUrls.specialCategoryId,
      count: 10,
    );
    if (byCat.isSuccess &&
        byCat.data != null &&
        byCat.data!.results.isNotEmpty) {
      return byCat.data!.results;
    }
    final fallback = await _catalogRepository.getProducts(page: 2, count: 10);
    return fallback.data?.results ?? const [];
  }

  Future<List<ProductModel>> _loadNew() async {
    final byTag = await _catalogRepository.getProducts(tag: 'new', count: 10);
    if (byTag.isSuccess &&
        byTag.data != null &&
        byTag.data!.results.isNotEmpty) {
      return byTag.data!.results;
    }
    final byCat = await _catalogRepository.getProducts(
      categoryId: ApiUrls.newArrivalCategoryId,
      count: 10,
    );
    if (byCat.isSuccess &&
        byCat.data != null &&
        byCat.data!.results.isNotEmpty) {
      return byCat.data!.results;
    }
    final fallback = await _catalogRepository.getProducts(page: 3, count: 10);
    return fallback.data?.results ?? const [];
  }
}
