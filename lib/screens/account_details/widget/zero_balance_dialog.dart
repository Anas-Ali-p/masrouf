import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

/// Shows the confirmation dialog. Returns `true` if the user confirmed.
Future<bool> confirmZeroBalance(
  BuildContext context, {
  required Account account,
}) async {
  final colors = context.colors;
  final text = context.text;
  final tokens = context.tokens;

  final isNegative = account.balance < 0;
  final amount = NumberFormat('#,##0.00', 'en').format(account.balance.abs());

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tokens.warning.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restart_alt_rounded,
              size: 20,
              color: tokens.warning,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تصفير رصيد الحساب',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('سيتم إنشاء عملية تسوية بقيمة:', style: text.bodyMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                Icon(
                  isNegative
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 18,
                  color: isNegative ? tokens.success : colors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  isNegative ? '+$amount' : '-$amount',
                  textDirection: .ltr,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isNegative ? tokens.success : colors.error,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  account.currency,
                  style: text.labelSmall?.copyWith(
                    color: tokens.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'يساوي صفر',
                  style: text.labelSmall?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: tokens.warning),
          child: const Text('تصفير'),
        ),
      ],
    ),
  );

  return result ?? false;
}
