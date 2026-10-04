import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account_filter.dart';
import 'package:masrouf_v2/models/new_transaction.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class ActiveFiltersBar extends StatelessWidget {
  const ActiveFiltersBar({
    super.key,
    required this.filter,
    required this.onEdit,
    required this.onClearType,
    required this.onClearDate,
    required this.onClearCategories,
    required this.onClearAll,
  });

  final AccountFilter filter;
  final VoidCallback onEdit;
  final VoidCallback onClearType;
  final VoidCallback onClearDate;
  final VoidCallback onClearCategories;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final dateLabel =
        filter.datePreset == DateRangePreset.custom &&
            filter.customRange != null
        ? '${DateFormat('yy/MM/dd', 'en').format(filter.customRange!.start)}'
              ' - '
              '${DateFormat('yy/MM/dd', 'en').format(filter.customRange!.end)}'
        : filter.datePreset.label;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          // Edit button
          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded, size: 14, color: colors.onPrimary),
                    const SizedBox(width: 5),
                    Text(
                      'فلترة',
                      style: text.labelMedium?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (filter.activeCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colors.onPrimary.withValues(alpha: .25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${filter.activeCount}',
                          style: text.labelSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Active filter chips
          if (!filter.isEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    if (filter.types.isNotEmpty)
                      _chip(context, _typeLabel(filter), onClearType),
                    if (filter.types.isNotEmpty &&
                        (filter.categoryIds.isNotEmpty ||
                            filter.datePreset != DateRangePreset.all))
                      const SizedBox(width: 6),
                    if (filter.datePreset != DateRangePreset.all)
                      _chip(context, dateLabel, onClearDate),
                    if (filter.datePreset != DateRangePreset.all &&
                        filter.categoryIds.isNotEmpty)
                      const SizedBox(width: 6),
                    if (filter.categoryIds.isNotEmpty)
                      _chip(
                        context,
                        filter.categoryIds.length == 1
                            ? filter.categoryIds.first
                            : '${filter.categoryIds.length} تصنيفات',
                        onClearCategories,
                      ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onClearAll,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          'مسح',
                          style: text.labelSmall?.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }

  String _typeLabel(AccountFilter f) {
    final labels = <String>[];
    if (f.types.contains(TransactionType.expense)) labels.add('مصروف');
    if (f.types.contains(TransactionType.income)) labels.add('دخل');
    if (f.types.contains(TransactionType.transfer)) labels.add('تحويل');
    return labels.join(' · ');
  }

  Widget _chip(BuildContext context, String label, VoidCallback onRemove) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 4, 5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: colors.primary.withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: text.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: colors.primary.withValues(alpha: .8),
            ),
          ),
        ],
      ),
    );
  }
}
