import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/account_filter.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/providers/transactions_provider.dart';
import 'package:masrouf_v2/screens/account_details/widget/account_filter_sheet.dart';
import 'package:masrouf_v2/screens/account_details/widget/active_filters_bar.dart';
import 'package:masrouf_v2/screens/reports/report_builder.dart';
import 'package:masrouf_v2/screens/reports/widgets/category_donut_card.dart';
import 'package:masrouf_v2/screens/reports/widgets/monthly_trend_card.dart';
import 'package:masrouf_v2/screens/reports/widgets/report_summary_cards.dart';
import 'package:masrouf_v2/screens/reports/widgets/top_categories_card.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/pdf/report_pdf.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, this.account});
  final Account? account;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  AccountFilter _filter = const AccountFilter();
  bool _exporting = false;

  String get _currency => widget.account?.currency ?? 'SAR';

  List<Transaction> _apply(List<Transaction> source) {
    final scoped = widget.account == null
        ? source
        : source.where((t) => t.accountId == widget.account!.id).toList();
    return scoped.where(_filter.matches).toList();
  }

  DateTimeRange _effectiveRange(List<Transaction> tx) {
    final presetRange = _filter.datePreset == DateRangePreset.all
        ? null
        : (_filter.datePreset == DateRangePreset.custom
              ? _filter.customRange
              : _filter.datePreset.resolve());

    if (presetRange != null) return presetRange;

    if (tx.isEmpty) {
      final now = DateTime.now();
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(
          now.year,
          now.month + 1,
          1,
        ).subtract(const Duration(seconds: 1)),
      );
    }
    final sorted = [...tx]..sort((a, b) => a.date.compareTo(b.date));
    return DateTimeRange(start: sorted.first.date, end: sorted.last.date);
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

  Future<void> _export(List<Transaction> tx) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final data = ReportBuilder.build(
        transactions: tx,
        range: _effectiveRange(tx),
      );
      await exportReport(
        data: data,
        periodLabel: _filter.isEmpty ? 'كل الفترات' : _filter.datePreset.label,
        currency: _currency,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر إنشاء التقرير: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    final txAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: txAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (all) {
            final scoped = widget.account == null
                ? all
                : all.where((t) => t.accountId == widget.account!.id).toList();
            final categories = scoped.map((t) => t.category).toSet().toList()
              ..sort();
            final tx = _apply(all);
            final data = ReportBuilder.build(
              transactions: tx,
              range: _effectiveRange(tx),
            );

            final subtitle = widget.account != null
                ? widget.account!.name
                : 'كل الحسابات';

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: AppTopBar(
                    showAvatar: false,
                    subtitle: subtitle,
                    title: 'التقارير',
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
                        showDot: !_filter.isEmpty,
                        onTap: () => _openFilters(categories),
                      ),
                      const SizedBox(width: 4),
                      _exporting
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : AppTopBarIconButton(
                              icon: Icons.picture_as_pdf_rounded,
                              onTap: () => _export(tx),
                            ),
                    ],
                  ),
                ),

                if (!_filter.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSizes.sm),
                      child: ActiveFiltersBar(
                        filter: _filter,
                        onEdit: () => _openFilters(categories),
                        onClearType: () => setState(
                          () => _filter = _filter.copyWith(types: {}),
                        ),
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

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                    ),
                    child: ReportSummaryCards(data: data, currency: _currency),
                  ),
                ),

                if (data.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.bar_chart_rounded,
                              size: 32,
                              color: tokens.textMuted,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _filter.isEmpty
                                  ? 'لا توجد بيانات لعرضها'
                                  : 'لا توجد بيانات مطابقة للفلتر',
                              style: context.text.labelMedium?.copyWith(
                                color: tokens.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSizes.md,
                        AppSizes.sm,
                        AppSizes.md,
                        0,
                      ),
                      child: CategoryDonutCard(
                        slices: data.categories,
                        currency: _currency,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSizes.md,
                        AppSizes.sm,
                        AppSizes.md,
                        0,
                      ),
                      child: MonthlyTrendCard(
                        months: data.months,
                        currency: _currency,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSizes.md,
                        AppSizes.sm,
                        AppSizes.md,
                        0,
                      ),
                      child: TopCategoriesCard(
                        slices: data.categories,
                        currency: _currency,
                      ),
                    ),
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
