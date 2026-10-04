import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

/// Default duration for all app snackbars — short and to the point.
const Duration _kSnackDuration = Duration(milliseconds: 500);

enum SnackKind { success, error, warning, info }

void showAppSnack(
  BuildContext context, {
  required String message,
  SnackKind kind = SnackKind.info,
  Duration? duration,
}) {
  final colors = context.colors;
  final tokens = context.tokens;
  final text = context.text;

  final (bg, fg, icon) = switch (kind) {
    SnackKind.success => (
      tokens.success,
      Colors.white,
      Icons.check_circle_rounded,
    ),
    SnackKind.error => (
      colors.error,
      Colors.white,
      Icons.error_outline_rounded,
    ),
    SnackKind.warning => (
      tokens.warning,
      tokens.onWarning,
      Icons.warning_amber_rounded,
    ),
    SnackKind.info => (
      colors.onSurface,
      colors.surface,
      Icons.info_outline_rounded,
    ),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: text.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // Compact — no giant padding
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSizes.sm + 2,
          AppSizes.sm,
          AppSizes.sm + 2,
          AppSizes.sm,
        ),
        backgroundColor: bg.withValues(alpha: .8),
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        width: null,
        margin: const EdgeInsetsDirectional.fromSTEB(
          AppSizes.md,
          0,
          AppSizes.md,
          AppSizes.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        duration: duration ?? _kSnackDuration,
      ),
    );
}
