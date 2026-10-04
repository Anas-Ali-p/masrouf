import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/models/transaction_detail.dart';
import 'package:masrouf_v2/screens/account_details/account_details_screen.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/screens/transaction_details/widgets/account_link_card.dart';
import 'package:masrouf_v2/screens/transaction_details/widgets/balance_timeline.dart';
import 'package:masrouf_v2/screens/transaction_details/widgets/detail_actions.dart';
import 'package:masrouf_v2/screens/transaction_details/widgets/detail_hero.dart';
import 'package:masrouf_v2/screens/transaction_details/widgets/details_list.dart';
import 'package:masrouf_v2/screens/transaction_details/widgets/notes_card.dart';
import 'package:masrouf_v2/screens/transaction_details/widgets/quick_info_row.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/providers/app_providers.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  const TransactionDetailsScreen({super.key, required this.detail});

  final TransactionDetail detail;

  void _openAccount(BuildContext context) {
    final account = detail.account;
    if (account == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AccountDetailsScreen(account: account)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final tx = detail.transaction;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 17,
                color: colors.error,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'حذف العملية؟',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سيتم حذف "${tx.title}" وتعديل رصيد الحساب تلقائياً.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'لا يمكن التراجع عن هذا الإجراء.',
              style: text.labelSmall?.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w600,
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
            style: TextButton.styleFrom(foregroundColor: colors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    try {
      await ref.read(transactionRepositoryProvider).deleteTransaction(tx.id);

      if (!context.mounted) return;

      // Pop the details screen — the underlying list updates via streams
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف العملية'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: tokens.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر الحذف: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final text = context.text;
    final tx = detail.transaction;

    // Build the details rows dynamically.
    final rows = <DetailRowData>[
      DetailRowData(
        icon: Icons.category_rounded,
        label: 'التصنيف',
        value: tx.category,
      ),
      DetailRowData(
        icon: Icons.swap_vert_rounded,
        label: 'النوع',
        value: tx.category == 'تحويل'
            ? 'تحويل'
            : tx.isIncome
            ? 'دخل'
            : 'مصروف',
        valueColor: tx.category == 'تحويل'
            ? context.colors.primary
            : tx.isIncome
            ? tokens.success
            : context.colors.error,
      ),
      DetailRowData(
        icon: Icons.attach_money_rounded,
        label: 'العملة',
        value: detail.currency,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top bar ────────────────────────────────────
            SliverToBoxAdapter(
              child: AppTopBar(
                showAvatar: false,
                title: 'تفاصيل العملية',
                leading: IconButton(
                  splashRadius: 22,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            ),

            // ── Hero ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.md,
                  0,
                ),
                child: DetailHero(
                  transaction: tx,
                  sourceAccount: detail.account,
                  destinationAccount: detail.toAccount,
                ),
              ),
            ),

            // ── Quick info ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  AppSizes.sm + 2,
                  AppSizes.md,
                  0,
                ),
                child: QuickInfoRow(date: tx.date, reference: detail.reference),
              ),
            ),

            // ── Account link ───────────────────────────────
            if (detail.account != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSizes.md,
                    AppSizes.sm + 2,
                    AppSizes.md,
                    0,
                  ),
                  child: AccountLinkCard(
                    account: detail.account!,
                    onTap: () => _openAccount(context),
                  ),
                ),
              ),

            // ── Balance timeline ───────────────────────────
            if (detail.hasBalanceHistory)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSizes.md,
                    AppSizes.sm + 2,
                    AppSizes.md,
                    0,
                  ),
                  child: BalanceTimeline(
                    before: detail.balanceBefore!,
                    after: detail.balanceAfter!,
                    currency: detail.currency,
                  ),
                ),
              ),

            // ── Details list ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  AppSizes.sm + 2,
                  AppSizes.md,
                  0,
                ),
                child: DetailsList(rows: rows),
              ),
            ),

            // ── Notes ──────────────────────────────────────
            if (detail.note != null && detail.note!.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSizes.md,
                    AppSizes.sm + 2,
                    AppSizes.md,
                    0,
                  ),
                  child: NotesCard(note: detail.note!),
                ),
              ),

            // ── Actions ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.md,
                ),
                child: DetailActions(
                  onEdit: () async {
                    final updated = await showAddTransactionSheet(
                      context,
                      existing: detail.transaction,
                    );
                    if (updated == true && context.mounted) {
                      // The providers emit the new row automatically — pop back
                      // so the details screen doesn't show stale data.
                      Navigator.pop(context);
                    }
                  },
                  onShare: () {
                    // TODO: share summary
                  },
                  onDelete: () => _confirmDelete(context, ref),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }
}
