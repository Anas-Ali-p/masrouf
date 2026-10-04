import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masrouf_v2/core/widgets/nav/app_bottom_nav_bar.dart';
import 'package:masrouf_v2/core/widgets/nav/app_bottom_nav_items.dart';
import 'package:masrouf_v2/screens/add_transaction/add_transaction_sheet.dart';
import 'package:masrouf_v2/screens/home/home_screen.dart';
import 'package:masrouf_v2/screens/reports/reports_screen.dart';
import 'package:masrouf_v2/screens/settings/settings_screen.dart';
import 'package:masrouf_v2/screens/transactions/transactions_screen.dart';
import 'package:masrouf_v2/theme/app_sizes.dart';
import 'package:masrouf_v2/theme/theme_context.dart';
import 'package:masrouf_v2/utils/app_snackbar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = AppNavDestination.home.index;

  /// Timestamp of the last back press on Home, used for double-back-to-exit.
  DateTime? _lastBackPress;

  /// Window in which a second back press counts as "exit".
  static const _exitWindow = Duration(seconds: 2);

  static const List<Widget> _pages = [
    HomeScreen(),
    TransactionsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

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
    final tokens = context.tokens;
    final colors = context.colors;

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
