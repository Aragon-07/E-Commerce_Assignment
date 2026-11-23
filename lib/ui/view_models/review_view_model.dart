import 'package:flutter/foundation.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

/// Loads, creates, and deletes product reviews.
class ReviewViewModel extends ChangeNotifier {
  ReviewViewModel({required this._reviewRepository});

  final ReviewRepository _reviewRepository;

  final List<ReviewModel> _reviews = [];
  int _totalCount = 0;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<void> loadReviews(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _reviewRepository.getReviews(productId: productId);
    _isLoading = false;

    if (res.isSuccess && res.data != null) {
      _reviews
        ..clear()
        ..addAll(res.data!.results);
      _totalCount = res.data!.total;
    } else {
      _errorMessage = res.message;
    }
    notifyListeners();
  }

  Future<bool> createReview({
    required String productId,
    required String comment,
    required double rating,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final res = await _reviewRepository.createReview(
      productId: productId,
      comment: comment,
      rating: rating,
    );
    _isSubmitting = false;

    if (res.isSuccess) {
      await loadReviews(productId);
      return true;
    }

    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteReview({
    required String reviewId,
    required String productId,
  }) async {
    final res = await _reviewRepository.deleteReview(reviewId);
    if (res.isSuccess) {
      _reviews.removeWhere((r) => r.id == reviewId);
      if (_totalCount > 0) _totalCount--;
      notifyListeners();
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
