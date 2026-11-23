/// Home promotional banner slide model (`GET /slides`).
class SlideModel {
  final String id;
  final String photoUrl;
  final String description;
  final String? productId;
  final String? brandId;
  final String? categoryId;

  const SlideModel({
    required this.id,
    required this.photoUrl,
    required this.description,
    this.productId,
    this.brandId,
    this.categoryId,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      photoUrl: (json['photo_url'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      productId: _extractId(json['product']),
      brandId: _extractId(json['brand']),
      categoryId: _extractId(json['category']),
    );
  }

  static String? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString();
    }
    return value.toString();
  }
}
