import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class AccountsSkeleton extends StatelessWidget {
  const AccountsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.sm + 4,
        crossAxisSpacing: AppSizes.sm + 4,
        childAspectRatio: 2.4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: const [_SkeletonCard(), _SkeletonCard()],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.border.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
    );
  }
}

class TransactionsSkeleton extends StatelessWidget {
  const TransactionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: AppSizes.sm + 2),
            decoration: BoxDecoration(
              color: tokens.border.withValues(alpha: .35),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
