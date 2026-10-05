import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/core/widgets/color_picker/color_picker.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/services/widget_service.dart';
import 'package:masrouf_v2/theme/app_motion.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/thousands_formatter.dart';
import 'package:uuid/uuid.dart';

Future<bool?> showAddAccountSheet(BuildContext context, {Account? existing}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => _AddAccountSheet(existing: existing),
  );
}

class _AddAccountSheet extends ConsumerStatefulWidget {
  const _AddAccountSheet({this.existing});
  final Account? existing;

  @override
  ConsumerState<_AddAccountSheet> createState() => _AddAccountSheetState();
}

class _AddAccountSheetState extends ConsumerState<_AddAccountSheet> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();

  String _currency = 'YER';
  Color _accent = const Color(0xFF2F3EE0);
  bool _saving = false;

  static const _currencies = ['YER', 'SAR', 'USD', 'EUR', 'AED', 'EGP', 'KWD'];

  static const _accents = [
    Color(0xFF2F3EE0), // indigo
    Color(0xFF3CCABC), // teal
    Color(0xFF16A34A), // green
    Color(0xFFF49B07), // amber
    Color(0xFFDC2626), // red
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF0EA5E9), // sky
  ];

  static const _categorySuggestions = [
    'بقالة',
    'متجر',
    'بهارات',
    'إكسسوارات',
    'مطاعم',
    'مواصلات',
    'بيت',
    'شخصي',
    'أعمال',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.name;
      _balanceController.text = NumberFormat(
        '#,##0.00',
        'en',
      ).format(e.balance);
      _categoryController.text = e.category ?? '';
      _noteController.text = e.note ?? '';
      _currency = e.currency;
      _accent = e.accentColor ?? _accents.first;
    }
    // Live rebuilds for the preview card.
    _nameController.addListener(_refresh);
    _categoryController.addListener(_refresh);
    if (widget.existing == null) {
      _balanceController.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _nameController
      ..removeListener(_refresh)
      ..dispose();
    _balanceController
      ..removeListener(_refresh)
      ..dispose();
    _categoryController
      ..removeListener(_refresh)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  double get _balance => parseFormattedAmount(_balanceController.text);

  Widget _balanceDisplay(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final amount = NumberFormat(
      '#,##0.00',
      'en',
    ).format(widget.existing!.balance);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: tokens.border.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 16, color: tokens.textMuted),
          const SizedBox(width: 8),
          Text(
            _currency,
            style: text.labelMedium?.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            textDirection: .ltr,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _accent,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final existing = widget.existing;
    if (existing == null) return;

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
              'حذف الحساب؟',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'سيتم حذف الحساب "${existing.name}" وجميع عملياته نهائياً.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                border: Border.all(color: colors.error.withValues(alpha: .25)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: colors.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'لا يمكن التراجع عن هذا الإجراء.',
                      style: text.labelSmall?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
            style: TextButton.styleFrom(foregroundColor: colors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    try {
      await ref.read(accountRepositoryProvider).delete(existing.id);

      try {
        final accounts = await ref
            .read(accountRepositoryProvider)
            .watchAll()
            .first;
        await WidgetService.updateAllWidgets(accounts: accounts);
      } catch (widgetError, widgetStack) {
        debugPrint(
          '[WidgetService] account delete sync failed: $widgetError\n$widgetStack',
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف الحساب'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: tokens.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر الحذف: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.error,
        ),
      );
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving) return;

    setState(() => _saving = true);
    try {
      final repo = ref.read(accountRepositoryProvider);
      final existing = widget.existing;

      final account = Account(
        id: existing?.id ?? const Uuid().v4(),
        name: name,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        currency: _currency,
        balance: existing?.balance ?? _balance,
        accentColor: _accent,
        type: existing?.type ?? AccountType.checking,
        accountNumber: existing?.accountNumber,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        createdAt: existing?.createdAt ?? DateTime.now(),
      );

      if (existing == null) {
        await repo.insert(account);
      } else {
        await repo.update(account);
      }

      try {
        final accounts = await repo.watchAll().first;
        await WidgetService.updateAllWidgets(accounts: accounts);
      } catch (widgetError, widgetStack) {
        debugPrint(
          '[WidgetService] account save sync failed: $widgetError\n$widgetStack',
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null ? 'تمت إضافة الحساب' : 'تم تحديث الحساب',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.tokens.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final isEdit = widget.existing != null;
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
                      isEdit ? 'تعديل الحساب' : 'حساب جديد',
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
              const SizedBox(height: 14),

              // ── Live preview card ─────────────────────
              _LivePreview(
                name: _nameController.text.trim(),
                category: _categoryController.text.trim(),
                balance: _balance,
                currency: _currency,
                accent: _accent,
              ),
              const SizedBox(height: 18),

              // ── Name input ────────────────────────────
              _label(context, 'اسم الحساب'),
              const SizedBox(height: 6),
              _bigField(
                context,
                controller: _nameController,
                hint: 'مثال: بقالة، مصروف البيت',
                autofocus: !isEdit,
              ),
              const SizedBox(height: 16),

              // ── Balance ──────────────────────────────────────
              _label(context, isEdit ? 'الرصيد الحالي' : 'الرصيد الابتدائي'),
              const SizedBox(height: 6),

              if (isEdit)
                // Read-only display — only changed via transactions
                _balanceDisplay(context)
              else
                _balanceField(context),
              const SizedBox(height: 16),

              // ── Category ──────────────────────────────
              _label(context, 'التصنيف (اختياري)'),
              const SizedBox(height: 6),
              _categoryField(context),
              const SizedBox(height: 8),
              _categoryChips(context),
              const SizedBox(height: 16),

              // ── Currency + Color ──────────────────────
              _label(context, 'العملة واللون'),
              const SizedBox(height: 8),
              _currencyRow(context),
              const SizedBox(height: 12),
              _colorRow(context),
              const SizedBox(height: 16),

              // ── Note ──────────────────────────────────
              _label(context, 'ملاحظة (اختياري)'),
              const SizedBox(height: 6),
              TextField(
                controller: _noteController,
                maxLines: 2,
                minLines: 1,
                style: text.bodyMedium,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'اكتب أي ملاحظة عن هذا الحساب...',
                  hintStyle: text.bodySmall?.copyWith(color: tokens.textMuted),
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
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
              const SizedBox(height: 18),

              // ── Delete (edit only) ───────────────────────────
              if (isEdit) ...[
                OutlinedButton.icon(
                  onPressed: _saving ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('حذف الحساب'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: .35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    textStyle: text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // ── Save ──────────────────────────────────
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  disabledBackgroundColor: colors.primary.withValues(
                    alpha: .25,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  textStyle: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
                    : Text(isEdit ? 'حفظ التعديلات' : 'إضافة الحساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Field helpers ────────────────────────────────────────

  Widget _label(BuildContext context, String s) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 2),
    child: Text(
      s,
      style: context.text.labelSmall?.copyWith(
        color: context.tokens.textMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _bigField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool autofocus = false,
  }) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      textAlign: TextAlign.start,
      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: text.bodyMedium?.copyWith(
          color: tokens.textMuted.withValues(alpha: .7),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
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
    );
  }

  Widget _balanceField(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          // Currency prefix
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 14),
            child: Text(
              _currency,
              style: text.labelMedium?.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Amount
          Expanded(
            child: TextField(
              controller: _balanceController,
              textAlign: TextAlign.end,
              textDirection: .ltr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [ThousandsInputFormatter()],
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: _accent,
                height: 1.1,
                letterSpacing: -0.3,
              ),
              cursorColor: _accent,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: '0.00',
                hintStyle: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.textMuted.withValues(alpha: .35),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryField(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return TextField(
      controller: _categoryController,
      style: text.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'اكتب تصنيفاً أو اختر من الاقتراحات',
        hintStyle: text.bodySmall?.copyWith(color: tokens.textMuted),
        prefixIcon: Icon(
          Icons.local_offer_outlined,
          size: 18,
          color: tokens.textMuted,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(8, 12, 14, 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: BorderSide(color: colors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _categoryChips(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final current = _categoryController.text.trim();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _categorySuggestions.map((c) {
        final active = current == c;
        return GestureDetector(
          onTap: () {
            _categoryController.text = c;
            _categoryController.selection = TextSelection.fromPosition(
              TextPosition(offset: c.length),
            );
          },
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? colors.primary.withValues(alpha: .12)
                  : colors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(
                color: active
                    ? colors.primary.withValues(alpha: .45)
                    : tokens.border,
              ),
            ),
            child: Text(
              c,
              style: text.labelSmall?.copyWith(
                color: active ? colors.primary : colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _currencyRow(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _currencies.map((c) {
        final active = _currency == c;
        return GestureDetector(
          onTap: () => setState(() => _currency = c),
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? colors.primary.withValues(alpha: .12)
                  : colors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(
                color: active
                    ? colors.primary.withValues(alpha: .45)
                    : tokens.border,
              ),
            ),
            child: Text(
              c,
              style: text.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: active ? colors.primary : colors.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _colorRow(BuildContext context) {
    final isCustom = !_accents.contains(_accent);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Preset swatches
        for (final c in _accents) _swatch(context, c, isCustom: false),

        // Custom swatch (only when a custom color is active)
        if (isCustom) _swatch(context, _accent, isCustom: true),

        // Add-custom button
        _addCustomButton(context),
      ],
    );
  }

  Widget _swatch(BuildContext context, Color c, {required bool isCustom}) {
    final colors = context.colors;
    final active = _accent.toARGB32() == c.toARGB32();

    return GestureDetector(
      onTap: () => setState(() => _accent = c),
      onLongPress: isCustom ? _openColorPicker : null,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: c.withValues(alpha: .45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: active ? Border.all(color: colors.onSurface, width: 2) : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (active)
              const Center(
                child: Icon(Icons.check_rounded, color: Colors.white, size: 16),
              ),
            // Pencil badge on the custom swatch so users know
            // it's editable via long-press or tap the rainbow button
            if (isCustom)
              PositionedDirectional(
                top: -2,
                end: -2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.onSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.surface, width: 1.5),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 8,
                    color: colors.surface,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _addCustomButton(BuildContext context) {
    final colors = context.colors;
    final tokens = context.tokens;

    return GestureDetector(
      onTap: _openColorPicker,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Color(0xFFFF0000),
              Color(0xFFFFFF00),
              Color(0xFF00FF00),
              Color(0xFF00FFFF),
              Color(0xFF0000FF),
              Color(0xFFFF00FF),
              Color(0xFFFF0000),
            ],
          ),
          border: Border.all(color: tokens.border, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_rounded, size: 13, color: colors.onSurface),
          ),
        ),
      ),
    );
  }

  Future<void> _openColorPicker() async {
    final result = await showColorPickerSheet(context, initial: _accent);
    if (result != null && mounted) {
      setState(() => _accent = result);
    }
  }
}

// ─────────────────────────────────────────────────────────
//  Live preview card
// ─────────────────────────────────────────────────────────

class _LivePreview extends StatelessWidget {
  const _LivePreview({
    required this.name,
    required this.category,
    required this.balance,
    required this.currency,
    required this.accent,
  });

  final String name;
  final String category;
  final double balance;
  final String currency;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final displayName = name.isEmpty ? 'اسم الحساب' : name;
    final displayCategory = category.isEmpty ? 'حساب شخصي' : category;
    final amountLabel = NumberFormat('#,##0.00', 'en').format(balance);

    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.curve,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [accent, Color.lerp(accent, Colors.black, 0.35)!],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative bubbles
          PositionedDirectional(
            top: -30,
            end: -30,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -40,
            start: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .30),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .18),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Text(
                        displayCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall?.copyWith(
                          color: Colors.white.withValues(alpha: .95),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amountLabel,
                    textDirection: .ltr,
                    style: text.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency,
                    style: text.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: .85),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
