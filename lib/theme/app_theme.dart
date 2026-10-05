import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_sizes.dart';
import 'app_text_styles.dart';
import 'app_tokens.dart';

enum AppThemeId {
  defaultTheme('default'),
  themeColors('theme-colors'),
  goldenTheme('golden-theme');

  const AppThemeId(this.storageName);

  final String storageName;

  static AppThemeId fromStorage(String? value) => AppThemeId.values.firstWhere(
    (e) => e.storageName == value,
    orElse: () => AppThemeId.defaultTheme,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light({AppThemeId themeId = AppThemeId.defaultTheme}) {
    final palette = _paletteFor(themeId);
    final scheme = _scheme(palette, Brightness.light);
    return _build(scheme, _tokens(palette, Brightness.light));
  }

  static ThemeData dark({AppThemeId themeId = AppThemeId.defaultTheme}) {
    final palette = _paletteFor(themeId);
    final scheme = _scheme(palette, Brightness.dark);
    return _build(scheme, _tokens(palette, Brightness.dark));
  }

  static _ThemePalette _paletteFor(AppThemeId themeId) {
    switch (themeId) {
      case AppThemeId.defaultTheme:
        return const _ThemePalette(
          bgLight: AppColors.bgLight,
          bgDark: AppColors.bgDark,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          accent: AppColors.accent,
          onAccent: AppColors.onAccent,
          success: AppColors.success,
          onSuccess: AppColors.onSuccess,
          warning: AppColors.warning,
          onWarning: AppColors.onWarning,
          error: AppColors.error,
          onError: AppColors.onError,
          textLight: AppColors.textLight,
          textDark: AppColors.textDark,
        );
      case AppThemeId.themeColors:
        return const _ThemePalette(
          bgLight: Color(0xFFF4F6FB),
          bgDark: Color(0xFF04060B),
          primary: Color(0xFF0015F3),
          onPrimary: Color(0xFFFFFFFF),
          secondary: Color(0xFF83D8FF),
          onSecondary: Color(0xFF101319),
          accent: Color(0xFF8445FF),
          onAccent: Color(0xFFFFFFFF),
          success: Color(0xFF00BE46),
          onSuccess: Color(0xFF101319),
          warning: Color(0xFFB67300),
          onWarning: Color(0xFF101319),
          error: Color(0xFFF91818),
          onError: Color(0xFF101319),
          textLight: Color(0xFF07149C),
          textDark: Color(0xFFA1C8FF),
        );
      case AppThemeId.goldenTheme:
        return const _ThemePalette(
          bgLight: Color(0xFFFFFFFF),
          bgDark: Color(0xFF04060B),
          primary: Color(0xFFFFC300),
          onPrimary: Color(0xFF101319),
          secondary: Color(0xFFEEFF83),
          onSecondary: Color(0xFF101319),
          accent: Color(0xFFC4FF45),
          onAccent: Color(0xFF101319),
          success: Color(0xFF00BE46),
          onSuccess: Color(0xFF101319),
          warning: Color(0xFFB67300),
          onWarning: Color(0xFF101319),
          error: Color(0xFFF91818),
          onError: Color(0xFF101319),
          textLight: Color(0xFFBC8600),
          textDark: Color(0xFFFFB600),
        );
    }
  }

  static ColorScheme _scheme(_ThemePalette palette, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ColorScheme(
      brightness: brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primary,
      onPrimaryContainer: palette.onPrimary,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      tertiary: palette.accent,
      onTertiary: palette.onAccent,
      error: palette.error,
      onError: palette.onError,
      surface: isLight ? palette.bgLight : palette.bgDark,
      onSurface: isLight ? palette.textLight : palette.textDark,
    );
  }

  static AppTokens _tokens(_ThemePalette palette, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return AppTokens(
      success: palette.success,
      onSuccess: palette.onSuccess,
      warning: palette.warning,
      onWarning: palette.onWarning,
      border: isLight ? const Color(0xFFE1E5EE) : const Color(0xFF243048),
      textMuted: isLight ? const Color(0xFF6B7280) : const Color(0xFF9AA3B8),
      accent: palette.accent,
      onAccent: palette.onAccent,
    );
  }

  static ThemeData _build(ColorScheme scheme, AppTokens tokens) {
    final textTheme = AppTextStyles.textTheme.apply(
      fontFamily: AppTextStyles.fontFamily,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          foregroundColor: scheme.primary,
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(
          AppSizes.md,
          AppSizes.md,
          AppSizes.md,
          AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: BorderSide(color: tokens.border),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: tokens.border,
        thickness: 1,
        space: 1,
      ),

      extensions: <ThemeExtension<dynamic>>[tokens],
    );
  }
}

class _ThemePalette {
  const _ThemePalette({
    required this.bgLight,
    required this.bgDark,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.error,
    required this.onError,
    required this.textLight,
    required this.textDark,
  });

  final Color bgLight;
  final Color bgDark;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color accent;
  final Color onAccent;
  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color error;
  final Color onError;
  final Color textLight;
  final Color textDark;
}
