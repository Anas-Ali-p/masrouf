import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class DetailsList extends StatelessWidget {
  const DetailsList({super.key, required this.rows});

  final List<DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _DetailRow(data: rows[i]),
            if (i != rows.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: AppSizes.md + 34,
                endIndent: AppSizes.md,
                color: tokens.border.withValues(alpha: .5),
              ),
          ],
        ],
      ),
    );
  }
}

@immutable
class DetailRowData {
  const DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.ltrValue = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final bool ltrValue;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.data});

  final DetailRowData data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final ic = data.iconColor ?? colors.primary;

    return Padding(
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
            child: Icon(data.icon, size: 15, color: ic),
          ),
          const SizedBox(width: AppSizes.sm + 2),
          Text(
            data.label,
            style: text.labelMedium?.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              data.value,
              textAlign: TextAlign.end,
              textDirection: data.ltrValue ? TextDirection.ltr : null,
              style: text.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: data.valueColor ?? colors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
