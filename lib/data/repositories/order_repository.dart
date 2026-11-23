import '../../core/constants/api_urls.dart';
import '../models/api_response.dart';
import '../models/order_model.dart';
import '../services/api_client.dart';

/// Handles creating, listing, and cancelling customer orders (`/order`, `/orders`).
class OrderRepository {
  OrderRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<ApiResponse<List<OrderModel>>> getOrders() async {
    final response = await _apiClient.get(
      ApiUrls.orders,
      queryParams: {'count': 30},
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    final items = _parseList(response.data);
    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: items,
    );
  }

  Future<ApiResponse<OrderModel?>> createOrder({
    required String paymentMethod,
    required ShippingAddress shippingAddress,
    String redirectUrl = 'https://craftybay.app/payment-success',
  }) async {
    final response = await _apiClient.post(
      ApiUrls.createOrder,
      body: {
        'payment_method': paymentMethod,
        'shipping_address': shippingAddress.toJson(),
        'redirect_url': redirectUrl,
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    OrderModel? order;
    if (response.data is Map<String, dynamic>) {
      order = OrderModel.fromJson(response.data as Map<String, dynamic>);
    }
    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: order,
    );
  }

  Future<ApiResponse<void>> cancelOrder(String orderId) async {
    final response = await _apiClient.patch(ApiUrls.cancelOrder(orderId));
    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }
    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
    );
  }

  List<OrderModel> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
    }
    return const [];
  }
}
