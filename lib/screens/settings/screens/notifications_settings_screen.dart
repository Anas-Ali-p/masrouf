import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_card.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_divider.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_tile.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

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
                  title: 'الإشعارات',
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
                      icon: Icons.receipt_long_rounded,
                      title: 'تنبيهات العمليات',
                      subtitle: 'عند إضافة عملية جديدة',
                      trailingSwitch: settings.notifTransactions,
                      onSwitchChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .setNotifTransactions(v),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.savings_rounded,
                      title: 'تنبيهات الميزانية',
                      subtitle: 'عند تجاوز الحد',
                      trailingSwitch: settings.notifBudget,
                      onSwitchChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .setNotifBudget(v),
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.mark_email_read_rounded,
                      title: 'ملخص أسبوعي',
                      subtitle: 'رسالة أسبوعية بالإحصائيات',
                      trailingSwitch: settings.notifWeekly,
                      onSwitchChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .setNotifWeekly(v),
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
