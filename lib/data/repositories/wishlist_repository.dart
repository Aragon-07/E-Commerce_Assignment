import '../../core/constants/api_urls.dart';
import '../models/api_response.dart';
import '../models/wishlist_item_model.dart';
import '../services/api_client.dart';

/// Handles customer wishlist operations (`/wishlist`).
class WishlistRepository {
  WishlistRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<ApiResponse<List<WishlistItemModel>>> getWishlistItems() async {
    final response = await _apiClient.get(
      ApiUrls.wishlist,
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

  Future<ApiResponse<void>> addToWishlist(String productId) async {
    final response = await _apiClient.post(
      ApiUrls.wishlist,
      body: {'product': productId},
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

  Future<ApiResponse<void>> deleteWishlistItem(String wishlistItemId) async {
    final response = await _apiClient.delete(
      ApiUrls.wishlistItemById(wishlistItemId),
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

  List<WishlistItemModel> _parseList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(WishlistItemModel.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map(WishlistItemModel.fromJson)
          .toList();
    }
    return const [];
  }
}
