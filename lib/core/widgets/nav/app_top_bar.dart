import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showAvatar = true,
    this.onAvatarTap,
  });

  /// Bold line (e.g. user name, "الرئيسية").
  final String? title;

  /// Small muted line above [title] (e.g. greeting, date).
  final String? subtitle;

  /// Optional custom leading widget. Falls back to an avatar when [showAvatar] is true.
  final Widget? leading;

  /// Optional trailing widgets (e.g. notification bell).
  final List<Widget>? actions;

  final bool showAvatar;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.sm + 4,
        AppSizes.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Leading ────────────────────────────────────────
          if (leading != null)
            leading!
          else if (showAvatar)
            _Avatar(
              onTap: onAvatarTap,
              bg: colors.primary.withValues(alpha: .12),
              iconColor: colors.primary,
            ),

          const SizedBox(width: AppSizes.sm + 4),

          // ── Title block ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: text.labelSmall?.copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                if (title != null)
                  Text(
                    title!,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // ── Actions ────────────────────────────────────────
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.bg, required this.iconColor, this.onTap});

  final Color bg;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.person_rounded, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

/// Small icon button with an optional red dot — perfect for notifications.
class AppTopBarIconButton extends StatelessWidget {
  const AppTopBarIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: tokens.border.withValues(alpha: .35),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, size: 20, color: colors.onSurface),
              ),
            ),
          ),
          if (showDot)
            PositionedDirectional(
              top: 8,
              end: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
