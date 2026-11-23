import 'package:flutter/material.dart';

/// Color palette matching the CraftyBay UI design system.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF07ADAE);
  static const Color primaryDark = Color(0xFF058C8D);
  static const Color primaryLight = Color(0xFFE6F7F7);
  static const Color accentOrange = Color(0xFFF7941D);
  static const Color ratingAmber = Color(0xFFFFC107);
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF7A7A7A);
  static const Color borderGrey = Color(0xFFE2E6EA);
  static const Color surfaceGrey = Color(0xFFF3F4F6);
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF2E7D32);

  /// Maps backend color names (e.g. "Red", "Gold") or hex codes to [Color].
  static Color parseColorName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.startsWith('#')) {
      final hex = normalized.substring(1);
      if (hex.length == 6) {
        final value = int.tryParse('FF$hex', radix: 16);
        if (value != null) return Color(value);
      } else if (hex.length == 8) {
        final value = int.tryParse(hex, radix: 16);
        if (value != null) return Color(value);
      }
    }

    switch (normalized) {
      case 'black':
        return const Color(0xFF222222);
      case 'white':
        return const Color(0xFFF8F9FA);
      case 'red':
        return const Color(0xFFE53935);
      case 'blue':
        return const Color(0xFF1E88E5);
      case 'green':
        return const Color(0xFF43A047);
      case 'purple':
        return const Color(0xFF8E24AA);
      case 'gold':
        return const Color(0xFFD4AF37);
      case 'yellow':
        return const Color(0xFFFDD835);
      case 'orange':
        return const Color(0xFFFB8C00);
      case 'pink':
        return const Color(0xFFD81B60);
      case 'brown':
        return const Color(0xFF6D4C41);
      case 'grey':
      case 'gray':
        return const Color(0xFF9E9E9E);
      case 'teal':
        return primary;
      case 'navy':
        return const Color(0xFF1A237E);
      case 'silver':
        return const Color(0xFFC0C0C0);
      default:
        return primary;
    }
  }
}
