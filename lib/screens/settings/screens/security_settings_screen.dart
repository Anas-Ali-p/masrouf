import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/screens/settings/screens/app_lock_screen.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_card.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_divider.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_tile.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

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
                  title: 'الأمان',
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
                      icon: Icons.lock_outline_rounded,
                      title: 'قفل التطبيق',
                      subtitle: settings.appLock
                          ? 'مُفعّل · رمز من 6 خانات'
                          : 'رمز PIN عند الفتح',
                      trailingSwitch: settings.appLock,
                      onSwitchChanged: (v) async {
                        if (v) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AppLockScreen(),
                            ),
                          );
                        } else {
                          await ref
                              .read(appSettingsProvider.notifier)
                              .setAppLock(false);
                        }
                      },
                    ),
                    const SettingsDivider(),
                    SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      title: 'البصمة',
                      subtitle: 'فتح سريع بالبصمة',
                      trailingSwitch: settings.biometric,
                      onSwitchChanged: (v) => ref
                          .read(appSettingsProvider.notifier)
                          .setBiometric(v),
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
