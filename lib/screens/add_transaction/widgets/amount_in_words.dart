import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/arabic_number_to_words.dart';

class AmountInWords extends StatelessWidget {
  const AmountInWords({
    super.key,
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();
    final words = ArabicNumberToWords.currency(amount, currency);
    if (words.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        words,
        textAlign: TextAlign.start,
        style: context.text.labelSmall?.copyWith(
          color: context.tokens.textMuted,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      ),
    );
  }
}
