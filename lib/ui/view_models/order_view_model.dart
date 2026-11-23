import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

/// Manages customer order placement, listing, and cancellation.
class OrderViewModel extends ChangeNotifier {
  OrderViewModel({required this._orderRepository});

  final OrderRepository _orderRepository;

  final List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _orderRepository.getOrders();
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _orders
        ..clear()
        ..addAll(res.data!);
    } else {
      _errorMessage = res.message;
    }
    notifyListeners();
  }

  Future<OrderModel?> createOrder({
    required String paymentMethod,
    required ShippingAddress shippingAddress,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _orderRepository.createOrder(
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
    );
    _isSubmitting = false;

    if (res.isSuccess) {
      await loadOrders();
      return res.data;
    }

    _errorMessage = res.message;
    notifyListeners();
    return null;
  }

  Future<bool> cancelOrder(String orderId) async {
    final res = await _orderRepository.cancelOrder(orderId);
    if (res.isSuccess) {
      await loadOrders();
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
