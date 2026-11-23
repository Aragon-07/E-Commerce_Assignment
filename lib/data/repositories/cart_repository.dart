import '../../core/constants/api_urls.dart';
import '../models/api_response.dart';
import '../models/cart_item_model.dart';
import '../services/api_client.dart';

/// Handles customer shopping cart operations (`/cart`).
class CartRepository {
  CartRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<ApiResponse<List<CartItemModel>>> getCartItems() async {
    final response = await _apiClient.get(
      ApiUrls.cart,
      queryParams: {'count': 50},
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

  Future<ApiResponse<void>> addToCart({
    required String productId,
    int quantity = 1,
    String? color,
    String? size,
  }) async {
    final body = <String, dynamic>{
      'product': productId,
      'quantity': quantity,
      if (color != null && color.isNotEmpty) 'color': color,
      if (size != null && size.isNotEmpty) 'size': size,
    };

    final response = await _apiClient.post(ApiUrls.cart, body: body);
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

  Future<ApiResponse<void>> updateCartItem({
    required String cartItemId,
    required int quantity,
  }) async {
    final response = await _apiClient.patch(
      ApiUrls.cartItemById(cartItemId),
      body: {'quantity': quantity},
    );
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

  Future<ApiResponse<void>> deleteCartItem(String cartItemId) async {
    final response = await _apiClient.delete(ApiUrls.cartItemById(cartItemId));
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

  List<CartItemModel> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList();
    }
    return const [];
  }
}
