import 'package:flutter/material.dart';
import 'package:aurore_school/core/constants/app_colors.dart';

// AppTextStyles defines the typography for Aurore School, ensuring a cohesive and accessible design.
class AppTextStyles {
  // Headings
  static const TextStyle display = TextStyle(
    fontFamily: 'Inter',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle header = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.iconPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle subheader = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.0,
    height: 1.4,
  );

  // Body Text
  static const TextStyle body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral,
    letterSpacing: 0.3,
    height: 1.4,
  );

  // Interactive Elements
  static const TextStyle button = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.iconPrimary,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  // Feedback States
  static const TextStyle error = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle disabled = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral,
    letterSpacing: 0.2,
    height: 1.5,
  );
}
