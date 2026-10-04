import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account_filter.dart';
import 'package:masrouf_v2/models/new_transaction.dart';
import 'package:masrouf_v2/theme/app_motion.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

Future<AccountFilter?> showAccountFilterSheet(
  BuildContext context, {
  required AccountFilter current,
  required List<String> availableCategories,
}) {
  return showModalBottomSheet<AccountFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) =>
        _AccountFilterSheet(initial: current, categories: availableCategories),
  );
}

class _AccountFilterSheet extends StatefulWidget {
  const _AccountFilterSheet({required this.initial, required this.categories});

  final AccountFilter initial;
  final List<String> categories;

  @override
  State<_AccountFilterSheet> createState() => _AccountFilterSheetState();
}

class _AccountFilterSheetState extends State<_AccountFilterSheet> {
  late AccountFilter _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange:
          _draft.customRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
      locale: const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: context.colors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _draft = _draft.copyWith(
          datePreset: DateRangePreset.custom,
          customRange: picked,
        );
      });
    }
  }

  void _reset() {
    setState(() => _draft = const AccountFilter());
  }

  void _apply() => Navigator.pop(context, _draft);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final maxH = MediaQuery.sizeOf(context).height * .82;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.md,
              8,
              AppSizes.sm,
              0,
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(
                    foregroundColor: tokens.textMuted,
                  ),
                  child: const Text('إعادة تعيين'),
                ),
                const Spacer(),
                Text(
                  'فلترة العمليات',
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  splashRadius: 20,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // ── Body ──────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type
                  _sectionLabel(context, 'النوع'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _typeChip('الكل', null),
                      _typeChip(
                        'مصروف',
                        TransactionType.expense,
                        color: colors.error,
                      ),
                      _typeChip(
                        'دخل',
                        TransactionType.income,
                        color: tokens.success,
                      ),
                      _typeChip(
                        'تحويل',
                        TransactionType.transfer,
                        color: colors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Date
                  _sectionLabel(context, 'الفترة الزمنية'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: DateRangePreset.values.map((p) {
                      final active = _draft.datePreset == p;
                      return _selectableChip(
                        context,
                        label: p.label,
                        active: active,
                        onTap: () {
                          if (p == DateRangePreset.custom) {
                            _pickCustomRange();
                          } else {
                            setState(() {
                              _draft = _draft.copyWith(
                                datePreset: p,
                                clearCustomRange: true,
                              );
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  // Show chosen range under the chips
                  if (_draft.datePreset == DateRangePreset.custom &&
                      _draft.customRange != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: .25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${DateFormat('yyyy/MM/dd', 'en').format(_draft.customRange!.start)}'
                            '  —  '
                            '${DateFormat('yyyy/MM/dd', 'en').format(_draft.customRange!.end)}',
                            textDirection: .ltr,
                            style: text.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Categories
                  if (widget.categories.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.lg),
                    _sectionLabel(context, 'التصنيفات'),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.categories.map((c) {
                        final active = _draft.categoryIds.contains(c);
                        return _selectableChip(
                          context,
                          label: c,
                          active: active,
                          onTap: () {
                            final next = {..._draft.categoryIds};
                            active ? next.remove(c) : next.add(c);
                            setState(() {
                              _draft = _draft.copyWith(categoryIds: next);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Apply ─────────────────────────────────────
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.md,
              4,
              AppSizes.md,
              AppSizes.md,
            ),
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
              child: const Text('تطبيق'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chips ──────────────────────────────────────────────

  Widget _typeChip(String label, TransactionType? type, {Color? color}) {
    final active = type == null
        ? _draft.types.isEmpty
        : _draft.types.contains(type);
    return _selectableChip(
      context,
      label: label,
      active: active,
      activeColor: color,
      onTap: () {
        if (type == null) {
          setState(() => _draft = _draft.copyWith(types: {}));
        } else {
          final next = {..._draft.types};
          active ? next.remove(type) : next.add(type);
          setState(() => _draft = _draft.copyWith(types: next));
        }
      },
    );
  }

  Widget _selectableChip(
    BuildContext context, {
    required String label,
    required bool active,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final accent = activeColor ?? colors.primary;

    return Material(
      color: active ? accent.withValues(alpha: .12) : colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.standard,
          curve: AppMotion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: active ? accent.withValues(alpha: .45) : tokens.border,
            ),
          ),
          child: Text(
            label,
            style: text.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: active ? accent : colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: context.text.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: context.tokens.textMuted,
      ),
    );
  }
}
