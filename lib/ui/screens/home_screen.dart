import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_urls.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_network_image.dart';
import '../../core/widgets/category_card.dart';
import '../../core/widgets/crafty_bay_logo.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/product_model.dart';
import '../../data/models/slide_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/home_view_model.dart';
import '../view_models/main_nav_view_model.dart';
import '../view_models/wishlist_view_model.dart';
import 'auth/login_screen.dart';
import 'product_details_screen.dart';
import 'product_list_screen.dart';
import 'profile/orders_screen.dart';
import 'profile/profile_screen.dart';

/// Home discovery screen with search bar, hero slider, categories, and product shelves.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _openSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductListScreen(
          title: 'Search: $trimmed',
          searchQuery: trimmed,
        ),
      ),
    );
  }

  void _openProductDetails(ProductModel product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  Future<void> _handleWishlistTap(ProductModel product) async {
    final authVm = context.read<AuthViewModel>();
    if (!authVm.isLoggedIn) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    final wishlistVm = context.read<WishlistViewModel>();
    final ok = await wishlistVm.toggleWishlist(product.id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wishlistVm.errorMessage ?? 'Could not update wishlist'),
        ),
      );
    }
  }

  void _showSupportDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Customer Support'),
        content: const Text(
          'Need help with an order?\n\nPhone: +880 1700-000000\nEmail: support@craftybay.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CraftyBayLogo(compact: true),
        actions: [
          _CircleIconButton(
            icon: Icons.person_outline,
            tooltip: 'Profile',
            onTap: () {
              final isLoggedIn = context.read<AuthViewModel>().isLoggedIn;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      isLoggedIn ? const ProfileScreen() : const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.call_outlined,
            tooltip: 'Support',
            onTap: _showSupportDialog,
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.notifications_none_outlined,
            tooltip: 'Orders',
            onTap: () {
              final isLoggedIn = context.read<AuthViewModel>().isLoggedIn;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      isLoggedIn ? const OrdersScreen() : const LoginScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: Consumer2<HomeViewModel, WishlistViewModel>(
        builder: (context, homeVm, wishlistVm, _) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: homeVm.loadHomeData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                _buildSearchField(),
                const SizedBox(height: 14),
                if (homeVm.isLoading && homeVm.slides.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (homeVm.errorMessage != null &&
                    homeVm.popularProducts.isEmpty)
                  _buildErrorState(homeVm)
                else ...[
                  _buildBannerCarousel(homeVm.slides),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: 'All Categories',
                    onSeeAllTap: () =>
                        context.read<MainNavViewModel>().setIndex(1),
                  ),
                  const SizedBox(height: 10),
                  _buildCategoriesRow(homeVm),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: 'Popular',
                    onSeeAllTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(
                            title: 'Popular',
                            categoryId: ApiUrls.popularCategoryId,
                            fallbackPage: 1,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildProductRow(homeVm.popularProducts, wishlistVm),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: 'Special',
                    onSeeAllTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(
                            title: 'Special',
                            categoryId: ApiUrls.specialCategoryId,
                            fallbackPage: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildProductRow(homeVm.specialProducts, wishlistVm),
                  const SizedBox(height: 18),
                  SectionHeader(
                    title: 'New',
                    onSeeAllTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(
                            title: 'New',
                            tag: 'new',
                            fallbackPage: 3,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildProductRow(homeVm.newProducts, wishlistVm),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: _openSearch,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
          onPressed: () => _openSearch(_searchController.text),
        ),
        filled: true,
        fillColor: AppColors.surfaceGrey,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(List<SlideModel> slides) {
    if (slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: slides.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 126,
                        height: double.infinity,
                        color: Colors.white.withValues(alpha: 0.16),
                        child: AppNetworkImage(
                          imageUrl: slide.photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slide.description.isNotEmpty
                                ? slide.description
                                : 'Special Offer Save 30%',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ProductListScreen(
                                    title: slide.description.isNotEmpty
                                        ? slide.description
                                        : 'Featured Products',
                                    brandId: slide.brandId,
                                    categoryId: slide.categoryId,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(100, 34),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Buy Now'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (index) {
            final isActive = index == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 14 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoriesRow(HomeViewModel homeVm) {
    if (homeVm.categories.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No categories available')),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: homeVm.categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = homeVm.categories[index];
          return CategoryCard(
            title: category.title,
            iconUrl: category.icon,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    title: category.title,
                    categoryId: category.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductRow(
    List<ProductModel> products,
    WishlistViewModel wishlistVm,
  ) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No products found')),
      );
    }

    return SizedBox(
      height: 186,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            title: product.title,
            price: product.currentPrice,
            rating: product.rating,
            imageUrl: product.primaryPhoto,
            isWishlisted: wishlistVm.isWishlisted(product.id),
            onTap: () => _openProductDetails(product),
            onActionTap: () => _handleWishlistTap(product),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(HomeViewModel homeVm) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            homeVm.errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            child: ElevatedButton(
              onPressed: homeVm.loadHomeData,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.surfaceGrey,
          child: Icon(icon, size: 19, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
