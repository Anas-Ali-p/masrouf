import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class CompactChip extends StatelessWidget {
  const CompactChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.iconColor,
    this.fill = false, // ← new
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color? iconColor;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final ic = iconColor ?? colors.primary;

    return Material(
      color: active ? colors.primary.withValues(alpha: .10) : colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 12, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: active
                  ? colors.primary.withValues(alpha: .35)
                  : tokens.border,
            ),
          ),
          child: Row(
            mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: fill
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: active ? colors.primary : ic),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: active ? colors.primary : colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
