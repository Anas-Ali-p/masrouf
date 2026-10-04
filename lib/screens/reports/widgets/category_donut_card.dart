import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/report_data.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class CategoryDonutCard extends StatelessWidget {
  const CategoryDonutCard({
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
              Icon(Icons.pie_chart_rounded, size: 14, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'التوزيع حسب التصنيف',
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm + 2),
          SizedBox(
            height: 130,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          startDegreeOffset: -90,
                          sections: [
                            for (final c in top)
                              PieChartSectionData(
                                value: c.amount,
                                color: c.color,
                                radius: 18,
                                showTitle: false,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الإجمالي',
                            style: text.labelSmall?.copyWith(
                              color: tokens.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            NumberFormat.compact(locale: 'en').format(total),
                            textDirection: .ltr,
                            style: text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            currency,
                            style: text.labelSmall?.copyWith(
                              color: tokens.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final c in top) ...[
                        _LegendRow(slice: c, total: total),
                        if (c != top.last) const SizedBox(height: 5),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.slice, required this.total});

  final CategorySlice slice;
  final double total;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final tokens = context.tokens;
    final pct = total == 0 ? 0.0 : (slice.amount / total) * 100;

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: slice.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            slice.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
        Text(
          '${pct.toStringAsFixed(0)}%',
          textDirection: .ltr,
          style: text.labelSmall?.copyWith(
            color: tokens.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
