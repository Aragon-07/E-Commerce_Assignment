import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// CraftyBay brand mark + wordmark widget supporting compact (AppBar) and large (Splash/Auth) layouts.
class CraftyBayLogo extends StatelessWidget {
  const CraftyBayLogo({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShoppingBagBadge(size: 30),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
              children: [
                TextSpan(
                  text: 'Crafty',
                  style: TextStyle(color: AppColors.primary),
                ),
                TextSpan(
                  text: 'Bay',
                  style: TextStyle(color: AppColors.accentOrange),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShoppingBagBadge(size: 86),
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'Crafty',
                style: TextStyle(color: AppColors.primary),
              ),
              TextSpan(
                text: 'Bay',
                style: TextStyle(color: AppColors.accentOrange),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShoppingBagBadge extends StatelessWidget {
  const _ShoppingBagBadge({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.88,
            height: size * 0.88,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7C4DFF),
                  Color(0xFFE91E63),
                  Color(0xFFFF9800),
                ],
              ),
              borderRadius: BorderRadius.circular(size * 0.22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: size * 0.56,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(size * 0.06),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                Icons.near_me_rounded,
                color: Colors.white,
                size: size * 0.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
