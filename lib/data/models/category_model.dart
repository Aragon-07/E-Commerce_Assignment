/// Product category model (`GET /categories`).
class CategoryModel {
  final String id;
  final String title;
  final String slug;
  final String? description;
  final String? icon;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
    );
  }
}
