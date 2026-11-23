import '../../core/constants/api_urls.dart';
import '../models/api_response.dart';
import '../models/brand_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/slide_model.dart';
import '../services/api_client.dart';

/// Fetches slides, categories, brands, and products from the CraftyBay API.
class CatalogRepository {
  CatalogRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<ApiResponse<List<SlideModel>>> getSlides() async {
    final response = await _apiClient.get(ApiUrls.slides, includeAuth: false);
    if (!response.isSuccess) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }
    final list = _extractList(response.data)
        .map(SlideModel.fromJson)
        .toList();
    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: list,
    );
  }

  Future<ApiResponse<PaginatedList<CategoryModel>>> getCategories({
    int page = 1,
    int count = 20,
  }) async {
    final response = await _apiClient.get(
      ApiUrls.categories,
      includeAuth: false,
      queryParams: {'page': page, 'count': count},
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
      data: _extractPaginated(response.data, CategoryModel.fromJson),
    );
  }

  Future<ApiResponse<PaginatedList<BrandModel>>> getBrands({
    int page = 1,
    int count = 20,
  }) async {
    final response = await _apiClient.get(
      ApiUrls.brands,
      includeAuth: false,
      queryParams: {'page': page, 'count': count},
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
      data: _extractPaginated(response.data, BrandModel.fromJson),
    );
  }

  Future<ApiResponse<PaginatedList<ProductModel>>> getProducts({
    int page = 1,
    int count = 12,
    String? categoryId,
    String? brandId,
    String? tag,
  }) async {
    final response = await _apiClient.get(
      ApiUrls.products,
      queryParams: {
        'page': page,
        'count': count,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
        if (brandId != null && brandId.isNotEmpty) 'brand': brandId,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
      },
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
      data: _extractPaginated(response.data, ProductModel.fromJson),
    );
  }

  Future<ApiResponse<ProductModel>> getProductById(String id) async {
    final response = await _apiClient.get(
      ApiUrls.productById(id),
      includeAuth: false,
    );
    if (!response.isSuccess || response.data is! Map<String, dynamic>) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }
    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: ProductModel.fromJson(response.data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProductModel>> getProductBySlug(String slug) async {
    final response = await _apiClient.get(
      ApiUrls.productBySlug(slug),
      includeAuth: false,
    );
    if (!response.isSuccess || response.data is! Map<String, dynamic>) {
      return ApiResponse.failure(
        statusCode: response.statusCode,
        message: response.message,
      );
    }
    return ApiResponse.success(
      statusCode: response.statusCode,
      message: response.message,
      data: ProductModel.fromJson(response.data as Map<String, dynamic>),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return const [];
  }

  PaginatedList<T> _extractPaginated<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is Map<String, dynamic>) {
      final rawList = data['results'] is List ? data['results'] as List : [];
      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
      return PaginatedList<T>(
        results: items,
        total: (data['total'] as num?)?.toInt() ?? items.length,
        nextPage: (data['next'] as num?)?.toInt(),
        lastPage: (data['last_page'] as num?)?.toInt(),
      );
    }
    if (data is List) {
      final items = data.whereType<Map<String, dynamic>>().map(fromJson).toList();
      return PaginatedList<T>(results: items, total: items.length);
    }
    return const PaginatedList(results: [], total: 0);
  }
}
