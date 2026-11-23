import '../../core/constants/api_urls.dart';
import '../models/api_response.dart';
import '../models/review_model.dart';
import '../services/api_client.dart';

/// Handles listing, creating, and deleting product reviews.
class ReviewRepository {
  ReviewRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<ApiResponse<PaginatedList<ReviewModel>>> getReviews({
    required String productId,
    int page = 1,
    int count = 20,
  }) async {
    final response = await _apiClient.get(
      ApiUrls.reviews,
      queryParams: {
        'product': productId,
        'page': page,
        'count': count,
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final rawList = data['results'] is List ? data['results'] as List : [];
      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
      return ApiResponse.success(
        statusCode: response.statusCode,
        message: response.message,
        data: PaginatedList(
          results: items,
          total: (data['total'] as num?)?.toInt() ?? items.length,
          nextPage: (data['next'] as num?)?.toInt(),
          lastPage: (data['last_page'] as num?)?.toInt(),
        ),
      );
    }

    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: const PaginatedList(results: [], total: 0),
    );
  }

  Future<ApiResponse<ReviewModel?>> createReview({
    required String productId,
    required String comment,
    required double rating,
  }) async {
    final response = await _apiClient.post(
      ApiUrls.createReview,
      body: {
        'product': productId,
        'comment': comment.trim(),
        'rating': rating,
      },
    );

    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }

    ReviewModel? review;
    if (response.data is Map<String, dynamic>) {
      review = ReviewModel.fromJson(response.data as Map<String, dynamic>);
    }
    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: review,
    );
  }

  Future<ApiResponse<void>> deleteReview(String reviewId) async {
    final response = await _apiClient.delete(ApiUrls.reviewById(reviewId));
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
}
