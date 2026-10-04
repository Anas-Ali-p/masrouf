import 'package:flutter/material.dart';

/// Raw color palette. Single source of truth.
/// Do NOT use these directly in widgets — read them via `context.colors`
/// or `context.tokens`. They are the inputs to [AppTheme] only.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color bgLight = Color(0xFFF7F8FC);
  static const Color bgDark = Color(0xFF0F1626);

  // Brand
  static const Color primary = Color(0xFF2F3EE0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFB1BACC);
  static const Color onSecondary = Color(0xFF101319);
  static const Color accent = Color(0xFF3CCABC);
  static const Color onAccent = Color(0xFF0F1626);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFF49B07);
  static const Color onWarning = Color(0xFF0F1626);
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);

  // Text
  static const Color textLight = Color(0xFF1C2438);
  static const Color textDark = Color(0xFFE6ECF5);
}
