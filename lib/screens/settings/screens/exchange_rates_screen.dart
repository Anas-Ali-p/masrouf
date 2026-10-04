import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
// At the top of exchange_rates_screen.dart
import 'package:masrouf_v2/screens/settings/widgets/currency_picker_sheet.dart'
    show kCommonCurrencies;

class ExchangeRatesScreen extends ConsumerStatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  ConsumerState<ExchangeRatesScreen> createState() =>
      _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends ConsumerState<ExchangeRatesScreen> {
  final _controllers = <String, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String currency, double? rate) {
    return _controllers.putIfAbsent(
      currency,
      () => TextEditingController(text: rate != null ? _fmt(rate) : ''),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (settings) {
            final base = settings.currency;
            final baseLabel = settings.currencyLabel.isEmpty
                ? base
                : settings.currencyLabel;

            final others = kCommonCurrencies.entries
                .where((e) => e.key != base)
                .toList();

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: AppTopBar(
                    showAvatar: false,
                    title: 'أسعار الصرف',
                    leading: IconButton(
                      splashRadius: 22,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),

                // Info banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSizes.md,
                      AppSizes.sm,
                      AppSizes.md,
                      AppSizes.sm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.sm + 2),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: .20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'أدخل سعر صرف كل عملة مقابل $baseLabel ($base).',
                              style: text.labelSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Base currency reference row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSizes.md,
                      0,
                      AppSizes.md,
                      AppSizes.sm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.sm + 2),
                      decoration: BoxDecoration(
                        color: tokens.border.withValues(alpha: .22),
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  baseLabel,
                                  style: text.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'العملة الافتراضية',
                                  style: text.labelSmall?.copyWith(
                                    color: tokens.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '1 $base',
                            textDirection: TextDirection.ltr,
                            style: text.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Rate rows
                SliverList.builder(
                  itemCount: others.length,
                  itemBuilder: (context, i) {
                    final entry = others[i];
                    final code = entry.key;
                    final label = entry.value;
                    final rate = settings.exchangeRates[code];
                    final controller = _controllerFor(code, rate);

                    return Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSizes.md,
                        0,
                        AppSizes.md,
                        AppSizes.sm,
                      ),
                      child: _RateRow(
                        code: code,
                        label: label,
                        baseCode: base,
                        controller: controller,
                        hasRate: rate != null,
                        onChanged: (v) {
                          final parsed = double.tryParse(v.replaceAll(',', ''));
                          if (parsed == null || parsed <= 0) {
                            ref
                                .read(appSettingsProvider.notifier)
                                .removeExchangeRate(code);
                          } else {
                            ref
                                .read(appSettingsProvider.notifier)
                                .setExchangeRate(code, parsed);
                          }
                        },
                      ),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.code,
    required this.label,
    required this.baseCode,
    required this.controller,
    required this.hasRate,
    required this.onChanged,
  });

  final String code;
  final String label;
  final String baseCode;
  final TextEditingController controller;
  final bool hasRate;
  final ValueChanged<String> onChanged;

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
        border: Border.all(
          color: hasRate
              ? colors.primary.withValues(alpha: .35)
              : tokens.border,
        ),
      ),
      child: Row(
        children: [
          // Currency code chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              textDirection: TextDirection.ltr,
              style: text.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '1 $code = ? $baseCode',
                  textDirection: TextDirection.ltr,
                  style: text.labelSmall?.copyWith(
                    color: tokens.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Rate input
          SizedBox(
            width: 90,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.end,
              textDirection: TextDirection.ltr,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: text.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: hasRate ? colors.primary : colors.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: '0',
                hintStyle: text.labelLarge?.copyWith(
                  color: tokens.textMuted.withValues(alpha: .35),
                  fontWeight: FontWeight.w800,
                ),
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: hasRate
                        ? colors.primary.withValues(alpha: .35)
                        : tokens.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: colors.primary, width: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
