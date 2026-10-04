import 'package:flutter/material.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_card.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_divider.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_tile.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  void _todo(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — قريباً'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = context.text;
    final tokens = context.tokens;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppTopBar(
                showAvatar: false,
                title: 'حول',
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
                    icon: Icons.star_outline_rounded,
                    title: 'قيّم التطبيق',
                    onTap: () => _todo(context, 'تقييم التطبيق'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.share_outlined,
                    title: 'شارك التطبيق',
                    onTap: () => _todo(context, 'مشاركة التطبيق'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    onTap: () => _todo(context, 'سياسة الخصوصية'),
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.tag_rounded,
                    title: 'الإصدار',
                    trailingText: '1.0.0',
                    showChevron: false,
                  ),
                ],
              ),
            ),
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
