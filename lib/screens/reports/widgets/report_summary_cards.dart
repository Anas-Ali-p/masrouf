import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/report_data.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class ReportSummaryCards extends StatelessWidget {
  const ReportSummaryCards({
    super.key,
    required this.data,
    this.currency = 'SAR',
  });

  final ReportData data;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: _Card(
            label: 'الدخل',
            amount: data.income,
            currency: currency,
            color: tokens.success,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _Card(
            label: 'المصروف',
            amount: data.expense,
            currency: currency,
            color: context.colors.error,
            icon: Icons.trending_down_rounded,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _Card(
            label: 'الصافي',
            amount: data.net,
            currency: currency,
            color: data.net >= 0 ? tokens.success : context.colors.error,
            icon: Icons.account_balance_rounded,
            signed: true,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.label,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
    this.signed = false,
  });

  final String label;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final value = NumberFormat('#,##0', 'en').format(amount.abs());
    final prefix = signed ? (amount >= 0 ? '+' : '-') : '';

    return Container(
      padding: const EdgeInsets.all(8),
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
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$prefix$value',
                  textDirection: .ltr,
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.1,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 3),
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
          ),
        ],
      ),
    );
  }
}
