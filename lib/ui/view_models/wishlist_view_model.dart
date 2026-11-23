import 'package:flutter/foundation.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../data/repositories/wishlist_repository.dart';

/// Manages customer wishlist items and toggle actions.
class WishlistViewModel extends ChangeNotifier {
  WishlistViewModel({required this._wishlistRepository});

  final WishlistRepository _wishlistRepository;

  final List<WishlistItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WishlistItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool isWishlisted(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  Future<void> loadWishlist() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _wishlistRepository.getWishlistItems();
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _items
        ..clear()
        ..addAll(res.data!);
    } else {
      _errorMessage = res.message;
    }
    notifyListeners();
  }

  Future<bool> toggleWishlist(String productId) async {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == productId);

    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      return removeWishlistItem(existing.id);
    }

    final res = await _wishlistRepository.addToWishlist(productId);
    if (res.isSuccess) {
      await loadWishlist();
      return true;
    }

    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> removeWishlistItem(String wishlistItemId) async {
    final idx = _items.indexWhere((e) => e.id == wishlistItemId);
    if (idx == -1) return false;
    final removed = _items.removeAt(idx);
    notifyListeners();

    final res = await _wishlistRepository.deleteWishlistItem(wishlistItemId);
    if (!res.isSuccess) {
      _items.insert(idx, removed);
      _errorMessage = res.message;
      notifyListeners();
      return false;
    }
    return true;
  }

  void clearLocal() {
    _items.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
