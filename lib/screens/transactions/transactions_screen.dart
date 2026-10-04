import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/account_filter.dart';
import 'package:masrouf_v2/models/day_group.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/models/transaction_detail.dart';
import 'package:masrouf_v2/providers/accounts_provider.dart';
import 'package:masrouf_v2/providers/transactions_provider.dart';
import 'package:masrouf_v2/screens/account_details/widget/account_filter_sheet.dart';
import 'package:masrouf_v2/screens/account_details/widget/active_filters_bar.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/screens/transaction_details/transaction_details_screen.dart';
import 'package:masrouf_v2/screens/transactions/widgets/day_group_header.dart';
import 'package:masrouf_v2/screens/transactions/widgets/empty_transactions.dart';
import 'package:masrouf_v2/screens/transactions/widgets/transaction_search_field.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/core/widgets/transaction/swipeable_transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  AccountFilter _filter = const AccountFilter();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilters(List<String> categories) async {
    final result = await showAccountFilterSheet(
      context,
      current: _filter,
      availableCategories: categories,
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  List<DayGroup> _buildGroups(
    List<Transaction> source,
    List<Account> accounts,
  ) {
    // accountId → currency lookup
    final currencies = <String, String>{
      for (final a in accounts) a.id: a.currency,
    };

    final filtered = source.where((t) {
      if (!_filter.matches(t)) return false;
      if (_query.isNotEmpty) {
        final q = _query.trim().toLowerCase();
        return t.title.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q);
      }
      return true;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    final map = <DateTime, List<Transaction>>{};
    for (final t in filtered) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      map.putIfAbsent(key, () => []).add(t);
    }

    return map.entries.map((e) {
      final totals = <String, double>{};
      for (final t in e.value) {
        final srcCur = currencies[t.accountId] ?? 'SAR';

        if (t.isTransfer && t.toAccountId != null) {
          // Source loses
          totals[srcCur] = (totals[srcCur] ?? 0) - t.amount;
          // Destination gains
          final dstCur = currencies[t.toAccountId] ?? srcCur;
          final dstAmt = t.destinationAmount ?? t.amount;
          totals[dstCur] = (totals[dstCur] ?? 0) + dstAmt;
        } else {
          final delta = t.isIncome ? t.amount : -t.amount;
          totals[srcCur] = (totals[srcCur] ?? 0) + delta;
        }
      }
      return DayGroup(day: e.key, items: e.value, totalsByCurrency: totals);
    }).toList()..sort((a, b) => b.day.compareTo(a.day));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final hasActiveFilter = !_filter.isEmpty;

    final txAsync = ref.watch(allTransactionsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.valueOrNull ?? [];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: txAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (allTx) {
            final categories = allTx.map((t) => t.category).toSet().toList()
              ..sort();
            final groups = _buildGroups(allTx, accounts);
            final total = groups.fold<int>(0, (s, g) => s + g.items.length);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top bar ────────────────────────────
                SliverToBoxAdapter(
                  child: AppTopBar(
                    showAvatar: false,
                    subtitle: 'سجل كامل',
                    title: 'العمليات',
                    leading: canPop
                        ? IconButton(
                            splashRadius: 22,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                          )
                        : null,
                    actions: [
                      AppTopBarIconButton(
                        icon: Icons.tune_rounded,
                        showDot: hasActiveFilter,
                        onTap: () => _openFilters(categories),
                      ),
                    ],
                  ),
                ),

                // ── Search ─────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSizes.md,
                      AppSizes.sm,
                      AppSizes.md,
                      AppSizes.sm,
                    ),
                    child: TransactionSearchField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),

                // ── Active filter chips ────────────────
                if (hasActiveFilter)
                  SliverToBoxAdapter(
                    child: ActiveFiltersBar(
                      filter: _filter,
                      onEdit: () => _openFilters(categories),
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

                // ── Result count ───────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSizes.md,
                      0,
                      AppSizes.md,
                      AppSizes.sm,
                    ),
                    child: Text(
                      '$total عملية',
                      style: context.text.labelSmall?.copyWith(
                        color: tokens.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // ── Grouped list ───────────────────────
                if (groups.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyTransactions(),
                  )
                else
                  for (final g in groups) ...[
                    SliverToBoxAdapter(child: DayGroupHeader(group: g)),
                    SliverList.builder(
                      itemCount: g.items.length,
                      itemBuilder: (context, i) {
                        final tx = g.items[i];
                        final source = accounts
                            .where((a) => a.id == tx.accountId)
                            .firstOrNull;
                        final destination = tx.toAccountId == null
                            ? null
                            : accounts
                                  .where((a) => a.id == tx.toAccountId)
                                  .firstOrNull;
                        return SwipeableTransactionTile(
                          transaction: tx,
                          currency: source?.currency,
                          destinationCurrency: destination?.currency,
                          onEdit: () =>
                              showAddTransactionSheet(context, existing: tx),
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
                        );
                      },
                    ),
                  ],

                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            );
          },
        ),
      ),
    );
  }
}
