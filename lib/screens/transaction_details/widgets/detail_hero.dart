import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class DetailHero extends StatelessWidget {
  const DetailHero({
    super.key,
    required this.transaction,
    this.sourceAccount,
    this.destinationAccount,
  });

  final Transaction transaction;
  final Account? sourceAccount;
  final Account? destinationAccount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final isTransfer = transaction.isTransfer;
    final isIncome = transaction.isIncome;

    final accent = isTransfer
        ? colors.primary
        : isIncome
        ? tokens.success
        : colors.error;

    final sign = isTransfer ? '' : (isIncome ? '+' : '-');
    final amount = NumberFormat('#,##0.00', 'en').format(transaction.amount);
    final time = DateFormat('h:mm a', 'ar').format(transaction.date);
    final currency = sourceAccount?.currency ?? 'SAR';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [accent, Color.lerp(accent, Colors.black, 0.35)!],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Single small decorative bubble
          PositionedDirectional(
            top: -40,
            end: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: type pill + time ──────────────
              Row(
                children: [
                  _pill(context, isTransfer: isTransfer, isIncome: isIncome),
                  const Spacer(),
                  Text(
                    time,
                    style: text.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: .85),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Amount ───────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$sign$amount',
                    textDirection: .ltr,
                    style: text.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    currency,
                    style: text.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: .85),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ── Subtitle: transfer accounts OR title ──
              if (isTransfer &&
                  sourceAccount != null &&
                  destinationAccount != null)
                _transferRow(context, sourceAccount!, destinationAccount!)
              else
                Text(
                  transaction.title,
                  style: text.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: .85),
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Type pill ────────────────────────────────────────

  Widget _pill(
    BuildContext context, {
    required bool isTransfer,
    required bool isIncome,
  }) {
    final icon = isTransfer
        ? Icons.swap_horiz_rounded
        : isIncome
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;
    final label = isTransfer
        ? 'تحويل'
        : isIncome
        ? 'دخل'
        : 'مصروف';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .20),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: Colors.white.withValues(alpha: .28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ── Transfer accounts row ────────────────────────────

  Widget _transferRow(
    BuildContext context,
    Account source,
    Account destination,
  ) {
    final text = context.text;
    final destAmount = transaction.destinationAmount;
    final destLabel = destAmount != null
        ? NumberFormat('#,##0.00', 'en').format(destAmount)
        : null;

    return Row(
      children: [
        // Source name (appears right in RTL)
        Text(
          source.name,
          style: text.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: .95),
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 11,
            color: Colors.white.withValues(alpha: .75),
          ),
        ),
        // Destination name + received amount
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  destination.name,
                  style: text.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: .95),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (destLabel != null) ...[
                const SizedBox(width: 5),
                Text(
                  '($destLabel ${destination.currency})',
                  textDirection: .ltr,
                  style: text.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: .7),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
