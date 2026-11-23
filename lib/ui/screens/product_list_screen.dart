import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/catalog_repository.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/product_list_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import 'auth/login_screen.dart';
import 'product_details_screen.dart';

/// Responsive product grid screen filtered by category, brand, tag, or search query.
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.brandId,
    this.tag,
    this.searchQuery,
    this.fallbackPage,
  });

  final String title;
  final String? categoryId;
  final String? brandId;
  final String? tag;
  final String? searchQuery;
  final int? fallbackPage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductListViewModel(
        catalogRepository: ctx.read<CatalogRepository>(),
        categoryId: categoryId,
        brandId: brandId,
        tag: tag,
        searchQuery: searchQuery,
        fallbackPage: fallbackPage,
      )..loadProducts(),
      child: _ProductListBody(title: title),
    );
  }
}

class _ProductListBody extends StatefulWidget {
  const _ProductListBody({required this.title});

  final String title;

  @override
  State<_ProductListBody> createState() => _ProductListBodyState();
}

class _ProductListBodyState extends State<_ProductListBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 160) {
      context.read<ProductListViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleWishlistTap(ProductModel product) async {
    final authVm = context.read<AuthViewModel>();
    if (!authVm.isLoggedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    await context.read<WishlistViewModel>().toggleWishlist(product.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 19),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
      ),
      body: Consumer2<ProductListViewModel, WishlistViewModel>(
        builder: (context, vm, wishlistVm, _) {
          if (vm.isLoading && vm.products.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (vm.errorMessage != null && vm.products.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () => vm.loadProducts(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (vm.products.isEmpty) {
            return const Center(
              child: Text(
                'No products found',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => vm.loadProducts(refresh: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 480 ? 3 : 2;
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(14),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: vm.products.length + (vm.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= vm.products.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      );
                    }
                    final product = vm.products[index];
                    return ProductCard(
                      width: null,
                      title: product.title,
                      price: product.currentPrice,
                      rating: product.rating,
                      imageUrl: product.primaryPhoto,
                      isWishlisted: wishlistVm.isWishlisted(product.id),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                      },
                      onActionTap: () => _handleWishlistTap(product),
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
