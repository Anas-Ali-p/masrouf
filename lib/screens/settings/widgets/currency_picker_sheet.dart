import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

const kCommonCurrencies = <String, String>{
  'SAR': 'ريال سعودي',
  'USD': 'دولار أمريكي',
  'EUR': 'يورو',
  'AED': 'درهم إماراتي',
  'EGP': 'جنيه مصري',
  'KWD': 'دينار كويتي',
  'YER': 'ريال يمني',
  'OMR': 'ريال عماني',
  'QAR': 'ريال قطري',
  'BHD': 'دينار بحريني',
  'JOD': 'دينار أردني',
  'TRY': 'ليرة تركية',
};

Future<void> showCurrencyPickerSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => const _CurrencyPickerSheet(),
  );
}

class _CurrencyPickerSheet extends ConsumerStatefulWidget {
  const _CurrencyPickerSheet();

  @override
  ConsumerState<_CurrencyPickerSheet> createState() =>
      _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends ConsumerState<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<String, String>> _filtered() {
    final all = kCommonCurrencies.entries.toList();
    if (_query.isEmpty) return all;
    final q = _query.trim().toLowerCase();
    return all.where((e) {
      return e.key.toLowerCase().contains(q) ||
          e.value.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final settingsAsync = ref.watch(appSettingsProvider);
    final current = settingsAsync.valueOrNull?.currency ?? 'SAR';

    final filtered = _filtered();
    final maxH = MediaQuery.sizeOf(context).height * .78;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Header ────────────────────────────────────
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.md,
              0,
              AppSizes.sm,
              0,
            ),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    'العملة الافتراضية',
                    textAlign: TextAlign.center,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Material(
                  color: tokens.border.withValues(alpha: .35),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Search ────────────────────────────────────
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSizes.md,
              0,
              AppSizes.md,
              AppSizes.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              textInputAction: TextInputAction.search,
              style: text.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                hintText: 'ابحث عن عملة...',
                hintStyle: text.bodySmall?.copyWith(color: tokens.textMuted),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: tokens.textMuted,
                ),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        splashRadius: 16,
                        icon: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: tokens.textMuted,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  8,
                  12,
                  12,
                  12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  borderSide: BorderSide(color: tokens.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  borderSide: BorderSide(color: colors.primary, width: 1.4),
                ),
              ),
            ),
          ),

          // ── List ──────────────────────────────────────
          Flexible(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 28,
                            color: tokens.textMuted,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد نتائج',
                            style: text.labelMedium?.copyWith(
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSizes.md,
                      0,
                      AppSizes.md,
                      AppSizes.md,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final entry = filtered[i];
                      final active = current == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Material(
                          color: active
                              ? colors.primary.withValues(alpha: .08)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () async {
                              await ref
                                  .read(appSettingsProvider.notifier)
                                  .setCurrency(entry.key, entry.value);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.sm + 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSm,
                                ),
                                border: Border.all(
                                  color: active
                                      ? colors.primary.withValues(alpha: .35)
                                      : tokens.border,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(
                                        alpha: .10,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.key,
                                        textDirection: TextDirection.ltr,
                                        style: text.labelSmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: colors.primary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      entry.value,
                                      style: text.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (active)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: colors.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
