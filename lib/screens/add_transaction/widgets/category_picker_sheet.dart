import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/category.dart';
import 'package:masrouf_v2/theme/app_motion.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

Future<TransactionCategory?> showCategoryPicker(
  BuildContext context, {
  required List<TransactionCategory> categories,
  String? selectedId,
}) {
  return showModalBottomSheet<TransactionCategory>(
    context: context,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) =>
        _CategoryPickerSheet(categories: categories, selectedId: selectedId),
  );
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({required this.categories, this.selectedId});

  final List<TransactionCategory> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final tokens = context.tokens;

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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              'اختر الفئة',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 76,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final c = categories[i];
                final active = c.id == selectedId;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, c),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: AppMotion.standard,
                        curve: AppMotion.curve,
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: active
                              ? c.color
                              : c.color.withValues(alpha: .12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          c.icon,
                          size: 20,
                          color: active ? Colors.white : c.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        c.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall?.copyWith(
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
