import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/providers/settings_provider.dart';
import 'package:masrouf_v2/screens/widgets/widget_account_picker_screen.dart';
import 'package:masrouf_v2/theme/app_theme.dart';

const _widgetChannel = MethodChannel('com.prettysoft.masrouf/widget_config');

/// Dedicated lightweight widget UI runtime. The native Activity launches
/// [widgetEntryPoint] from `lib/main.dart`, which delegates here.
void runWidgetEntryPoint(List<String> args) {
  final mode = args.isNotEmpty ? args.first : '';
  final value = args.length > 1 ? args[1] : '';

  runApp(
    ProviderScope(
      child: WidgetEntryApp(mode: mode, value: value),
    ),
  );
}

class WidgetEntryApp extends ConsumerWidget {
  const WidgetEntryApp({super.key, required this.mode, required this.value});

  final String mode;
  final String value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final themeMode = settings?.themeMode ?? ThemeMode.system;
    final themeId = settings?.themeId ?? AppThemeId.defaultTheme;

    final Widget home = switch (mode) {
      'config' => _WidgetConfigHost(widgetId: int.tryParse(value) ?? 0),
      'action' => _WidgetActionHost(accountId: value),
      _ => const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.shrink(),
      ),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(themeId: themeId),
      darkTheme: AppTheme.dark(themeId: themeId),
      themeMode: themeMode,
      home: home,
    );
  }
}

class _WidgetConfigHost extends StatefulWidget {
  const _WidgetConfigHost({required this.widgetId});

  final int widgetId;

  @override
  State<_WidgetConfigHost> createState() => _WidgetConfigHostState();
}

class _WidgetConfigHostState extends State<_WidgetConfigHost> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showWidgetAccountPickerSheet(context, widgetId: widget.widgetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(),
    );
  }
}

class _WidgetActionHost extends ConsumerStatefulWidget {
  const _WidgetActionHost({required this.accountId});

  final String accountId;

  @override
  ConsumerState<_WidgetActionHost> createState() => _WidgetActionHostState();
}

class _WidgetActionHostState extends ConsumerState<_WidgetActionHost> {
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown) return;
    _shown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await showAddTransactionSheet(
        context,
        accountId: widget.accountId,
        useBackdropBlur: false,
      );

      if (!mounted) return;

      try {
        await _widgetChannel.invokeMethod('finishWidgetAction');
      } catch (e) {
        debugPrint('[WidgetAction] finish error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(),
    );
  }
}
