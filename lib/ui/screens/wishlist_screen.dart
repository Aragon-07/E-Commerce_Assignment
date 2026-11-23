import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/main_nav_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import 'auth/login_screen.dart';
import 'product_details_screen.dart';

/// Wish List tab displaying saved products in a responsive grid.
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 19),
          onPressed: () => context.read<MainNavViewModel>().backToHome(),
        ),
        title: const Text('Wish List'),
      ),
      body: !authVm.isLoggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 56,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sign in to view your saved wishlist items.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () async {
                          final ok = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                          if (ok == true && context.mounted) {
                            context.read<WishlistViewModel>().loadWishlist();
                          }
                        },
                        child: const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Consumer<WishlistViewModel>(
              builder: (context, vm, _) {
                if (vm.isLoading && vm.items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (vm.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_outline,
                          size: 62,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your wish list is empty',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: vm.loadWishlist,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount =
                          constraints.maxWidth >= 480 ? 3 : 2;
                      return GridView.builder(
                        padding: const EdgeInsets.all(14),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: vm.items.length,
                        itemBuilder: (context, index) {
                          final wishItem = vm.items[index];
                          final product = wishItem.product;
                          return ProductCard(
                            width: null,
                            title: product.title,
                            price: product.currentPrice,
                            rating: product.rating,
                            imageUrl: product.primaryPhoto,
                            showDeleteIcon: true,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(product: product),
                                ),
                              );
                            },
                            onActionTap: () =>
                                vm.removeWishlistItem(wishItem.id),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
