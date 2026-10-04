import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/transaction.dart';

@immutable
class DayGroup {
  const DayGroup({
    required this.day,
    required this.items,
    this.totalsByCurrency = const {},
  });

  final DateTime day;
  final List<Transaction> items;

  /// Net per currency for this day.
  /// Example: { 'SAR': -900.0, 'YER': 140000.0 }
  final Map<String, double> totalsByCurrency;

  double get income => items
      .where((t) => t.isIncome && !t.isTransfer)
      .fold(0.0, (s, t) => s + t.amount);

  double get expense => items
      .where((t) => !t.isIncome && !t.isTransfer)
      .fold(0.0, (s, t) => s + t.amount);

  /// Legacy single-value net (only valid for same-currency days).
  double get net => income - expense;
}
