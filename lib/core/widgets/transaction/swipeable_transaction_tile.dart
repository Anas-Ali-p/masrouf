import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/screens/home/widgets/transaction_tile.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class SwipeableTransactionTile extends ConsumerWidget {
  const SwipeableTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit, // ← triggered by start→end swipe
    this.currency,
    this.destinationCurrency,
  });

  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final String? currency;
  final String? destinationCurrency;

  // ── Delete confirmation dialog ────────────────────────
  Future<bool> _confirmDelete(BuildContext context) async {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final tx = transaction;

    final isTransfer = tx.isTransfer;
    final amountLabel = NumberFormat('#,##0.00', 'en').format(tx.amount);
    final sign = isTransfer ? '' : (tx.isIncome ? '+' : '-');
    final amountColor = isTransfer
        ? colors.primary
        : tx.isIncome
        ? tokens.success
        : colors.error;

    final dateLabel = DateFormat('EEEE، d MMMM yyyy', 'ar').format(tx.date);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: .12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: colors.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'حذف العملية',
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'لا يمكن التراجع عن هذا الإجراء',
                          style: text.labelSmall?.copyWith(
                            color: tokens.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: tokens.border.withValues(alpha: .35),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, false),
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Transaction preview
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tokens.border.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(
                    color: tokens.border.withValues(alpha: .5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (tx.iconColor ?? colors.primary).withValues(
                          alpha: .14,
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: Icon(
                        tx.icon,
                        size: 17,
                        color: tx.iconColor ?? colors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tx.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Text(
                                tx.category,
                                style: text.labelSmall?.copyWith(
                                  color: tokens.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                              Container(
                                width: 3,
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: tokens.textMuted.withValues(alpha: .6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  dateLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.labelSmall?.copyWith(
                                    color: tokens.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$sign$amountLabel',
                      textDirection: .ltr,
                      style: text.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Impact line
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 13,
                    color: tokens.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'سيتم إرجاع المبلغ إلى رصيد الحساب تلقائياً.',
                      style: text.labelSmall?.copyWith(
                        color: tokens.textMuted,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        foregroundColor: colors.onSurface,
                        side: BorderSide(color: tokens.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                        textStyle: text.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(42),
                        backgroundColor: colors.error,
                        foregroundColor: colors.onError,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                        textStyle: text.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline_rounded, size: 15),
                      label: const Text('حذف'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return ok ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Dismissible(
      key: ValueKey('tx-${transaction.id}'),
      direction: DismissDirection.horizontal,
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.40,
        DismissDirection.endToStart: 0.40,
      },

      // ── start → end (visual left→right in RTL) = EDIT
      background: _ActionBackground(
        alignment: AlignmentDirectional.centerStart,
        color: colors.primary,
        icon: Icons.edit_rounded,
        label: 'تعديل',
        textColor: colors.onPrimary,
      ),

      // ── end → start (visual right→left in RTL) = DELETE
      secondaryBackground: _ActionBackground(
        alignment: AlignmentDirectional.centerEnd,
        color: colors.error,
        icon: Icons.delete_outline_rounded,
        label: 'حذف',
        textColor: colors.onPrimary,
      ),

      // ── Decide what happens on release ────────────
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // EDIT side — never dismiss. Fire the callback and snap back.
          // Fall back to `onTap` if no `onEdit` was provided.
          (onEdit ?? onTap)?.call();
          return false;
        }

        // DELETE side — confirm, then dismiss
        return _confirmDelete(context);
      },

      // ── Runs after the tile is fully dismissed ────
      onDismissed: (_) async {
        try {
          await ref
              .read(transactionRepositoryProvider)
              .deleteTransaction(transaction.id);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text('تم حذف العملية'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: context.tokens.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                duration: const Duration(milliseconds: 1400),
                margin: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  0,
                  AppSizes.md,
                  AppSizes.md,
                ),
              ),
            );
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text('تعذر الحذف'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: colors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                duration: const Duration(milliseconds: 1800),
                margin: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  0,
                  AppSizes.md,
                  AppSizes.md,
                ),
              ),
            );
        }
      },

      child: TransactionTile(
        transaction: transaction,
        onTap: onTap,
        currency: currency,
        destinationCurrency: destinationCurrency,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  Swipe background
// ─────────────────────────────────────────────────────────

class _ActionBackground extends StatelessWidget {
  const _ActionBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
    required this.textColor,
  });

  final AlignmentGeometry alignment;
  final Color color;
  final IconData icon;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final text = context.text;

    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.sm + 2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      alignment: alignment,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: text.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
