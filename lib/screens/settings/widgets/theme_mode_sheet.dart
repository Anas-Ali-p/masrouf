import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

Future<ThemeMode?> showThemeModeSheet(
  BuildContext context, {
  required ThemeMode current,
}) {
  return showModalBottomSheet<ThemeMode>(
    context: context,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _ThemeModeSheet(current: current),
  );
}

class _ThemeModeSheet extends StatelessWidget {
  const _ThemeModeSheet({required this.current});

  final ThemeMode current;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    const options = [
      (ThemeMode.system, 'تلقائي (حسب النظام)', Icons.brightness_auto_rounded),
      (ThemeMode.light, 'فاتح', Icons.light_mode_rounded),
      (ThemeMode.dark, 'داكن', Icons.dark_mode_rounded),
    ];

    return SafeArea(
      top: false,
      child: Padding(
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
              'المظهر',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.sm + 2),
            for (final (mode, label, icon) in options) ...[
              Material(
                color: current == mode
                    ? colors.primary.withValues(alpha: .08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  onTap: () => Navigator.pop(context, mode),
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
                        if (current == mode)
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
