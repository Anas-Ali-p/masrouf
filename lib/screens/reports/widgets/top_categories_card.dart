import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/report_data.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class TopCategoriesCard extends StatelessWidget {
  const TopCategoriesCard({
    super.key,
    required this.slices,
    this.currency = 'SAR',
  });

  final List<CategorySlice> slices;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    if (slices.isEmpty) return const SizedBox.shrink();

    final total = slices.fold<double>(0, (s, c) => s + c.amount);
    final top = slices.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.leaderboard_rounded, size: 14, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'أعلى التصنيفات',
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm + 2),
          for (var i = 0; i < top.length; i++) ...[
            _Row(slice: top[i], total: total, currency: currency),
            if (i != top.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.slice,
    required this.total,
    required this.currency,
  });

  final CategorySlice slice;
  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final pct = total == 0 ? 0.0 : slice.amount / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: slice.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(slice.icon, size: 13, color: slice.color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                slice.category,
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              NumberFormat('#,##0.00', 'en').format(slice.amount),
              textDirection: .ltr,
              style: text.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              currency,
              style: text.labelSmall?.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 4,
            backgroundColor: tokens.border.withValues(alpha: .5),
            valueColor: AlwaysStoppedAnimation(slice.color),
          ),
        ),
      ],
    );
  }
}
