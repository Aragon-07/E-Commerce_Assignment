/// Product brand model (`GET /brands`).
class BrandModel {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? icon;

  const BrandModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.icon,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}
