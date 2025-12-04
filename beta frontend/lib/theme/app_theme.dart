import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFF5A5F); // Orange/Red
  static const Color darkNavy = Color(0xFF1D2333);
  static const Color darkGrey = Color(0xFF2E3445);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color green = Color(0xFF10B981);
  static const Color starColor = Color(0xFFFF5A5F);

  // Text Styles
  static const TextStyle welcomeText = TextStyle(
    color: white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle appTitle = TextStyle(
    color: white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: textDark,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle viewAllText = TextStyle(
    color: primaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardTitle = TextStyle(
    color: textDark,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardSubtitle = TextStyle(
    color: textGrey,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle priceText = TextStyle(
    color: white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonText = TextStyle(
    color: white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle locationText = TextStyle(
    color: white,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle ratingText = TextStyle(
    color: textDark,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

extension ResponsiveExt on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;

  // Width percentage: pass 0-100 to get percent of screen width
  double wp(double percent) => screenSize.width * (percent / 100);

  // Height percentage: pass 0-100 to get percent of screen height
  double hp(double percent) => screenSize.height * (percent / 100);

  // Scale-independent text sizing relative to a 375pt baseline (iPhone X width)
  double sp(double size) {
    final scale = (screenSize.width / 375).clamp(0.85, 1.20);
    return size * scale;
  }

  bool get isSmall => screenSize.width < 360;
  bool get isTablet => screenSize.width >= 600;
}
