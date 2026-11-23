import 'package:flutter/foundation.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';

/// Manages shopping cart items, quantity updates, and total price calculation.
class CartViewModel extends ChangeNotifier {
  CartViewModel({required this._cartRepository});

  final CartRepository _cartRepository;

  final List<CartItemModel> _items = [];
  bool _isLoading = false;
  bool _isMutating = false;
  String? _errorMessage;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isMutating => _isMutating;
  String? get errorMessage => _errorMessage;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _cartRepository.getCartItems();
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

  Future<bool> addToCart({
    required String productId,
    int quantity = 1,
    String? color,
    String? size,
  }) async {
    _isMutating = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _cartRepository.addToCart(
      productId: productId,
      quantity: quantity,
      color: color,
      size: size,
    );
    _isMutating = false;

    if (res.isSuccess) {
      await loadCart();
      return true;
    }

    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    if (newQuantity < 1) return false;
    final idx = _items.indexWhere((e) => e.id == cartItemId);
    if (idx == -1) return false;

    final previous = _items[idx];
    _items[idx] = previous.copyWith(quantity: newQuantity);
    notifyListeners();

    final res = await _cartRepository.updateCartItem(
      cartItemId: cartItemId,
      quantity: newQuantity,
    );

    if (!res.isSuccess) {
      _items[idx] = previous;
      _errorMessage = res.message;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> removeItem(String cartItemId) async {
    final idx = _items.indexWhere((e) => e.id == cartItemId);
    if (idx == -1) return false;
    final removed = _items.removeAt(idx);
    notifyListeners();

    final res = await _cartRepository.deleteCartItem(cartItemId);
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
