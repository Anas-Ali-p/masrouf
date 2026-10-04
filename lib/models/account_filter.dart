import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/new_transaction.dart';
import 'package:masrouf_v2/models/transaction.dart';

enum DateRangePreset {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  last30Days,
  thisYear,
  custom,
}

extension DateRangePresetX on DateRangePreset {
  String get label => switch (this) {
    DateRangePreset.all => 'الكل',
    DateRangePreset.today => 'اليوم',
    DateRangePreset.yesterday => 'أمس',
    DateRangePreset.thisWeek => 'هذا الأسبوع',
    DateRangePreset.thisMonth => 'هذا الشهر',
    DateRangePreset.last30Days => 'آخر 30 يوم',
    DateRangePreset.thisYear => 'هذا العام',
    DateRangePreset.custom => 'مخصص',
  };

  /// Returns null for `all`, otherwise the [from, to] window.
  DateTimeRange? resolve() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case DateRangePreset.all:
        return null;
      case DateRangePreset.today:
        return DateTimeRange(
          start: today,
          end: today.add(const Duration(days: 1)),
        );
      case DateRangePreset.yesterday:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 1)),
          end: today,
        );
      case DateRangePreset.thisWeek:
        // Week starts Saturday in most Arabic locales; fall back to
        // Sunday if you prefer. `weekday` is 1=Mon..7=Sun.
        final daysFromSat = (today.weekday + 1) % 7;
        final start = today.subtract(Duration(days: daysFromSat));
        return DateTimeRange(
          start: start,
          end: start.add(const Duration(days: 7)),
        );
      case DateRangePreset.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return DateTimeRange(start: start, end: end);
      case DateRangePreset.last30Days:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 29)),
          end: today.add(const Duration(days: 1)),
        );
      case DateRangePreset.thisYear:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year + 1, 1, 1),
        );
      case DateRangePreset.custom:
        return null; // handled by the caller
    }
  }
}

@immutable
class AccountFilter {
  const AccountFilter({
    this.types = const {}, // empty = all types
    this.categoryIds = const {}, // empty = all categories
    this.datePreset = DateRangePreset.all,
    this.customRange,
  });

  /// Empty set means "no type filter".
  final Set<TransactionType> types;

  /// Empty set means "no category filter".
  final Set<String> categoryIds;

  final DateRangePreset datePreset;
  final DateTimeRange? customRange;

  bool get isEmpty =>
      types.isEmpty && categoryIds.isEmpty && datePreset == DateRangePreset.all;

  int get activeCount =>
      (types.isNotEmpty ? 1 : 0) +
      (categoryIds.isNotEmpty ? 1 : 0) +
      (datePreset != DateRangePreset.all ? 1 : 0);

  AccountFilter copyWith({
    Set<TransactionType>? types,
    Set<String>? categoryIds,
    DateRangePreset? datePreset,
    DateTimeRange? customRange,
    bool clearCustomRange = false,
  }) => AccountFilter(
    types: types ?? this.types,
    categoryIds: categoryIds ?? this.categoryIds,
    datePreset: datePreset ?? this.datePreset,
    customRange: clearCustomRange ? null : (customRange ?? this.customRange),
  );

  bool matches(Transaction t) {
    // Type
    if (types.isNotEmpty) {
      final isTransfer = t.category == 'تحويل';
      final txType = isTransfer
          ? TransactionType.transfer
          : (t.isIncome ? TransactionType.income : TransactionType.expense);
      if (!types.contains(txType)) return false;
    }

    // Category
    if (categoryIds.isNotEmpty && !categoryIds.contains(t.category)) {
      return false;
    }

    // Date
    final range = datePreset == DateRangePreset.custom
        ? customRange
        : datePreset.resolve();
    if (range != null) {
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final end = DateTime(range.end.year, range.end.month, range.end.day);
      if (t.date.isBefore(start) || t.date.isAfter(end)) return false;
    }

    return true;
  }
}

// Re-use the existing TransactionType enum — but it lives in
// new_transaction.dart. Import it here.
