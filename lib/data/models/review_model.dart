/// Product review model (`GET /reviews`, `POST /review`).
class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String reviewerName;
  final String? reviewerAvatar;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String productId = '';
    final rawProduct = json['product'];
    if (rawProduct is Map<String, dynamic>) {
      productId = (rawProduct['_id'] ?? rawProduct['id'] ?? '').toString();
    } else if (rawProduct != null) {
      productId = rawProduct.toString();
    }

    String userId = '';
    String reviewerName = 'Customer';
    String? reviewerAvatar;
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      userId = (rawUser['_id'] ?? rawUser['id'] ?? '').toString();
      final first = (rawUser['first_name'] ?? '').toString();
      final last = (rawUser['last_name'] ?? '').toString();
      final combined = '$first $last'.trim();
      if (combined.isNotEmpty) {
        reviewerName = combined;
      }
      reviewerAvatar = rawUser['avatar_url']?.toString();
    } else if (rawUser != null) {
      userId = rawUser.toString();
    }

    final rawRating = json['rating'];
    double parsedRating = 5.0;
    if (rawRating is num) {
      parsedRating = rawRating.toDouble();
    } else if (rawRating != null) {
      parsedRating = double.tryParse(rawRating.toString()) ?? 5.0;
    }

    return ReviewModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: productId,
      userId: userId,
      reviewerName: reviewerName,
      reviewerAvatar: reviewerAvatar,
      rating: parsedRating,
      comment: (json['comment'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
