import 'product_model.dart';

/// Cart item model (`GET /cart`, `POST /cart`, `PATCH /cart/:id`).
class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final String? color;
  final String? size;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    this.color,
    this.size,
  });

  double get totalPrice => product.currentPrice * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
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

    int parsedQty = 1;
    final rawQty = json['quantity'];
    if (rawQty is num) {
      parsedQty = rawQty.toInt();
    } else if (rawQty != null) {
      parsedQty = int.tryParse(rawQty.toString()) ?? 1;
    }
    if (parsedQty < 1) parsedQty = 1;

    return CartItemModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      product: product,
      quantity: parsedQty,
      color: json['color']?.toString(),
      size: json['size']?.toString(),
    );
  }

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    String? color,
    String? size,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }
}
