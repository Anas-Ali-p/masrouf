import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/day_group.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class DayGroupHeader extends StatelessWidget {
  const DayGroupHeader({super.key, required this.group});

  final DayGroup group;

  String _label(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(day.year, day.month, day.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    return DateFormat('EEEE، d MMMM', 'ar').format(day);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final totals = group.totalsByCurrency;
    final sortedCurrencies = totals.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.md,
        AppSizes.sm + 2,
        AppSizes.md,
        AppSizes.xs + 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Day + count
          Text(
            _label(group.day),
            style: text.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: tokens.border.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${group.items.length}',
              style: text.labelSmall?.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Per-currency totals — wrapped so they stay readable
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 2,
              children: [
                for (final c in sortedCurrencies)
                  _total(context, totals[c]!, c),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _total(BuildContext context, double value, String currency) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final positive = value >= 0;
    final color = positive ? tokens.success : colors.error;
    final prefix = positive ? '+' : '-';
    final label = NumberFormat('#,##0.00', 'en').format(value.abs());

    return RichText(
      textDirection: .ltr,
      text: TextSpan(
        style: text.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: color,
        ),
        children: [
          TextSpan(text: '$prefix$label '),
          TextSpan(
            text: currency,
            style: TextStyle(
              color: tokens.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
