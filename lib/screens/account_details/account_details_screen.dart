import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/transaction/swipeable_transaction_tile.dart';
import 'package:masrouf_v2/data/demo_data.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/account_filter.dart';
import 'package:masrouf_v2/models/new_transaction.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/providers/accounts_provider.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/providers/transactions_provider.dart';
import 'package:masrouf_v2/screens/account_details/widget/account_filter_sheet.dart';
import 'package:masrouf_v2/screens/account_details/widget/account_hero.dart';
import 'package:masrouf_v2/screens/account_details/widget/account_quick_actions.dart';
import 'package:masrouf_v2/screens/account_details/widget/account_stats_card.dart';
import 'package:masrouf_v2/screens/account_details/widget/transactions_header.dart';
import 'package:masrouf_v2/screens/account_details/widget/zero_balance_dialog.dart';
import 'package:masrouf_v2/screens/add_account/add_account_sheet.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/models/transaction_detail.dart';
import 'package:masrouf_v2/screens/reports/reports_screen.dart';
import 'package:masrouf_v2/screens/transaction_details/transaction_details_screen.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/app_snackbar.dart';
import 'package:masrouf_v2/utils/pdf/account_statment_pdf.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:uuid/uuid.dart';

class AccountDetailsScreen extends ConsumerStatefulWidget {
  const AccountDetailsScreen({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  late List<Transaction> _transactions;
  AccountFilter _filter = const AccountFilter(); // was TransactionFilter
  Account get _account => widget.account;

  List<String> get _availableCategories =>
      _transactions.map((t) => t.category).toSet().toList()..sort();

  @override
  void initState() {
    super.initState();
    _transactions = demoTransactions
        .where((t) => t.accountId == _account.id)
        .toList();
  }

  // ── Actions ────────────────────────────────────────────

  Future<void> _openAdd({TransactionType? type}) async {
    await showAddTransactionSheet(
      context,
      accountId: _account.id,
      initialType: type,
    );
  }

  Future<void> _openEdit() async {
    final updated = await showAddAccountSheet(context, existing: _account);
    if (updated == true && mounted) {
      // The accounts stream will emit the change — pop back to home
      // so we don't show a stale account object.
      Navigator.pop(context);
    }
  }

  Future<void> _openFilters() async {
    final result = await showAccountFilterSheet(
      context,
      current: _filter,
      availableCategories: _availableCategories,
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  Future<void> _zeroBalance() async {
    final confirmed = await confirmZeroBalance(context, account: _account);
    if (!confirmed || !mounted) return;

    final isNegative = _account.balance < 0;

    try {
      final tx = Transaction(
        id: const Uuid().v4(),
        title: 'تصفير الرصيد',
        category: 'تسوية',
        amount: _account.balance.abs(),
        date: DateTime.now(),
        icon: Icons.restart_alt_rounded,
        iconColor: context.tokens.warning,
        isIncome: isNegative,
        accountId: _account.id,
      );

      await ref.read(transactionRepositoryProvider).addTransaction(tx);

      if (!mounted) return;
      showAppSnack(
        context,
        message: 'تم تصفير الرصيد بنجاح',
        kind: SnackKind.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnack(
        context,
        message: 'تعذر التصفير : $e',
        kind: SnackKind.error,
      );
    }
  }

  Future<void> _exportPdf() async {
    // Show blocking loader so the user knows something is happening.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await exportAccountStatement(
        account: _account,
        // Export the FULL list, not the filtered view — users expect the
        // statement to be complete.
        transactions: _transactions,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر إنشاء الملف: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // close loader
      }
    }
  }

  void _openReports() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ReportsScreen(account: _account)));
  }

  // ── Build ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(accountByIdProvider(_account.id));
    final tokens = context.tokens;
    final txAsync = ref.watch(
      transactionsInvolvingAccountProvider(_account.id),
    );
    final txList = txAsync.valueOrNull ?? [];
    final filtered = txList.where(_filter.matches).toList();
    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.valueOrNull ?? [];

    return accountAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (account) {
        if (account == null) {
          return const Scaffold(body: Center(child: Text('الحساب غير موجود')));
        }
        // ...rest of build using `account` instead of `_account`
        return Scaffold(
          // ── FAB: add transaction ────────────────────────────
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAdd(),
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            elevation: 4,
            mini: true,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top bar ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: AppTopBar(
                    showAvatar: false,
                    title: _account.name,
                    leading: IconButton(
                      splashRadius: 22,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: AppSizes.iconSm,
                        ),
                        onPressed: _openEdit,
                      ),
                    ],
                  ),
                ),

                // ── Hero card ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSizes.md,
                      AppSizes.sm,
                      AppSizes.md,
                      AppSizes.md,
                    ),
                    child: AccountHero(account: _account),
                  ),
                ),

                // ── Quick actions ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                    ),
                    child: AccountQuickActions(
                      onTransfer: () =>
                          _openAdd(type: TransactionType.transfer),
                      onZeroBalance: _zeroBalance,
                      onExportPdf: _exportPdf,
                      onReports: _openReports,
                    ),
                  ),
                ),

                // ── Month stats ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSizes.md,
                      AppSizes.md,
                      AppSizes.md,
                      0,
                    ),
                    child: AccountStatsCard(account: _account),
                  ),
                ),

                // ── Optional note ───────────────────────────────
                if (_account.note != null && _account.note!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSizes.md,
                        AppSizes.md,
                        AppSizes.md,
                        0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSizes.md),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                          border: Border.all(color: tokens.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 18,
                              color: tokens.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _account.note!,
                                style: context.text.bodyMedium?.copyWith(
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Sticky section header + filters ───────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: TransactionsHeaderDelegate(
                    backgroundColor: context.colors.surface,
                    borderColor: tokens.border,
                    child: TransactionsHeader(
                      count: filtered.length,
                      filter: _filter,
                      onEdit: _openFilters,
                      onClearType: () =>
                          setState(() => _filter = _filter.copyWith(types: {})),
                      onClearDate: () => setState(
                        () => _filter = _filter.copyWith(
                          datePreset: DateRangePreset.all,
                          clearCustomRange: true,
                        ),
                      ),
                      onClearCategories: () => setState(
                        () => _filter = _filter.copyWith(categoryIds: {}),
                      ),
                      onClearAll: () =>
                          setState(() => _filter = const AccountFilter()),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.sm)),
                // ── Transactions list ───────────────────────────
                if (filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 32,
                              color: tokens.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'لا توجد عمليات مطابقة',
                              style: context.text.bodySmall?.copyWith(
                                color: tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final tx = filtered[i];
                      final source = tx.accountId == _account.id
                          ? _account
                          : accounts
                                .where((a) => a.id == tx.accountId)
                                .firstOrNull;
                      final destination = tx.toAccountId == null
                          ? null
                          : (tx.toAccountId == _account.id
                                ? _account
                                : accounts
                                      .where((a) => a.id == tx.toAccountId)
                                      .firstOrNull);

                      return SwipeableTransactionTile(
                        transaction: tx,
                        currency: source?.currency,
                        destinationCurrency: destination?.currency,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailsScreen(
                                detail: TransactionDetail(
                                  transaction: tx,
                                  account: source,
                                  toAccount: destination,
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
                // ── Bottom spacer (leaves room for the FAB) ─────
                const SliverToBoxAdapter(child: SizedBox(height: 35)),
              ],
            ),
          ),
        );
      },
    );
  }
}
