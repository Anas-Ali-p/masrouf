import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/category.dart';
import 'package:masrouf_v2/models/new_transaction.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/providers/accounts_provider.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/screens/add_transaction/widgets/amount_field.dart';
import 'package:masrouf_v2/screens/add_transaction/widgets/amount_in_words.dart';
import 'package:masrouf_v2/screens/add_transaction/widgets/category_picker_sheet.dart';
import 'package:masrouf_v2/screens/add_transaction/widgets/compact_chip.dart';
import 'package:masrouf_v2/screens/add_transaction/widgets/type_selector.dart';
import 'package:masrouf_v2/screens/settings/screens/exchange_rates_screen.dart';
import 'package:masrouf_v2/services/widget_service.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/thousands_formatter.dart';
import 'package:uuid/uuid.dart';

Future<bool?> showAddTransactionSheet(
  BuildContext context, {
  String? accountId,
  TransactionType? initialType,
  Transaction? existing,
  bool useBackdropBlur = true,
}) {
  WidgetBuilder builder = (sheetContext) {
    final sheet = Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
        color: context.colors.surface,
      ),
      child: AddTransactionSheet(
        initialAccountId: accountId,
        initialType: initialType,
        existing: existing,
      ),
    );

    if (!useBackdropBlur) return sheet;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: sheet,
    );
  };

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface.withValues(alpha: 0),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: builder,
  );
}

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({
    super.key,
    this.initialAccountId,
    this.initialType,
    this.existing,
  });

  final String? initialAccountId;
  final TransactionType? initialType;
  final Transaction? existing;

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late NewTransactionDraft _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final e = widget.existing;
    if (e != null) {
      final isTransfer = e.toAccountId != null;
      final type = isTransfer
          ? TransactionType.transfer
          : e.isIncome
          ? TransactionType.income
          : TransactionType.expense;

      // The category list depends on type, so resolve the label
      // against the correct list.
      final list = type == TransactionType.income
          ? kIncomeCategories
          : kExpenseCategories;
      final matched = list.where((c) => c.label == e.category).firstOrNull;

      _draft = NewTransactionDraft(
        type: type,
        amount: e.amount,
        categoryId: matched?.id,
        accountId: e.accountId,
        toAccountId: e.toAccountId,
        date: e.date,
      );

      _amountController.text = NumberFormat('#,##0.00', 'en').format(e.amount);

      // If the title differs from the category label, treat it as a note.
      if (e.title != e.category) {
        _noteController.text = e.title;
      }
    } else {
      _draft = NewTransactionDraft(
        type: widget.initialType ?? TransactionType.expense,
        accountId: widget.initialAccountId,
        date: DateTime.now(),
      );
    }

    _amountController.addListener(_syncAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_syncAmount);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Amount sync ────────────────────────────────────────
  void _syncAmount() {
    final n = parseFormattedAmount(_amountController.text);
    if (n != _draft.amount) {
      setState(() => _draft = _draft.copyWith(amount: n));
    }
  }

  Widget _conversionPreview(
    BuildContext context, {
    required AppSettingsState? settings,
    required Account source,
    required Account destination,
  }) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    if (settings == null || _draft.amount <= 0) {
      return const SizedBox.shrink();
    }

    final converted = settings.convert(
      _draft.amount,
      source.currency,
      destination.currency,
    );

    if (converted == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExchangeRatesScreen()),
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.warning.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(
                  color: tokens.warning.withValues(alpha: .35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: tokens.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لم يتم ضبط سعر الصرف بين '
                      '${source.currency} و ${destination.currency}',
                      style: text.labelSmall?.copyWith(
                        color: tokens.warning,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    'اضبط',
                    style: text.labelSmall?.copyWith(
                      color: tokens.warning,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final convertedLabel = NumberFormat('#,##0.00', 'en').format(converted);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: colors.primary.withValues(alpha: .20)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.currency_exchange_rounded,
              size: 15,
              color: colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'يستلم $convertedLabel ${destination.currency}',
                style: text.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            Text(
              '1 ${source.currency} = ${_rateLabel(settings, source.currency, destination.currency)} ${destination.currency}',
              textDirection: .ltr,
              style: text.labelSmall?.copyWith(
                color: colors.primary.withValues(alpha: .8),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rateLabel(AppSettingsState settings, String from, String to) {
    final fromRate = from == settings.currency
        ? 1.0
        : settings.exchangeRates[from] ?? 1.0;
    final toRate = to == settings.currency
        ? 1.0
        : settings.exchangeRates[to] ?? 1.0;
    final rate = fromRate / toRate;
    if (rate == rate.roundToDouble()) return rate.toInt().toString();
    return rate.toStringAsFixed(4);
  }

  // ── Categories for the current type ────────────────────
  List<TransactionCategory> get _categories =>
      _draft.type == TransactionType.income
      ? kIncomeCategories
      : kExpenseCategories;

  TransactionCategory? get _selectedCategory {
    if (_draft.categoryId == null) return null;
    return _categories.firstWhere(
      (c) => c.id == _draft.categoryId,
      orElse: () => _categories.last,
    );
  }

  IconData get _icon {
    if (_draft.type == TransactionType.transfer) {
      return Icons.swap_horiz_rounded;
    }
    return _selectedCategory?.icon ??
        (_draft.type == TransactionType.income
            ? Icons.trending_up_rounded
            : Icons.trending_down_rounded);
  }

  Color? get _iconColor =>
      _draft.type == TransactionType.transfer ? null : _selectedCategory?.color;

  String get _categoryLabel {
    if (_draft.type == TransactionType.transfer) return 'تحويل';
    return _selectedCategory?.label ?? 'أخرى';
  }

  // ── Type change ────────────────────────────────────────
  void _onTypeChanged(TransactionType t) {
    setState(() {
      _draft = NewTransactionDraft(
        type: t,
        amount: _draft.amount,
        accountId: _draft.accountId,
        toAccountId: t == TransactionType.transfer ? _draft.toAccountId : null,
        date: _draft.date,
        note: _draft.note,
      );
    });
  }

  // ── Swap Accountds  ────────────────────────────────────────
  void _swapAccounts() {
    setState(() {
      _draft = NewTransactionDraft(
        type: _draft.type,
        amount: _draft.amount,
        categoryId: _draft.categoryId,
        accountId: _draft.toAccountId,
        toAccountId: _draft.accountId,
        date: _draft.date,
        note: _draft.note,
      );
    });
  }

  // ── Pickers ────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _draft.date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _draft = _draft.copyWith(date: picked));
    }
  }

  Future<void> _pickCategory() async {
    final picked = await showCategoryPicker(
      context,
      categories: _categories,
      selectedId: _draft.categoryId,
    );
    if (picked != null) {
      setState(() => _draft = _draft.copyWith(categoryId: picked.id));
    }
  }

  Future<void> _pickAccount({
    required bool isDestination,
    required List<Account> accounts,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (_) => _AccountPickerSheet(
        accounts: accounts,
        selectedId: isDestination ? _draft.toAccountId : _draft.accountId,
        excludedId: isDestination
            ? _draft.accountId
            : (_draft.type == TransactionType.transfer
                  ? _draft.toAccountId
                  : null),
      ),
    );
    if (selected == null) return;
    setState(() {
      _draft = isDestination
          ? _draft.copyWith(toAccountId: selected)
          : _draft.copyWith(accountId: selected);
    });
  }

  // ── Save ───────────────────────────────────────────────
  Future<void> _save() async {
    if (_saving || !_draft.isValid) return;

    setState(() => _saving = true);

    try {
      final existing = widget.existing;
      final note = _noteController.text.trim();

      // ── Compute destination amount for transfers ──────
      double? destinationAmount;
      if (_draft.type == TransactionType.transfer) {
        final accounts =
            ref.read(accountsProvider).valueOrNull ?? const <Account>[];
        final source = accounts
            .where((a) => a.id == _draft.accountId)
            .firstOrNull;
        final destination = accounts
            .where((a) => a.id == _draft.toAccountId)
            .firstOrNull;

        if (source != null && destination != null) {
          if (source.currency == destination.currency) {
            // Same currency → 1:1
            destinationAmount = _draft.amount;
          } else {
            // Cross-currency → use exchange rates
            final settings = ref.read(appSettingsProvider).valueOrNull;
            destinationAmount = settings?.convert(
              _draft.amount,
              source.currency,
              destination.currency,
            );
          }
        }
      }

      // ── Build the transaction ─────────────────────────
      final tx = Transaction(
        id: existing?.id ?? const Uuid().v4(),
        title: note.isNotEmpty ? note : _categoryLabel,
        category: _categoryLabel,
        amount: _draft.amount,
        destinationAmount: destinationAmount, // ← stored on the row
        date: _draft.date ?? DateTime.now(),
        icon: _icon,
        iconColor: _iconColor,
        isIncome: _draft.type == TransactionType.income,
        accountId: _draft.accountId!,
        toAccountId: _draft.type == TransactionType.transfer
            ? _draft.toAccountId
            : null,
      );

      // ── Persist ───────────────────────────────────────
      final repo = ref.read(transactionRepositoryProvider);
      if (existing == null) {
        await repo.addTransaction(tx);
      } else {
        await repo.updateTransaction(tx);
      }

      // Keep installed Android widgets synchronized with the database.
      // Widget refresh must never turn a successful transaction into a
      // perceived save failure, so sync errors are isolated.
      try {
        final accounts = await ref
            .read(accountRepositoryProvider)
            .watchAll()
            .first;
        await WidgetService.updateAllWidgets(accounts: accounts);
      } catch (widgetError, widgetStack) {
        debugPrint(
          '[WidgetService] transaction sync failed: $widgetError\n$widgetStack',
        );
      }

      // ── Success ───────────────────────────────────────
      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null ? 'تمت إضافة العملية' : 'تم تحديث العملية',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.tokens.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          duration: const Duration(milliseconds: 1400),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر الحفظ: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.colors.error,
          duration: const Duration(milliseconds: 2000),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final accountsAsync = ref.watch(accountsProvider);
    final accounts = accountsAsync.valueOrNull ?? [];

    // Auto-select the first account if nothing is set yet
    if (_draft.accountId == null && accounts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _draft.accountId != null) return;
        setState(() {
          _draft = NewTransactionDraft(
            type: _draft.type,
            amount: _draft.amount,
            accountId: accounts.first.id,
            toAccountId: _draft.toAccountId,
            date: _draft.date,
            note: _draft.note,
            categoryId: _draft.categoryId,
          );
        });
      });
    }

    final sourceAccount = _draft.accountId == null
        ? null
        : accounts.where((a) => a.id == _draft.accountId).firstOrNull;
    final destinationAccount = _draft.toAccountId == null
        ? null
        : accounts.where((a) => a.id == _draft.toAccountId).firstOrNull;

    final category = _selectedCategory;
    final dateLabel = DateFormat(
      'd MMM',
      'ar',
    ).format(_draft.date ?? DateTime.now());
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSizes.md,
            6,
            AppSizes.md,
            AppSizes.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle ────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // ── Header ────────────────────────────────
              Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      widget.existing == null ? 'إضافة عملية' : 'تعديل العملية',
                      textAlign: TextAlign.center,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Material(
                    color: tokens.border.withValues(alpha: .35),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Type selector ─────────────────────────
              TypeSelector(value: _draft.type, onChanged: _onTypeChanged),
              const SizedBox(height: 12),

              // ── Amount ────────────────────────────────
              AmountField(
                controller: _amountController,
                type: _draft.type,
                currency: sourceAccount?.currency ?? 'SAR',
              ),
              AmountInWords(
                amount: _draft.amount,
                currency: sourceAccount != null
                    ? sourceAccount.currency
                    : "ريال",
              ),
              const SizedBox(height: 12),

              // ── Empty accounts warning ────────────────
              if (accountsAsync.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (accounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    border: Border.all(
                      color: tokens.warning.withValues(alpha: .35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: tokens.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'أضف حساباً أولاً لتتمكن من تسجيل العمليات',
                          style: text.labelMedium?.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // ── Chips row ────────────────────────────
                if (_draft.type == TransactionType.transfer) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CompactChip(
                          fill: true,
                          icon: Icons.account_balance_wallet_rounded,
                          label: sourceAccount?.name ?? 'من حساب',
                          onTap: () => _pickAccount(
                            isDestination: false,
                            accounts: accounts,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Material(
                          color: colors.primary.withValues(alpha: .10),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: _swapAccounts,
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CompactChip(
                          fill: true,
                          icon: Icons.south_west_rounded,
                          label: destinationAccount?.name ?? 'إلى حساب',
                          active: destinationAccount != null,
                          onTap: () => _pickAccount(
                            isDestination: true,
                            accounts: accounts,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_draft.type == TransactionType.transfer &&
                      sourceAccount != null &&
                      destinationAccount != null &&
                      sourceAccount.currency != destinationAccount.currency)
                    _conversionPreview(
                      context,
                      settings: ref.watch(appSettingsProvider).valueOrNull,
                      source: sourceAccount,
                      destination: destinationAccount,
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: CompactChip(
                          fill: true,
                          icon: Icons.calendar_today_rounded,
                          label: dateLabel,
                          onTap: _pickDate,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: CompactChip(
                          icon: Icons.account_balance_wallet_rounded,
                          label: sourceAccount?.name ?? 'الحساب',
                          onTap: () => _pickAccount(
                            isDestination: false,
                            accounts: accounts,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CompactChip(
                          icon: Icons.calendar_today_rounded,
                          label: dateLabel,
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: CompactChip(
                          icon: category?.icon ?? Icons.local_offer_rounded,
                          label: category?.label ?? 'الفئة',
                          active: category != null,
                          iconColor: category?.color ?? colors.primary,
                          onTap: _pickCategory,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),

                // ── Notes ────────────────────────────────
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  minLines: 1,
                  style: text.bodyMedium,
                  onChanged: (v) =>
                      setState(() => _draft = _draft.copyWith(note: v)),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'ملاحظة (اختياري)',
                    hintStyle: text.bodySmall?.copyWith(
                      color: tokens.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.sticky_note_2_outlined,
                      size: 18,
                      color: tokens.textMuted,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    contentPadding: const EdgeInsetsDirectional.fromSTEB(
                      8,
                      12,
                      12,
                      12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      borderSide: BorderSide(color: tokens.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      borderSide: BorderSide(color: colors.primary, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Save ─────────────────────────────────
                ElevatedButton(
                  onPressed: (_draft.isValid && !_saving) ? _save : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    disabledBackgroundColor: colors.primary.withValues(
                      alpha: .25,
                    ),
                    disabledForegroundColor: colors.onPrimary.withValues(
                      alpha: .7,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    textStyle: text.labelLarge,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.existing == null
                              ? 'حفظ العملية'
                              : 'حفظ التعديلات',
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Account picker sub-sheet ──────────────────────────────

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({
    required this.accounts,
    this.selectedId,
    this.excludedId,
  });

  final List<Account> accounts;
  final String? selectedId;
  final String? excludedId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final visible = accounts.where((a) => a.id != excludedId).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'اختر الحساب',
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.sm),
            ...visible.map((a) {
              final active = a.id == selectedId;
              return Material(
                color: active
                    ? colors.primary.withValues(alpha: .08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  onTap: () => Navigator.pop(context, a.id),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.sm + 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: a.accentColor ?? colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            a.name,
                            style: text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (active)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 20,
                            color: colors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
