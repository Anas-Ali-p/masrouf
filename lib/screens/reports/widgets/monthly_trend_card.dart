import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/report_data.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class MonthlyTrendCard extends StatelessWidget {
  const MonthlyTrendCard({
    super.key,
    required this.months,
    this.currency = 'SAR',
  });

  final List<MonthPoint> months;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    if (months.isEmpty) return const SizedBox.shrink();

    final maxVal = months
        .expand((m) => [m.income, m.expense])
        .fold<double>(0, (a, b) => a > b ? a : b);
    final yMax = maxVal == 0 ? 100.0 : maxVal * 1.2;

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
              Icon(Icons.bar_chart_rounded, size: 14, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'الاتجاه الشهري',
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              _dot(context, 'دخل', tokens.success),
              const SizedBox(width: 8),
              _dot(context, 'مصروف', colors.error),
            ],
          ),
          const SizedBox(height: AppSizes.sm + 2),
          SizedBox(
            height: 130,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: yMax,
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yMax / 3,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: tokens.border.withValues(alpha: .6),
                    strokeWidth: 0.6,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: yMax / 3,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        final n = NumberFormat.compact(
                          locale: 'en',
                        ).format(value);
                        return Text(
                          n,
                          textDirection: .ltr,
                          style: text.labelSmall?.copyWith(
                            color: tokens.textMuted,
                            fontSize: 9,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('MMM', 'ar').format(months[i].month),
                            style: text.labelSmall?.copyWith(
                              color: tokens.textMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colors.onSurface,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    getTooltipItem: (group, gi, rod, ri) {
                      final isIncome = ri == 0;
                      return BarTooltipItem(
                        '${isIncome ? "دخل" : "مصروف"}\n',
                        text.labelSmall!.copyWith(
                          color: colors.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                        children: [
                          TextSpan(
                            text: NumberFormat('#,##0', 'en').format(rod.toY),
                            style: text.labelMedium!.copyWith(
                              color: colors.surface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < months.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: months[i].income,
                          color: tokens.success,
                          width: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        BarChartRodData(
                          toY: months[i].expense,
                          color: colors.error,
                          width: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: context.tokens.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
