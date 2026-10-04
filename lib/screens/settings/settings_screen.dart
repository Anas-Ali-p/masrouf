import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/screens/settings/screens/about_settings_screen.dart';
import 'package:masrouf_v2/screens/settings/screens/data_settings_screen.dart';
import 'package:masrouf_v2/screens/settings/screens/general_settings_screen.dart';
import 'package:masrouf_v2/screens/settings/screens/notifications_settings_screen.dart';
import 'package:masrouf_v2/screens/settings/screens/security_settings_screen.dart';
import 'package:masrouf_v2/screens/settings/widgets/profile_card.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_card.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_divider.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_group_tile.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
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
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top bar ────────────────────────────────
            const SliverToBoxAdapter(
              child: AppTopBar(showAvatar: false, title: 'الإعدادات'),
            ),

            // ── Profile card ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  AppSizes.sm,
                  AppSizes.md,
                  0,
                ),
                child: ProfileCard(
                  name: 'أحمد',
                  email: 'ahmed@example.com',
                  onEdit: () => _todo(context, 'تعديل الملف'),
                ),
              ),
            ),

            // ── Groups ─────────────────────────────────
            SliverToBoxAdapter(
              child: SettingsCard(
                children: [
                  SettingsGroupTile(
                    icon: Icons.tune_rounded,
                    title: 'عام',
                    subtitle: 'المظهر · اللغة · العملة',
                    count: 4,
                    onTap: () => _push(context, const GeneralSettingsScreen()),
                  ),
                  const SettingsDivider(),
                  SettingsGroupTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'الإشعارات',
                    subtitle: 'التنبيهات والملخصات',
                    count: 3,
                    onTap: () =>
                        _push(context, const NotificationsSettingsScreen()),
                  ),
                  const SettingsDivider(),
                  SettingsGroupTile(
                    icon: Icons.shield_outlined,
                    title: 'الأمان',
                    subtitle: 'القفل والبصمة',
                    count: 2,
                    onTap: () => _push(context, const SecuritySettingsScreen()),
                  ),
                  const SettingsDivider(),
                  SettingsGroupTile(
                    icon: Icons.folder_outlined,
                    title: 'البيانات',
                    subtitle: 'النسخ الاحتياطي والاستيراد',
                    count: 3,
                    onTap: () => _push(context, const DataSettingsScreen()),
                  ),
                  const SettingsDivider(),
                  SettingsGroupTile(
                    icon: Icons.info_outline_rounded,
                    title: 'حول',
                    subtitle: 'الخصوصية والمشاركة',
                    count: 4,
                    onTap: () => _push(context, const AboutSettingsScreen()),
                  ),
                ],
              ),
            ),

            // ── Sign out ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.md,
                  0,
                ),
                child: OutlinedButton.icon(
                  onPressed: () => _todo(context, 'تسجيل الخروج'),
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('تسجيل الخروج'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: .35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    textStyle: text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // ── Footer ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSizes.lg),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'صُنع بـ ♥',
                        style: text.labelSmall?.copyWith(
                          color: tokens.textMuted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الإصدار 1.0.0 (build 1)',
                        style: text.labelSmall?.copyWith(
                          color: tokens.textMuted,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}
