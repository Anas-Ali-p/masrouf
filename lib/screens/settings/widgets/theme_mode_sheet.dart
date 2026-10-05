import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/app_theme.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

Future<({AppThemeId themeId, ThemeMode themeMode})?> showThemeModeSheet(
  BuildContext context, {
  required AppThemeId currentTheme,
  required ThemeMode currentMode,
}) {
  return showModalBottomSheet<({AppThemeId themeId, ThemeMode themeMode})>(
    context: context,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _ThemeModeSheet(
      currentTheme: currentTheme,
      currentMode: currentMode,
    ),
  );
}

class _ThemeModeSheet extends StatelessWidget {
  const _ThemeModeSheet({
    required this.currentTheme,
    required this.currentMode,
  });

  final AppThemeId currentTheme;
  final ThemeMode currentMode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    const modes = [
      (ThemeMode.system, 'تلقائي (حسب النظام)', Icons.brightness_auto_rounded),
      (ThemeMode.light, 'فاتح', Icons.light_mode_rounded),
      (ThemeMode.dark, 'داكن', Icons.dark_mode_rounded),
    ];

    const themes = [
      (AppThemeId.defaultTheme, 'الافتراضي', 'ألوان التطبيق الحالية'),
      (AppThemeId.themeColors, 'theme-colors', 'أزرق وأرجواني زاهٍ'),
      (AppThemeId.goldenTheme, 'golden-theme', 'ذهبي وألوان ليمونية'),
    ];


    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'الثيم',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'الثيم الأساسي',
                style: text.labelMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            for (final (themeId, label, subtitle) in themes) ...[
              Material(
                color: currentTheme == themeId
                    ? colors.primary.withValues(alpha: .08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  onTap: () => Navigator.pop(
                    context,
                    (
                      themeId: themeId,
                      themeMode: currentMode,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm + 2),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            themeId == AppThemeId.goldenTheme
                                ? Icons.auto_awesome_rounded
                                : themeId == AppThemeId.themeColors
                                ? Icons.palette_rounded
                                : Icons.circle_outlined,
                            size: 16,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm + 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: text.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                subtitle,
                                style: text.bodySmall?.copyWith(
                                  color: tokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (currentTheme == themeId)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'نمط الإضاءة',
                style: text.labelMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            for (final (mode, label, icon) in modes) ...[
              Material(
                color: currentMode == mode
                    ? colors.primary.withValues(alpha: .08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  onTap: () => Navigator.pop(
                    context,
                    (
                      themeId: currentTheme,
                      themeMode: mode,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm + 2),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(icon, size: 16, color: colors.primary),
                        ),
                        const SizedBox(width: AppSizes.sm + 2),
                        Expanded(
                          child: Text(
                            label,
                            style: text.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (currentMode == mode)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}
