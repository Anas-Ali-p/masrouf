import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class DetailActions extends StatelessWidget {
  const DetailActions({
    super.key,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Row(
      children: [
        // Delete (compact, error)
        _IconBtn(
          icon: Icons.delete_outline_rounded,
          onTap: onDelete,
          fg: colors.error,
          bg: colors.error.withValues(alpha: .08),
          border: colors.error.withValues(alpha: .28),
        ),
        const SizedBox(width: 6),

        // Share (compact, neutral)
        _IconBtn(
          icon: Icons.share_outlined,
          onTap: onShare,
          fg: colors.primary,
          bg: colors.primary.withValues(alpha: .08),
          border: colors.primary.withValues(alpha: .25),
        ),
        const SizedBox(width: 8),

        // Edit (fills the rest, primary)
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              textStyle: text.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('تعديل العملية'),
          ),
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.fg,
    required this.bg,
    required this.border,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color fg;
  final Color bg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: border),
          ),
          child: Icon(icon, size: 20, color: fg),
        ),
      ),
    );
  }
}
