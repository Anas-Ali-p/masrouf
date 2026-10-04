import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/data/repositories/settings_repository.dart';
import 'package:masrouf_v2/providers/app_providers.dart';

@immutable
class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.currency = 'SAR',
    this.currencyLabel = 'ريال سعودي',
    this.language = 'العربية',
    this.hideBalances = false,
    this.biometric = false,
    this.appLock = false,
    this.notifTransactions = true,
    this.notifBudget = true,
    this.notifWeekly = false,
    this.exchangeRates = const {}, // ← new: currency -> rate in default
    this.appPin, // ← new: hashed PIN or null
  });

  final ThemeMode themeMode;
  final String currency;
  final String currencyLabel;
  final String language;
  final bool hideBalances;
  final bool biometric;
  final bool appLock;
  final bool notifTransactions;
  final bool notifBudget;
  final bool notifWeekly;

  /// Rates relative to the default currency.
  /// Example: { 'USD': 535.0, 'SAR': 140.0 } when default is YER.
  final Map<String, double> exchangeRates;

  /// Hashed app PIN. Null when no lock is configured.
  final String? appPin;

  String get themeLabel => switch (themeMode) {
    ThemeMode.system => 'تلقائي',
    ThemeMode.light => 'فاتح',
    ThemeMode.dark => 'داكن',
  };

  // ── Conversion helper ─────────────────────────────
  /// Converts [amount] from [from] to [to]. Returns null if a rate is
  /// missing for either currency.
  double? convert(double amount, String from, String to) {
    if (from == to) return amount;
    final fromRate = from == currency ? 1.0 : exchangeRates[from];
    final toRate = to == currency ? 1.0 : exchangeRates[to];
    if (fromRate == null || toRate == null) return null;
    return amount * fromRate / toRate;
  }

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    String? currency,
    String? currencyLabel,
    String? language,
    bool? hideBalances,
    bool? biometric,
    bool? appLock,
    bool? notifTransactions,
    bool? notifBudget,
    bool? notifWeekly,
    Map<String, double>? exchangeRates,
    String? appPin,
    bool clearPin = false,
  }) => AppSettingsState(
    themeMode: themeMode ?? this.themeMode,
    currency: currency ?? this.currency,
    currencyLabel: currencyLabel ?? this.currencyLabel,
    language: language ?? this.language,
    hideBalances: hideBalances ?? this.hideBalances,
    biometric: biometric ?? this.biometric,
    appLock: appLock ?? this.appLock,
    notifTransactions: notifTransactions ?? this.notifTransactions,
    notifBudget: notifBudget ?? this.notifBudget,
    notifWeekly: notifWeekly ?? this.notifWeekly,
    exchangeRates: exchangeRates ?? this.exchangeRates,
    appPin: clearPin ? null : (appPin ?? this.appPin),
  );
}

class AppSettingsNotifier extends AsyncNotifier<AppSettingsState> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  Future<AppSettingsState> build() async {
    return AppSettingsState(
      themeMode: await _repo.getThemeMode(),
      currency: await _repo.getCurrency(),
      currencyLabel: await _repo.getCurrencyLabel(),
      language: await _repo.getLanguage(),
      hideBalances: await _repo.getHideBalances(),
      biometric: await _repo.getBiometric(),
      appLock: await _repo.getAppLock(),
      notifTransactions: await _repo.getNotifTransactions(),
      notifBudget: await _repo.getNotifBudget(),
      notifWeekly: await _repo.getNotifWeekly(),
      exchangeRates: await _repo.getExchangeRates(),
    );
  }

  Future<void> setCurrency(String code, String label) async {
    await _repo.setCurrency(code, label);
    state = AsyncData(
      state.value!.copyWith(currency: code, currencyLabel: label),
    );
  }

  Future<void> setExchangeRate(String currency, double rate) async {
    final current = Map<String, double>.from(state.value!.exchangeRates);
    current[currency] = rate;
    await _repo.setExchangeRates(current);
    state = AsyncData(state.value!.copyWith(exchangeRates: current));
  }

  Future<void> removeExchangeRate(String currency) async {
    final current = Map<String, double>.from(state.value!.exchangeRates)
      ..remove(currency);
    await _repo.setExchangeRates(current);
    state = AsyncData(state.value!.copyWith(exchangeRates: current));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repo.setThemeMode(mode);
    state = AsyncData(state.value!.copyWith(themeMode: mode));
  }

  Future<void> setHideBalances(bool v) async {
    await _repo.setHideBalances(v);
    state = AsyncData(state.value!.copyWith(hideBalances: v));
  }

  Future<void> setBiometric(bool v) async {
    await _repo.setBiometric(v);
    state = AsyncData(state.value!.copyWith(biometric: v));
  }

  Future<void> setAppLock(bool v) async {
    await _repo.setAppLock(v);
    state = AsyncData(state.value!.copyWith(appLock: v));
  }

  Future<void> setNotifTransactions(bool v) async {
    await _repo.setNotifTransactions(v);
    state = AsyncData(state.value!.copyWith(notifTransactions: v));
  }

  Future<void> setNotifBudget(bool v) async {
    await _repo.setNotifBudget(v);
    state = AsyncData(state.value!.copyWith(notifBudget: v));
  }

  Future<void> setNotifWeekly(bool v) async {
    await _repo.setNotifWeekly(v);
    state = AsyncData(state.value!.copyWith(notifWeekly: v));
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );
