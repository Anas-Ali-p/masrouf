import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class AccountHero extends StatelessWidget {
  const AccountHero({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final accent = account.accentColor ?? colors.primary;

    final amount = NumberFormat('#,##0.00', 'en').format(account.balance);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md + 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [accent, Color.lerp(accent, Colors.black, 0.25)!],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: type chip + number ─────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(account.type.icon, size: 14, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      account.type.label,
                      style: text.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (account.accountNumber != null)
                Text(
                  account.accountNumber!,
                  textDirection: .ltr,
                  style: text.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .85),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),

          // ── Balance ─────────────────────────────────────
          Text(
            'الرصيد الحالي',
            style: text.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: .75),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                amount,
                textDirection: .ltr,
                style: text.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                account.currency,
                style: text.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: .8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
