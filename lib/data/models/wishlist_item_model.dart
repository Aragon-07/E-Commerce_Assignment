import 'product_model.dart';

/// Wishlist item model (`GET /wishlist`, `POST /wishlist`).
class WishlistItemModel {
  final String id;
  final ProductModel product;

  const WishlistItemModel({
    required this.id,
    required this.product,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    late final ProductModel product;
    if (rawProduct is Map<String, dynamic>) {
      product = ProductModel.fromJson(rawProduct);
    } else {
      product = ProductModel(
        id: rawProduct?.toString() ?? '',
        title: 'Product',
        slug: '',
        description: '',
        photos: const [],
        colors: const [],
        sizes: const [],
        tags: const [],
        currentPrice: 0,
        quantity: 1,
        categories: const [],
      );
    }

    return WishlistItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      product: product,
    );
  }
}
