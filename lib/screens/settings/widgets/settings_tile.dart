import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailingText,
    this.trailingSwitch,
    this.onSwitchChanged,
    this.iconColor,
    this.iconBg,
    this.danger = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final String? trailingText;
  final bool? trailingSwitch;
  final ValueChanged<bool>? onSwitchChanged;
  final Color? iconColor;
  final Color? iconBg;
  final bool danger;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final fg = danger ? colors.error : colors.primary;
    final ic = iconColor ?? fg;
    final bg = iconBg ?? ic.withValues(alpha: .10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: trailingSwitch != null ? null : onTap,
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
                  color: bg,
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
                        fontWeight: FontWeight.w600,
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

              if (trailingText != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 6),
                  child: Text(
                    trailingText!,
                    style: text.labelSmall?.copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (trailingSwitch != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch.adaptive(
                      value: trailingSwitch!,
                      onChanged: onSwitchChanged,
                      activeColor: colors.primary,
                    ),
                  ),
                ),

              if (trailingSwitch == null && showChevron && onTap != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Icon(
                    Icons.chevron_right_rounded, // ← change this
                    size: 18,
                    color: tokens.textMuted.withValues(alpha: .7),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
