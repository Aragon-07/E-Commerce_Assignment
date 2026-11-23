/// Standard response wrapper for API calls.
class ApiResponse<T> {
  final bool isSuccess;
  final int statusCode;
  final String message;
  final T? data;

  const ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ApiResponse.success({
    required int statusCode,
    String message = 'Success',
    T? data,
  }) {
    return ApiResponse<T>(
      isSuccess: true,
      statusCode: statusCode,
      message: message,
      data: data,
    );
  }

  factory ApiResponse.failure({
    required int statusCode,
    required String message,
  }) {
    return ApiResponse<T>(
      isSuccess: false,
      statusCode: statusCode,
      message: message,
    );
  }
}

/// Paginated list result container matching `data.results` from the API.
class PaginatedList<T> {
  final List<T> results;
  final int total;
  final int? nextPage;
  final int? lastPage;

  const PaginatedList({
    required this.results,
    required this.total,
    this.nextPage,
    this.lastPage,
  });
}
