import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _themeKey = 'themeMode';
  static const _currencyKey = 'currency';
  static const _currencyLabelKey = 'currencyLabel';
  static const _languageKey = 'language';
  static const _hideBalancesKey = 'hideBalances';
  static const _biometricKey = 'biometric';
  static const _appLockKey = 'appLock';
  static const _notifTransactionsKey = 'notifTransactions';
  static const _notifBudgetKey = 'notifBudget';
  static const _notifWeeklyKey = 'notifWeekly';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static const _ratesKey = 'exchangeRates';

  // Theme
  Future<ThemeMode> getThemeMode() async {
    final p = await _prefs;
    final v = p.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == v,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final p = await _prefs;
    await p.setString(_themeKey, mode.name);
  }

  // Currency
  Future<String> getCurrency() async =>
      (await _prefs).getString(_currencyKey) ?? 'SAR';

  Future<void> setCurrency(String code, String label) async {
    final p = await _prefs;
    await p.setString(_currencyKey, code);
    await p.setString(_currencyLabelKey, label);
  }

  Future<String> getCurrencyLabel() async =>
      (await _prefs).getString(_currencyLabelKey) ?? 'ريال سعودي';

  // Language
  Future<String> getLanguage() async =>
      (await _prefs).getString(_languageKey) ?? 'العربية';

  // Booleans — one generic pair
  Future<bool> _getBool(String key, {bool fallback = false}) async =>
      (await _prefs).getBool(key) ?? fallback;

  Future<void> _setBool(String key, bool value) async {
    final p = await _prefs;
    await p.setBool(key, value);
  }

  Future<bool> getHideBalances() => _getBool(_hideBalancesKey);
  Future<void> setHideBalances(bool v) => _setBool(_hideBalancesKey, v);

  Future<bool> getBiometric() => _getBool(_biometricKey);
  Future<void> setBiometric(bool v) => _setBool(_biometricKey, v);

  Future<bool> getAppLock() => _getBool(_appLockKey);
  Future<void> setAppLock(bool v) => _setBool(_appLockKey, v);

  Future<bool> getNotifTransactions() =>
      _getBool(_notifTransactionsKey, fallback: true);
  Future<void> setNotifTransactions(bool v) =>
      _setBool(_notifTransactionsKey, v);

  Future<bool> getNotifBudget() => _getBool(_notifBudgetKey, fallback: true);
  Future<void> setNotifBudget(bool v) => _setBool(_notifBudgetKey, v);

  Future<bool> getNotifWeekly() => _getBool(_notifWeeklyKey);
  Future<void> setNotifWeekly(bool v) => _setBool(_notifWeeklyKey, v);

  Future<Map<String, double>> getExchangeRates() async {
    final p = await _prefs;
    final raw = p.getString(_ratesKey);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  Future<void> setExchangeRates(Map<String, double> rates) async {
    final p = await _prefs;
    await p.setString(_ratesKey, jsonEncode(rates));
  }
}
