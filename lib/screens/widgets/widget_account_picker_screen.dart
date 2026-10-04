import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/providers/accounts_provider.dart';
import 'package:masrouf_v2/services/widget_service.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';

const _widgetChannel = MethodChannel('com.example.masrouf_v2/widget_config');

Future<bool?> showWidgetAccountPickerSheet(
  BuildContext context, {
  required int widgetId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: context.colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusLg),
      ),
    ),
    builder: (_) => Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .82,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
        color: context.colors.surface,
      ),
      child: WidgetAccountPickerScreen(widgetId: widgetId),
    ),
  );
}

class WidgetAccountPickerScreen extends ConsumerStatefulWidget {
  const WidgetAccountPickerScreen({super.key, required this.widgetId});

  final int widgetId;

  @override
  ConsumerState<WidgetAccountPickerScreen> createState() =>
      _WidgetAccountPickerScreenState();
}

class _WidgetAccountPickerScreenState
    extends ConsumerState<WidgetAccountPickerScreen> {
  bool _saving = false;
  bool _cancelling = false;

  Future<void> _cancelConfiguration() async {
    if (_cancelling) return;
    _cancelling = true;

    try {
      await _widgetChannel.invokeMethod('cancelConfiguration');
    } catch (_) {}
  }

  Future<void> _selectAccount(
    Account account,
    List<Account> accounts,
  ) async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      await WidgetService.configureWidget(
        widgetId: widget.widgetId,
        account: account,
        accounts: accounts,
      );

      await _widgetChannel.invokeMethod('finishConfiguration');
    } catch (e, stack) {
      if (!mounted) return;
      setState(() => _saving = false);

      debugPrint('[Widget] save error: $e');
      debugPrint('[Widget] stack: $stack');

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تعذر حفظ الحساب'),
          content: SingleChildScrollView(
            child: Text('$e\n\n$stack', style: const TextStyle(fontSize: 11)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _handleBack() async {
    await _cancelConfiguration();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    final accountsAsync = ref.watch(accountsProvider);

    return WillPopScope(
      onWillPop: _handleBack,
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.textMuted.withValues(alpha: .35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.sm,
                AppSizes.xs,
                AppSizes.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختر الحساب',
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'إلغاء',
                    onPressed: _saving ? null : _cancelConfiguration,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: accountsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.xl),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.xl),
                    child: Text(
                      'حدث خطأ: $e',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium,
                    ),
                  ),
                ),
                data: (accounts) {
                  if (accounts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: .10),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 30,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد حسابات',
                              style: text.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'أضف حساباً أولاً من التطبيق، ثم عد لإضافة الويدجت.',
                              textAlign: TextAlign.center,
                              style: text.labelMedium?.copyWith(
                                color: tokens.textMuted,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      0,
                      AppSizes.md,
                      AppSizes.md,
                    ),
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final account = accounts[i];
                      return _AccountTile(
                        account: account,
                        onTap: _saving ? null : () => _selectAccount(account, accounts),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, this.onTap});

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tokens = context.tokens;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.sm + 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: account.accentColor ?? colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      account.name,
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.currency} • ${account.balance.toStringAsFixed(2)}',
                      textDirection: TextDirection.ltr,
                      style: text.labelSmall?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: tokens.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
