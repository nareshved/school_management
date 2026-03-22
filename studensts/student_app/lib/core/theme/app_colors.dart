import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Deep Indigo
  static const Color primary = Color(0xFF1A237E);
  static const Color primaryContainer = Color(0xFF000666);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF8690EE);

  // Secondary - Teal
  static const Color secondary = Color(0xFF00897B);
  static const Color secondaryContainer = Color(0xFF8DF5E4);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Tertiary - Amber (Warning/Urgent)
  static const Color tertiary = Color(0xFFFF8F00);
  static const Color tertiaryContainer = Color(0xFFFFE082);

  // Error
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFFCDD2);

  // Surfaces - "The Scholastic Curator" layering
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFECECEC);

  // On Surface
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF454652);

  // Outline
  static const Color outline = Color(0xFFC6C5D4);
  static const Color outlineVariant = Color(0xFFE0E0E0);

  // Success
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFC8E6C9);

  // Status Colors
  static const Color paid = Color(0xFF2E7D32);
  static const Color pending = Color(0xFFFF8F00);
  static const Color overdue = Color(0xFFD32F2F);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1A237E), Color(0xFF000666)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF80CBC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
