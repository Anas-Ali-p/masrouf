import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/theme/app_theme.dart';

class WidgetService {
  static const String providerName = 'HomeWidgetProvider';
  static const String _stateKey = 'widget_state_v2';
  static const MethodChannel _channel = MethodChannel(
    'com.prettysoft.masrouf/widget_config',
  );

  /// Stores the widget/account binding and current account cache in one payload.
  ///
  /// The previous implementation wrote 4 separate keys for every widget plus
  /// a second write for the active-widget registry. This payload keeps the
  /// number of SharedPreferences writes effectively constant per operation.
  static Future<void> configureWidget({
    required int widgetId,
    required Account account,
    required List<Account> accounts,
  }) async {
    final state = await _readState();

    final widgets = _asStringMap(state['widgets']);
    final legacyWidgets = await _readLegacyWidgets();

    // Preserve any widgets configured by older app versions.
    for (final entry in legacyWidgets.entries) {
      widgets.putIfAbsent(entry.key, () => entry.value);
    }

    widgets['$widgetId'] = account.id;
    _removeBindingsForMissingAccounts(widgets, accounts);

    final payload = <String, dynamic>{
      'version': 2,
      'widgets': widgets,
      'accounts': _buildAccountCache(accounts, widgets.values),
      if (state['theme'] != null) 'theme': state['theme'],
    };

    await _writeState(payload);
    await HomeWidget.updateWidget(androidName: providerName);
  }

  /// Refreshes the single shared widget payload for all installed instances.
  static Future<void> updateAllWidgets({
    required List<Account> accounts,
  }) async {
    final state = await _readState();
    final widgets = _asStringMap(state['widgets']);
    final legacyWidgets = await _readLegacyWidgets();

    // Merge legacy bindings even when v2 already contains other instances.
    for (final entry in legacyWidgets.entries) {
      widgets.putIfAbsent(entry.key, () => entry.value);
    }

    if (widgets.isEmpty) {
      return;
    }

    // A deleted/archived account must not leave an actionable widget pointing
    // at an account that no longer exists. The widget can remain placed, but
    // it becomes an unconfigured placeholder until the user reconfigures it.
    _removeBindingsForMissingAccounts(widgets, accounts);

    final payload = <String, dynamic>{
      'version': 2,
      'widgets': widgets,
      'accounts': _buildAccountCache(accounts, widgets.values),
      if (state['theme'] != null) 'theme': state['theme'],
    };

    await _writeState(payload);
    await HomeWidget.updateWidget(androidName: providerName);
  }


  static int _toAndroidColor(Color color) {
    final value = color.toARGB32();
    return value > 0x7FFFFFFF ? value - 0x100000000 : value;
  }

  /// Synchronizes only the widget background/text colors with the app theme.
  /// The XML/layout structure remains unchanged.
  static Future<void> syncThemeColors({
    required AppThemeId themeId,
    required ThemeMode themeMode,
  }) async {
    final brightness = switch (themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };

    final theme = brightness == Brightness.dark
        ? AppTheme.dark(themeId: themeId)
        : AppTheme.light(themeId: themeId);

    final state = await _readState();
    state['theme'] = <String, Object>{
      'background': _toAndroidColor(theme.colorScheme.surface),
      'text': _toAndroidColor(theme.colorScheme.onSurface),
    };

    await _writeState(state);
    await HomeWidget.updateWidget(androidName: providerName);
  }

  static void _removeBindingsForMissingAccounts(
    Map<String, String> widgets,
    List<Account> accounts,
  ) {
    final accountIds = accounts.map((account) => account.id).toSet();
    widgets.removeWhere((_, accountId) => !accountIds.contains(accountId));
  }

  static Map<String, dynamic> _buildAccountCache(
    List<Account> accounts,
    Iterable<String> widgetAccountIds,
  ) {
    final ids = widgetAccountIds.toSet();

    return <String, dynamic>{
      for (final account in accounts)
        if (ids.contains(account.id))
          account.id: <String, dynamic>{
            'name': account.name,
            'balance': NumberFormat('#,##0.00', 'en').format(account.balance),
            'currency': account.currency,
          },
    };
  }

  static Map<String, String> _asStringMap(Object? value) {
    if (value is! Map) return <String, String>{};

    return <String, String>{
      for (final entry in value.entries)
        entry.key.toString(): entry.value?.toString() ?? '',
    };
  }

  static Future<Map<String, dynamic>> _readState() async {
    final raw = await HomeWidget.getWidgetData<String>(_stateKey);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (e) {
      debugPrint('[WidgetService] invalid widget state: $e');
      return <String, dynamic>{};
    }
  }

  static Future<Map<String, String>> _readLegacyWidgets() async {
    final rawIds = await HomeWidget.getWidgetData<String>('active_widget_ids');
    if (rawIds == null || rawIds.isEmpty) {
      return <String, String>{};
    }

    final result = <String, String>{};

    for (final rawId in rawIds.split(',')) {
      final widgetId = int.tryParse(rawId);
      if (widgetId == null) continue;

      final accountId = await HomeWidget.getWidgetData<String>(
        'account_id_$widgetId',
      );

      if (accountId != null && accountId.isNotEmpty) {
        result['$widgetId'] = accountId;
      }
    }

    return result;
  }

  static Future<void> _writeState(Map<String, dynamic> state) async {
    final ok = await _channel.invokeMethod<bool>(
      'saveWidgetState',
      <String, Object>{'state': jsonEncode(state)},
    );

    if (ok != true) {
      throw StateError('Unable to persist widget state');
    }
  }
}
