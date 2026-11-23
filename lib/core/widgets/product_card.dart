import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'app_network_image.dart';

/// Reusable product card matching the CraftyBay UI reference.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.rating = 4.8,
    this.imageUrl,
    this.isWishlisted = false,
    this.showDeleteIcon = false,
    required this.onTap,
    this.onActionTap,
    this.width = 148,
  });

  final String title;
  final double price;
  final double rating;
  final String? imageUrl;
  final bool isWishlisted;
  final bool showDeleteIcon;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final priceText = price == price.roundToDouble()
        ? '\$${price.toInt()}'
        : '\$${price.toStringAsFixed(2)}';

    return SizedBox(
      width: width,
      child: Card(
        elevation: 1.5,
        shadowColor: Colors.black12,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: AppColors.primaryLight,
                  padding: const EdgeInsets.all(8),
                  child: AppNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            priceText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          size: 13,
                          color: AppColors.ratingAmber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: onActionTap,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: showDeleteIcon
                                  ? AppColors.danger
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              showDeleteIcon
                                  ? Icons.delete_outline
                                  : (isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border),
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
