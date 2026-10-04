import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/new_transaction.dart';
import 'package:masrouf_v2/theme/app_motion.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class TypeSelector extends StatelessWidget {
  const TypeSelector({super.key, required this.value, required this.onChanged});

  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  // 3 segments → alignments -1, 0, 1 along the horizontal axis.
  // In RTL, Flutter flips AlignmentDirectional for us, so we write
  // the "reading order" side and let Directionality handle mirroring.
  AlignmentDirectional _alignmentFor(TransactionType t) {
    switch (t) {
      case TransactionType.expense:
        return AlignmentDirectional.centerStart; // rightmost in RTL
      case TransactionType.income:
        return AlignmentDirectional.center;
      case TransactionType.transfer:
        return AlignmentDirectional.centerEnd; // leftmost in RTL
    }
  }

  Color _accentFor(TransactionType t, BuildContext context) {
    final colors = context.colors;
    final tokens = context.tokens;
    switch (t) {
      case TransactionType.expense:
        return colors.error;
      case TransactionType.income:
        return tokens.success;
      case TransactionType.transfer:
        return colors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tokens = context.tokens;

    const items = TransactionType.values;
    const labels = ['مصروف', 'دخل', 'تحويل'];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Width of one thumb. Subtract the outer 4px padding on each
        // side, then divide evenly by the number of segments.
        final innerWidth = constraints.maxWidth - 8;
        final thumbWidth = innerWidth / items.length;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: tokens.border.withValues(alpha: .35),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Stack(
            children: [
              // ── Sliding thumb ─────────────────────────────
              AnimatedAlign(
                duration: AppMotion.fast,
                curve: AppMotion.curve,
                alignment: _alignmentFor(value),
                child: AnimatedScale(
                  scale: 1.0,
                  duration: AppMotion.fast,
                  curve: AppMotion.curve,
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    curve: AppMotion.curve,
                    width: thumbWidth,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: .08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Labels ────────────────────────────────────
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(items[i]),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          height: 32,
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: AppMotion.standard,
                              curve: AppMotion.curve,
                              style: context.text.labelSmall!.copyWith(
                                fontWeight: FontWeight.w700,
                                color: value == items[i]
                                    ? _accentFor(items[i], context)
                                    : tokens.textMuted,
                              ),
                              child: Text(labels[i]),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
