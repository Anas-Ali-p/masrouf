import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class SettingsGroupTile extends StatelessWidget {
  const SettingsGroupTile({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;
  final String? subtitle;
  final Color? iconColor;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final ic = iconColor ?? (danger ? colors.error : colors.primary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSizes.sm + 2,
            AppSizes.sm,
            AppSizes.sm + 2,
            AppSizes.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: ic.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: ic),
              ),
              const SizedBox(width: AppSizes.sm + 2),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: danger ? colors.error : colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: text.labelSmall?.copyWith(
                          color: tokens.textMuted,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: tokens.border.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: text.labelSmall?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 4),

              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: tokens.textMuted.withValues(alpha: .7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
