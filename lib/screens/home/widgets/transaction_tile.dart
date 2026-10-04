import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.perspectiveAccountId,
    this.currency,
    this.destinationCurrency,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final String? perspectiveAccountId;

  /// Source account currency (e.g. SAR).
  final String? currency;

  /// Destination account currency for transfers (e.g. YER).
  final String? destinationCurrency;

  bool get _effectiveIsIncome {
    final tx = transaction;
    if (tx.toAccountId != null && perspectiveAccountId != null) {
      if (perspectiveAccountId == tx.toAccountId) return true; // incoming
      if (perspectiveAccountId == tx.accountId) return false; // outgoing
    }
    return tx.isIncome;
  }

  bool get _isTransfer => transaction.toAccountId != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final isIncome = _effectiveIsIncome;
    final prefix = isIncome ? '+' : '-';
    final amount = NumberFormat('#,##0.00', 'en').format(transaction.amount);
    final displayAmount =
        transaction.isTransfer && transaction.destinationAmount != null
        ? [
            '${NumberFormat('#,##0.00', 'en').format(transaction.amount)} $currency',
            '${NumberFormat('#,##0.00', 'en').format(transaction.destinationAmount!)} $destinationCurrency',
          ]
        : ['$prefix$amount $currency'];

    final isTransfer = _isTransfer;

    // For transfers, use the arrow icon on the leading circle instead of
    // the income/expense color to make the direction obvious.
    final iconColor = isTransfer
        ? colors.primary
        : (transaction.isIncome ? tokens.success : colors.error);

    final amountColor = isIncome ? tokens.success : colors.error;

    final iconData = isTransfer ? Icons.swap_horiz_rounded : transaction.icon;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.sm + 2,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSizes.sm + 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                // Leading icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
                  ),
                  child: Icon(iconData, size: 20, color: iconColor),
                ),
                const SizedBox(width: AppSizes.sm + 4),

                // Title + category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        transaction.title,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.category,
                        style: text.labelSmall?.copyWith(
                          color: tokens.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),

                // Amount
                isTransfer
                    ? Column(
                        children: [
                          Text(
                            displayAmount[0],
                            style: text.bodySmall!.copyWith(
                              color: colors.error,
                              fontWeight: .w600,
                            ),
                            textDirection: .ltr,
                            //
                          ),
                          const SizedBox(height: 2),
                          Icon(Icons.arrow_downward_rounded, size: 12),
                          const SizedBox(height: 2),
                          Text(
                            displayAmount[1],
                            style: text.bodySmall!.copyWith(
                              color: tokens.success,
                              fontWeight: .w600,
                            ),
                            textDirection: .ltr,
                            //
                          ),
                        ],
                      )
                    : Text(
                        displayAmount[0],
                        style: text.titleSmall?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w700,
                        ),
                        textDirection: .ltr,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
