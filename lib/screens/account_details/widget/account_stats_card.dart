import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class AccountStatsCard extends StatelessWidget {
  const AccountStatsCard({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'دخل الشهر',
              amount: account.monthlyIncome,
              currency: account.currency,
              icon: Icons.trending_up_rounded,
              color: tokens.success,
            ),
          ),
          Container(width: 1, height: 48, color: tokens.border),
          Expanded(
            child: _Stat(
              label: 'مصروف الشهر',
              amount: account.monthlyExpense,
              currency: account.currency,
              icon: Icons.trending_down_rounded,
              color: colors.error,
              alignEnd: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.amount,
    required this.currency,
    required this.icon,
    required this.color,
    this.alignEnd = false,
  });

  final String label;
  final double amount;
  final String currency;
  final IconData icon;
  final Color color;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final tokens = context.tokens;
    final cross = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      child: Column(
        crossAxisAlignment: cross,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            textDirection: alignEnd ? .rtl : .ltr,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: text.labelSmall?.copyWith(
                  color: tokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                NumberFormat('#,##0.00', 'en').format(amount),
                textDirection: .ltr,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: text.labelSmall?.copyWith(
                  color: tokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
