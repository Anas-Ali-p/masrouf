import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class QuickInfoRow extends StatelessWidget {
  const QuickInfoRow({super.key, required this.date, this.reference});

  final DateTime date;
  final String? reference;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: _Chip(
            icon: Icons.calendar_today_rounded,
            label: DateFormat('EEEE، d MMMM', 'ar').format(date),
          ),
        ),
        if (reference != null) ...[
          const SizedBox(width: 6),
          Expanded(
            child: _Chip(icon: Icons.tag_rounded, label: reference!, ltr: true),
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, this.ltr = false});

  final IconData icon;
  final String label;
  final bool ltr;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: tokens.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              textDirection: ltr ? .ltr : null,
              style: text.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
