import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:masrouf_v2/core/widgets/nav/app_top_bar.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_card.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_divider.dart';
import 'package:masrouf_v2/screens/settings/widgets/settings_tile.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/app_snackbar.dart';
import 'package:masrouf_v2/utils/data_backup.dart';

class DataSettingsScreen extends ConsumerStatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  ConsumerState<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends ConsumerState<DataSettingsScreen> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await DataBackup.export(ref.read(databaseProvider));
      if (mounted) {
        showAppSnack(
          context,
          message: 'تم إنشاء النسخة الاحتياطية',
          kind: SnackKind.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(
          context,
          message: 'فشل التصدير: $e',
          kind: SnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    final replace = await _confirmReplace();
    if (replace == null) return;

    setState(() => _busy = true);
    try {
      final file = await File(path).readAsString();
      final stats = await DataBackup.restoreFromJson(
        ref.read(databaseProvider),
        file,
        replaceAll: replace,
      );
      if (mounted) {
        showAppSnack(
          context,
          message:
              'تم الاستيراد: ${stats.accounts} حساب، ${stats.transactions} عملية',
          kind: SnackKind.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnack(
          context,
          message: 'فشل الاستيراد: $e',
          kind: SnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmReplace() {
    final colors = context.colors;
    final text = context.text;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'طريقة الاستيراد',
          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'هل تريد استبدال البيانات الحالية؟\nاختر "دمج" للاحتفاظ بها وإضافة الجديدة.',
          style: text.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('دمج'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: colors.error),
            child: const Text('استبدال'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppTopBar(
                showAvatar: false,
                title: 'البيانات',
                leading: IconButton(
                  splashRadius: 22,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                actions: [
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: SettingsCard(
                children: [
                  SettingsTile(
                    icon: Icons.cloud_upload_outlined,
                    title: 'نسخة احتياطية',
                    subtitle: 'تصدير جميع البيانات كملف JSON',
                    onTap: _export,
                  ),
                  const SettingsDivider(),
                  SettingsTile(
                    icon: Icons.file_download_outlined,
                    title: 'استعادة البيانات',
                    subtitle: 'من ملف JSON',
                    onTap: _restore,
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
      ),
    );
  }
}
