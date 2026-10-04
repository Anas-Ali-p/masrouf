import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/screens/settings/widgets/currency_picker_sheet.dart';
import 'package:masrouf_v2/screens/settings/screens/exchange_rates_screen.dart';
import 'package:masrouf_v2/screens/settings/widgets/currency_picker_sheet.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_card.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_divider.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_tile.dart';
import 'package:masrouf_v2/screens/settings/widgets/theme_mode_sheet.dart';

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current =
        ref.read(appSettingsProvider).valueOrNull?.themeMode ??
        ThemeMode.system;
    final result = await showThemeModeSheet(context, current: current);
    if (result != null) {
      await ref.read(appSettingsProvider.notifier).setThemeMode(result);
    }
  }

  void _todo(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — قريباً'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (settings) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: AppTopBar(
                  showAvatar: false,
                  title: 'عام',
                  leading: IconButton(
                    splashRadius: 22,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SettingsCard(
                  children: [
                    SettingsTile(
                      icon: Icons.brightness_6_rounded,
                      title: 'المظهر',
                      subtitle: 'اختر بين الفاتح والداكن',
                      trailingText: settings.themeLabel,
                      onTap: () => _pickTheme(context, ref),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.language_rounded,
                      title: 'اللغة',
                      trailingText: settings.language,
                      onTap: () => _todo(context, 'تغيير اللغة'),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.attach_money_rounded,
                      title: 'العملة الافتراضية',
                      trailingText:
                          '${settings.currency} - ${settings.currencyLabel}',
                      onTap: () => showCurrencyPickerSheet(context),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.swap_vert_rounded,
                      title: 'أسعار الصرف',
                      subtitle: 'التحويل بين العملات',
                      trailingText: '${settings.exchangeRates.length}',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ExchangeRatesScreen(),
                        ),
                      ),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.visibility_off_rounded,
                      title: 'إخفاء الأرصدة',
                      subtitle: 'إخفاء الأرقام في الشاشات',
                      trailingSwitch: settings.hideBalances,
                      onSwitchChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .setHideBalances(v),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }
}
