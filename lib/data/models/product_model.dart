import 'brand_model.dart';
import 'category_model.dart';

/// Product model supporting nested/unpopulated brand and categories and empty media arrays.
class ProductModel {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String? metaDescription;
  final List<String> photos;
  final List<String> colors;
  final List<String> sizes;
  final List<String> tags;
  final double? regularPrice;
  final double currentPrice;
  final int quantity;
  final BrandModel? brand;
  final List<CategoryModel> categories;
  final double rating;

  const ProductModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.metaDescription,
    required this.photos,
    required this.colors,
    required this.sizes,
    required this.tags,
    this.regularPrice,
    required this.currentPrice,
    required this.quantity,
    this.brand,
    required this.categories,
    this.rating = 4.8,
  });

  String? get primaryPhoto => photos.isNotEmpty ? photos.first : null;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    BrandModel? parsedBrand;
    final rawBrand = json['brand'];
    if (rawBrand is Map<String, dynamic>) {
      parsedBrand = BrandModel.fromJson(rawBrand);
    }

    final parsedCategories = <CategoryModel>[];
    final rawCategories = json['categories'];
    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map<String, dynamic>) {
          parsedCategories.add(CategoryModel.fromJson(item));
        }
      }
    }

    return ProductModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      metaDescription: json['meta_description']?.toString(),
      photos: _parseStringList(json['photos']),
      colors: _parseStringList(json['colors']),
      sizes: _parseStringList(json['sizes']),
      tags: _parseStringList(json['tags']),
      regularPrice: _parseDouble(json['regular_price']),
      currentPrice: _parseDouble(json['current_price']) ?? 0.0,
      quantity: _parseInt(json['quantity']) ?? 1,
      brand: parsedBrand,
      categories: parsedCategories,
      rating: _parseDouble(json['rating']) ?? 4.8,
    );
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .map((e) => e.toString().trim())
        .toList();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
