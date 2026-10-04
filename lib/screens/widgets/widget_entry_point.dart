import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/screens/widgets/widget_account_picker_screen.dart';
import 'package:masrouf_v2/services/widget_service.dart';
import 'package:masrouf_v2/theme/app_theme.dart';

const _widgetChannel = MethodChannel('com.example.masrouf_v2/widget_config');

/// Dedicated lightweight widget UI runtime. The native Activity launches
/// [widgetEntryPoint] from `lib/main.dart`, which delegates here.
void runWidgetEntryPoint(List<String> args) {
  final mode = args.isNotEmpty ? args.first : '';
  final value = args.length > 1 ? args[1] : '';

  runApp(
    ProviderScope(
      child: WidgetEntryApp(
        mode: mode,
        value: value,
      ),
    ),
  );
}

class WidgetEntryApp extends StatelessWidget {
  const WidgetEntryApp({
    super.key,
    required this.mode,
    required this.value,
  });

  final String mode;
  final String value;

  @override
  Widget build(BuildContext context) {
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
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
      showWidgetAccountPickerSheet(
        context,
        widgetId: widget.widgetId,
      );
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

      final saved = await showAddTransactionSheet(
        context,
        accountId: widget.accountId,
        useBackdropBlur: false,
      );

      if (!mounted) return;

      if (saved == true) {
        try {
          final accounts = await ref
              .read(accountRepositoryProvider)
              .watchAll()
              .first;
          await WidgetService.updateAllWidgets(accounts: accounts);
        } catch (e, stack) {
          debugPrint('[WidgetAction] sync error: $e');
          debugPrint('[WidgetAction] sync stack: $stack');
        }
      }

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
