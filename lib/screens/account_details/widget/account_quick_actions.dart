import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class AccountQuickActions extends StatelessWidget {
  const AccountQuickActions({
    super.key,
    required this.onTransfer,
    required this.onZeroBalance,
    required this.onExportPdf,
    required this.onReports,
  });

  final VoidCallback onTransfer;
  final VoidCallback onZeroBalance;
  final VoidCallback onExportPdf;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: _Action(
            icon: Icons.swap_horiz_rounded,
            label: 'تحويل',
            onTap: onTransfer,
            tint: colors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Action(
            icon: Icons.restart_alt_rounded,
            label: 'تصفير',
            onTap: onZeroBalance,
            tint: tokens.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Action(
            icon: Icons.picture_as_pdf_rounded,
            label: 'PDF',
            onTap: onExportPdf,
            tint: colors.error,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Action(
            icon: Icons.insights_rounded,
            label: 'التقارير',
            onTap: onReports,
            tint: tokens.accent,
          ),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: tokens.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: tint),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
