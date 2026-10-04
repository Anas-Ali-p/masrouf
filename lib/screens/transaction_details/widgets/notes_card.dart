import 'package:flutter/material.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class NotesCard extends StatelessWidget {
  const NotesCard({super.key, required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent bar
          Container(
            width: 3,
            margin: const EdgeInsetsDirectional.only(top: 2),
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sticky_note_2_outlined,
                      size: 13,
                      color: tokens.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ملاحظات',
                      style: text.labelSmall?.copyWith(
                        color: tokens.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(note, style: text.bodyMedium?.copyWith(height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
