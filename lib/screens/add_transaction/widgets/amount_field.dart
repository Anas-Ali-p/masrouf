import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masrouf_v2/models/new_transaction.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/thousands_formatter.dart';

class AmountField extends StatefulWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.type,
    this.currency = 'SAR',
  });

  final TextEditingController controller;
  final TransactionType type;
  final String currency;

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;
    final focused = _focusNode.hasFocus;

    final accent = switch (widget.type) {
      TransactionType.expense => colors.error,
      TransactionType.income => tokens.success,
      TransactionType.transfer => colors.primary,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 40,
      padding: .fromSTEB(5, 0, 5, 0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: focused ? colors.primary.withValues(alpha: .7) : tokens.border,
          width: focused ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: .center,
        children: [
          // ── Amount — fills the box, centered H+V ──────────
          Expanded(
            child: TextField(
              controller: widget.controller,
              autofocus: true,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              textDirection: TextDirection.ltr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ThousandsInputFormatter(),
              ],
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: accent,
                height: 1.0,
              ),
              cursorColor: accent,
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                hintText: '0.00',
                hintStyle: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tokens.textMuted.withValues(alpha: .35),
                  height: 1.0,
                ),
              ),
            ),
          ),

          // ── Currency — pinned to the physical left ────────
          Center(
            child: Text(
              widget.currency,
              style: text.labelMedium?.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
