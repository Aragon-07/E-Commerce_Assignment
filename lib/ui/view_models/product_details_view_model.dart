import 'package:flutter/foundation.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/catalog_repository.dart';

/// Manages single product details, selected variant options, and quantity.
class ProductDetailsViewModel extends ChangeNotifier {
  ProductDetailsViewModel({
    required this._catalogRepository,
    required ProductModel initialProduct,
  })  : _product = initialProduct {
    _initDefaults();
  }

  final CatalogRepository _catalogRepository;

  ProductModel _product;
  bool _isLoading = false;
  String? _selectedColor;
  String? _selectedSize;
  int _quantity = 1;

  ProductModel get product => _product;
  bool get isLoading => _isLoading;
  String? get selectedColor => _selectedColor;
  String? get selectedSize => _selectedSize;
  int get quantity => _quantity;

  void _initDefaults() {
    if (_product.colors.isNotEmpty && _selectedColor == null) {
      _selectedColor = _product.colors.first;
    }
    if (_product.sizes.isNotEmpty && _selectedSize == null) {
      _selectedSize = _product.sizes.first;
    }
  }

  Future<void> fetchLatestDetails() async {
    if (_product.id.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    final res = await _catalogRepository.getProductById(_product.id);
    _isLoading = false;
    if (res.isSuccess && res.data != null) {
      _product = res.data!;
      _initDefaults();
    }
    notifyListeners();
  }

  void selectColor(String color) {
    _selectedColor = color;
    notifyListeners();
  }

  void selectSize(String size) {
    _selectedSize = size;
    notifyListeners();
  }

  void incrementQuantity() {
    if (_quantity < 99) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }
}
