import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/catalog_repository.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/product_details_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import 'auth/login_screen.dart';
import 'reviews_screen.dart';

/// Product details screen with image slider, color/size selectors, description, and Add to Cart bar.
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductDetailsViewModel(
        catalogRepository: ctx.read<CatalogRepository>(),
        initialProduct: product,
      )..fetchLatestDetails(),
      child: const _ProductDetailsBody(),
    );
  }
}

class _ProductDetailsBody extends StatefulWidget {
  const _ProductDetailsBody();

  @override
  State<_ProductDetailsBody> createState() => _ProductDetailsBodyState();
}

class _ProductDetailsBodyState extends State<_ProductDetailsBody> {
  final PageController _imageController = PageController();
  int _imageIndex = 0;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(ProductDetailsViewModel vm) async {
    final authVm = context.read<AuthViewModel>();
    if (!authVm.isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
    }

    final cartVm = context.read<CartViewModel>();
    final ok = await cartVm.addToCart(
      productId: vm.product.id,
      quantity: vm.quantity,
      color: vm.selectedColor,
      size: vm.selectedSize,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Added to cart'
              : (cartVm.errorMessage ?? 'Could not add to cart'),
        ),
        backgroundColor: ok ? AppColors.primary : AppColors.danger,
      ),
    );
  }

  Future<void> _toggleWishlist(String productId) async {
    final authVm = context.read<AuthViewModel>();
    if (!authVm.isLoggedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    await context.read<WishlistViewModel>().toggleWishlist(productId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProductDetailsViewModel, WishlistViewModel, CartViewModel>(
      builder: (context, vm, wishlistVm, cartVm, _) {
        final product = vm.product;
        final photos = product.photos;
        final isWishlisted = wishlistVm.isWishlisted(product.id);
        final priceText = product.currentPrice == product.currentPrice.roundToDouble()
            ? '\$${product.currentPrice.toInt()}'
            : '\$${product.currentPrice.toStringAsFixed(2)}';

        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSlider(context, photos),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                QuantityStepper(
                                  quantity: vm.quantity,
                                  onIncrement: vm.incrementQuantity,
                                  onDecrement: vm.decrementQuantity,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 18,
                                  color: AppColors.ratingAmber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ReviewsScreen(
                                          productId: product.id,
                                          productTitle: product.title,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Reviews',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                InkWell(
                                  onTap: () => _toggleWishlist(product.id),
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(
                                      isWishlisted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (product.colors.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              const Text(
                                'Color',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: product.colors.map((colorName) {
                                  final selected =
                                      vm.selectedColor == colorName;
                                  final swatch =
                                      AppColors.parseColorName(colorName);
                                  final isLight =
                                      swatch.computeLuminance() > 0.7;
                                  return InkWell(
                                    onTap: () => vm.selectColor(colorName),
                                    customBorder: const CircleBorder(),
                                    child: Tooltip(
                                      message: colorName,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: swatch,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selected
                                                ? AppColors.primary
                                                : Colors.grey.shade300,
                                            width: selected ? 2.5 : 1,
                                          ),
                                        ),
                                        child: selected
                                            ? Icon(
                                                Icons.check,
                                                size: 17,
                                                color: isLight
                                                    ? Colors.black
                                                    : Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            if (product.sizes.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              const Text(
                                'Size',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: product.sizes.map((size) {
                                  final selected = vm.selectedSize == size;
                                  return InkWell(
                                    onTap: () => vm.selectSize(size),
                                    borderRadius: BorderRadius.circular(18),
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 34,
                                        minHeight: 34,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.primary
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      child: Text(
                                        size,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: selected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 20),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description.isNotEmpty
                                  ? product.description
                                  : 'No description available for this product.',
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            priceText,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 145,
                        child: ElevatedButton(
                          onPressed:
                              cartVm.isMutating ? null : () => _addToCart(vm),
                          child: cartVm.isMutating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Add To Cart'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSlider(BuildContext context, List<String> photos) {
    final slideCount = photos.isEmpty ? 1 : photos.length;
    return Container(
      height: 270,
      width: double.infinity,
      color: AppColors.surfaceGrey,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imageController,
            itemCount: slideCount,
            onPageChanged: (idx) => setState(() => _imageIndex = idx),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 58, 24, 28),
                child: AppNetworkImage(
                  imageUrl: photos.isEmpty ? null : photos[index],
                  fit: BoxFit.contain,
                  placeholderIconSize: 64,
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 19),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (slideCount > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slideCount, (idx) {
                  final active = idx == _imageIndex;
                  return Container(
                    width: active ? 12 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
