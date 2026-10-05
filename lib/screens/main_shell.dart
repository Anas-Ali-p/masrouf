import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:masrouf_v2/core/widgets/nav/app_bottom_nav_bar.dart';
import 'package:masrouf_v2/core/widgets/nav/app_bottom_nav_items.dart';
import 'package:masrouf_v2/providers/app_providers.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/screens/home/home_screen.dart';
import 'package:masrouf_v2/screens/reports/reports_screen.dart';
import 'package:masrouf_v2/screens/settings/settings_screen.dart';
import 'package:masrouf_v2/screens/transactions/transactions_screen.dart';
import 'package:masrouf_v2/utils/app_snackbar.dart';
import 'package:masrouf_v2/utils/data_backup.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  int _currentIndex = AppNavDestination.home.index;

  /// Timestamp of the last back press on Home, used for double-back-to-exit.
  DateTime? _lastBackPress;

  /// Window in which a second back press counts as "exit".
  static const _exitWindow = Duration(seconds: 2);

  Timer? _automaticBackupTimer;

  static const List<Widget> _pages = [
    HomeScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAutomaticBackup();
    });
    _automaticBackupTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => _runAutomaticBackup(),
    );
  }

  @override
  void dispose() {
    _automaticBackupTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runAutomaticBackup();
    }
  }

  Future<void> _runAutomaticBackup() async {
    try {
      await DataBackup.createDailyBackup(ref.read(databaseProvider));
    } catch (e, stackTrace) {
      debugPrint('[AUTO BACKUP] error: $e');
      debugPrint('[AUTO BACKUP STACK] $stackTrace');
    }
  }

  bool get _isHome => _currentIndex == AppNavDestination.home.index;

  // ── Back handling ──────────────────────────────────────
  void _handleBack(bool didPop, Object? result) {
    if (didPop) return;

    // 1) Not on Home → go Home.
    if (!_isHome) {
      setState(() => _currentIndex = AppNavDestination.home.index);
      return;
    }

    // 2) On Home → double-back to exit.
    final now = DateTime.now();
    final last = _lastBackPress;

    if (last == null || now.difference(last) > _exitWindow) {
      _lastBackPress = now;
      _showExitHint();
      return;
    }

    // Second press within the window → exit.
    SystemNavigator.pop();
  }

  void _showExitHint() {
    showAppSnack(
      context,
      message: 'اضغط مرة أخرى للخروج',
      kind: SnackKind.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handleBack,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(index: _currentIndex, children: _pages),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppBottomNavBar(
                items: kNavItems,
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
                onAdd: () async {
                  final saved = await showAddTransactionSheet(context);
                  // Nothing else needed — the providers auto-refresh.
                  if (saved == true) {
                    debugPrint('Transaction saved');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
