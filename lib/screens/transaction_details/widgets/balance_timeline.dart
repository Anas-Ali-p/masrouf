import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class BalanceTimeline extends StatelessWidget {
  const BalanceTimeline({
    super.key,
    required this.before,
    required this.after,
    required this.currency,
  });

  final double before;
  final double after;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final delta = after - before;
    final isUp = delta >= 0;
    final deltaColor = isUp ? tokens.success : colors.error;
    final fmt = NumberFormat('#,##0.00', 'en');

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 14, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'تأثير العملية على الرصيد',
                style: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Row: before | line | after
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Before
              Expanded(
                child: _side(
                  context,
                  label: 'قبل العملية',
                  amount: before,
                  currency: currency,
                  color: colors.onSurface,
                  align: CrossAxisAlignment.start,
                ),
              ),

              // Middle connector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    const SizedBox(height: 14),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dot(colors.primary),
                        Container(width: 40, height: 2, color: tokens.border),
                        _dot(colors.primary),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: deltaColor.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isUp
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 10,
                            color: deltaColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            fmt.format(delta.abs()),
                            textDirection: .ltr,
                            style: text.labelSmall?.copyWith(
                              color: deltaColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // After
              Expanded(
                child: _side(
                  context,
                  label: 'بعد العملية',
                  amount: after,
                  currency: currency,
                  color: deltaColor,
                  align: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 1.5),
      boxShadow: [
        BoxShadow(color: color.withValues(alpha: .35), blurRadius: 6),
      ],
    ),
  );

  Widget _side(
    BuildContext context, {
    required String label,
    required double amount,
    required String currency,
    required Color color,
    required CrossAxisAlignment align,
  }) {
    final text = context.text;
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: align,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: text.labelSmall?.copyWith(
            color: tokens.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat('#,##0.00', 'en').format(amount),
          textDirection: .ltr,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          currency,
          style: text.labelSmall?.copyWith(
            color: tokens.textMuted,
            letterSpacing: 0.4,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
