import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/account_filter.dart';
import 'package:masrouf_v2/screens/account_details/widget/active_filters_bar.dart';
import 'package:masrouf_v2/screens/home/widgets/section_title.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

/// Fixed height used by the persistent header delegate.
const double kTransactionsHeaderHeight = 85;

class TransactionsHeader extends StatelessWidget {
  const TransactionsHeader({
    super.key,
    required this.count,
    required this.filter,
    required this.onEdit,
    required this.onClearType,
    required this.onClearDate,
    required this.onClearCategories,
    required this.onClearAll,
  });

  final int count;
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

    return Container(
      height: kTransactionsHeaderHeight,
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Section title row ─────────────────────────
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.md,
              AppSizes.sm,
              AppSizes.md,
              AppSizes.xs + 2,
            ),
            child: SectionTitle(
              title: 'عمليات الحساب',
              trailing: Text(
                '$count',
                style: text.labelSmall?.copyWith(
                  color: tokens.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ── Filter bar ────────────────────────────────
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.md,
              0,
              AppSizes.md,
              0,
            ),
            child: ActiveFiltersBar(
              filter: filter,
              onEdit: onEdit,
              onClearType: onClearType,
              onClearDate: onClearDate,
              onClearCategories: onClearCategories,
              onClearAll: onClearAll,
            ),
          ),

          // ── Bottom hairline so it separates from the list
          const SizedBox(height: 4),
          Divider(
            height: 1,
            thickness: 1,
            color: tokens.border.withValues(alpha: .5),
          ),
        ],
      ),
    );
  }
}

class TransactionsHeaderDelegate extends SliverPersistentHeaderDelegate {
  TransactionsHeaderDelegate({
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  @override
  double get minExtent => kTransactionsHeaderHeight;

  @override
  double get maxExtent => kTransactionsHeaderHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Show a subtle shadow when content scrolls under the header.
    return Material(
      color: backgroundColor,
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: .06),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant TransactionsHeaderDelegate old) =>
      old.child != child ||
      old.backgroundColor != backgroundColor ||
      old.borderColor != borderColor;
}
