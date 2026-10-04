import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/core/widgets/transaction/swipeable_transaction_tile.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/transaction_detail.dart';
import 'package:masrouf_v2/providers/accounts_provider.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/providers/transactions_provider.dart';
import 'package:masrouf_v2/screens/account_details/account_details_screen.dart';
import 'package:masrouf_v2/screens/add_account/add_account_sheet.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/screens/home/widgets/account_card.dart';
import 'package:masrouf_v2/screens/home/widgets/add_account_card.dart';
import 'package:masrouf_v2/screens/home/widgets/home_skeletons.dart';
import 'package:masrouf_v2/screens/home/widgets/section_title.dart';
import 'package:masrouf_v2/screens/home/widgets/transaction_tile.dart';
import 'package:masrouf_v2/screens/transaction_details/transaction_details_screen.dart';
import 'package:masrouf_v2/screens/transactions/transactions_screen.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير';
    return 'مساء الخير';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    // Live data
    final accountsAsync = ref.watch(accountsProvider);
    final recentAsync = ref.watch(recentTransactionsProvider(10));
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final hideBalances = settings?.hideBalances ?? false;
    final accounts = accountsAsync.valueOrNull ?? [];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top bar ────────────────────────────────────
            SliverToBoxAdapter(
              child: AppTopBar(
                subtitle: _greeting(),
                title: 'أحمد',
                onAvatarTap: () {
                  // TODO: open profile
                },
                actions: [
                  AppTopBarIconButton(
                    icon: Icons.notifications_none_rounded,
                    showDot: true,
                    onTap: () {
                      // TODO: open notifications
                    },
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),

            // ── Accounts grid ──────────────────────────────
            ...accountsAsync.when(
              loading: () => const [
                SliverToBoxAdapter(child: AccountsSkeleton()),
              ],
              error: (e, _) => [
                SliverToBoxAdapter(
                  child: _ErrorBox(
                    message: 'تعذر تحميل الحسابات',
                    onRetry: () => ref.invalidate(accountsProvider),
                  ),
                ),
              ],
              data: (accounts) => [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSizes.sm + 4,
                          crossAxisSpacing: AppSizes.sm + 4,
                          mainAxisExtent: 70,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      // Last tile = "add account"
                      if (index == accounts.length) {
                        return AddAccountCard(
                          onTap: () => showAddAccountSheet(context),
                        );
                      }
                      final account = accounts[index];
                      return AccountCard(
                        account: account,
                        hideBalance: hideBalances,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AccountDetailsScreen(account: account),
                            ),
                          );
                        },
                      );
                    }, childCount: accounts.length + 1),
                  ),
                ),
              ],
            ),

            // ── Section title ──────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  AppSizes.lg,
                  AppSizes.md,
                  AppSizes.sm + 2,
                ),
                child: SectionTitle(title: 'آخر العمليات'),
              ),
            ),

            // ── Recent transactions ────────────────────────
            ...recentAsync.when(
              loading: () => const [
                SliverToBoxAdapter(child: TransactionsSkeleton()),
              ],
              error: (e, _) => [
                SliverToBoxAdapter(
                  child: _ErrorBox(
                    message: 'تعذر تحميل العمليات',
                    onRetry: () => ref.invalidate(allTransactionsProvider),
                  ),
                ),
              ],
              data: (transactions) {
                if (transactions.isEmpty) {
                  return [
                    SliverToBoxAdapter(
                      child: _EmptyTransactions(
                        onAdd: () => showAddTransactionSheet(context),
                      ),
                    ),
                  ];
                }
                return [
                  SliverList.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, i) {
                      final tx = transactions[i];
                      final source = accounts
                          .where((a) => a.id == tx.accountId)
                          .firstOrNull;
                      final destination = tx.toAccountId == null
                          ? null
                          : accounts
                                .where((a) => a.id == tx.toAccountId)
                                .firstOrNull;
                      return SwipeableTransactionTile(
                        currency: source?.currency,
                        destinationCurrency: destination?.currency,
                        transaction: tx,
                        onTap: () {
                          // Look up the account for this transaction
                          final accounts = accountsAsync.valueOrNull ?? [];
                          final source = accounts
                              .where((a) => a.id == tx.accountId)
                              .firstOrNull;
                          final destination = tx.toAccountId == null
                              ? null
                              : accounts
                                    .where((a) => a.id == tx.toAccountId)
                                    .firstOrNull;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailsScreen(
                                detail: TransactionDetail(
                                  transaction: tx,
                                  account: source,
                                  toAccount: destination, // ← new
                                ),
                              ),
                            ),
                          );
                        },
                        onEdit: () =>
                            showAddTransactionSheet(context, existing: tx),
                      );
                    },
                  ),
                ];
              },
            ),

            // ── See all ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.lg,
                ),
                child: Center(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        22,
                        12,
                        18,
                        12,
                      ),
                      shape: const StadiumBorder(),
                      side: BorderSide(color: tokens.border),
                      foregroundColor: context.colors.primary,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('عرض كل العمليات'),
                        SizedBox(width: 6),
                        Icon(Icons.chevron_right_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}

// ── Inline helper widgets ────────────────────────────────

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colors.error.withValues(alpha: .35)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20, color: colors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: text.bodyMedium?.copyWith(color: tokens.textMuted),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: colors.primary),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.lg,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: tokens.border),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 26,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.sm + 4),
            Text(
              'لا توجد عمليات بعد',
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'ابدأ بإضافة أول عملية لك',
              style: text.labelSmall?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: AppSizes.md),
            TextButton.icon(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('إضافة عملية'),
            ),
          ],
        ),
      ),
    );
  }
}
