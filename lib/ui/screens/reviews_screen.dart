import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/review_repository.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/review_view_model.dart';
import 'auth/login_screen.dart';
import 'create_review_screen.dart';

/// Product reviews list screen with bottom review counter and `+` add-review button.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({
    super.key,
    required this.productId,
    required this.productTitle,
  });

  final String productId;
  final String productTitle;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ReviewViewModel(
        reviewRepository: ctx.read<ReviewRepository>(),
      )..loadReviews(productId),
      child: _ReviewsBody(
        productId: productId,
        productTitle: productTitle,
      ),
    );
  }
}

class _ReviewsBody extends StatelessWidget {
  const _ReviewsBody({
    required this.productId,
    required this.productTitle,
  });

  final String productId;
  final String productTitle;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthViewModel>().user?.id;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 19),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Reviews'),
      ),
      body: Consumer<ReviewViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              Expanded(
                child: vm.isLoading && vm.reviews.isEmpty
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      )
                    : vm.reviews.isEmpty
                        ? const Center(
                            child: Text(
                              'No reviews yet. Be the first to review!',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () => vm.loadReviews(productId),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: vm.reviews.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final review = vm.reviews[index];
                                final isOwn = currentUserId != null &&
                                    currentUserId.isNotEmpty &&
                                    review.userId == currentUserId;
                                return Card(
                                  elevation: 1,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor:
                                                  AppColors.surfaceGrey,
                                              child: const Icon(
                                                Icons.person_outline,
                                                size: 18,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                review.reviewerName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.star,
                                              size: 16,
                                              color: AppColors.ratingAmber,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              review.rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (isOwn)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 18,
                                                  color: AppColors.danger,
                                                ),
                                                onPressed: () =>
                                                    vm.deleteReview(
                                                  reviewId: review.id,
                                                  productId: productId,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          review.comment,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                      Text(
                        'Reviews (${vm.totalCount})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      FloatingActionButton(
                        mini: true,
                        elevation: 0,
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          final authVm = context.read<AuthViewModel>();
                          if (!authVm.isLoggedIn) {
                            final ok = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                            if (ok != true || !context.mounted) return;
                          }
                          final created =
                              await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => CreateReviewScreen(
                                productId: productId,
                                productTitle: productTitle,
                              ),
                            ),
                          );
                          if (created == true && context.mounted) {
                            vm.loadReviews(productId);
                          }
                        },
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
