import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/report_data.dart';
import 'package:masrouf_v2/models/transaction.dart';

/// Palette used to color slices. Picked from your existing theme accents.
const List<Color> _slicePalette = [
  Color(0xFF2F3EE0),
  Color(0xFF3CCABC),
  Color(0xFF16A34A),
  Color(0xFFF49B07),
  Color(0xFFDC2626),
  Color(0xFF8B5CF6),
  Color(0xFF0EA5E9),
  Color(0xFFEC4899),
  Color(0xFF10B981),
  Color(0xFF6B7280),
];

/// Category → icon lookup (extend as needed).
const Map<String, IconData> _categoryIcons = {
  'مطاعم': Icons.restaurant_rounded,
  'تسوق': Icons.shopping_bag_rounded,
  'مواصلات': Icons.directions_car_rounded,
  'فواتير': Icons.receipt_long_rounded,
  'صحة': Icons.medical_services_rounded,
  'ترفيه': Icons.movie_rounded,
  'وقود': Icons.local_gas_station_rounded,
  'دخل': Icons.payments_rounded,
  'تسوية': Icons.restart_alt_rounded,
  'أخرى': Icons.more_horiz_rounded,
};

class ReportBuilder {
  ReportBuilder._();

  static ReportData build({
    required List<Transaction> transactions,
    required DateTimeRange range,
  }) {
    final inRange = transactions.where((t) {
      return !t.date.isBefore(range.start) && !t.date.isAfter(range.end);
    }).toList();

    double income = 0, expense = 0;
    final byCategory = <String, double>{};

    for (final t in inRange) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
        byCategory.update(
          t.category,
          (v) => v + t.amount,
          ifAbsent: () => t.amount,
        );
      }
    }

    // Categories sorted desc
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categories = <CategorySlice>[];
    for (var i = 0; i < sorted.length; i++) {
      final e = sorted[i];
      categories.add(
        CategorySlice(
          category: e.key,
          amount: e.value,
          color: _slicePalette[i % _slicePalette.length],
          icon: _categoryIcons[e.key] ?? Icons.category_rounded,
        ),
      );
    }

    // Months spanning the range
    final months = _monthsBetween(range.start, range.end, inRange);

    return ReportData(
      range: range,
      income: income,
      expense: expense,
      categories: categories,
      months: months,
    );
  }

  static List<MonthPoint> _monthsBetween(
    DateTime start,
    DateTime end,
    List<Transaction> tx,
  ) {
    final points = <MonthPoint>[];
    var cursor = DateTime(start.year, start.month, 1);
    final stop = DateTime(end.year, end.month, 1);

    while (!cursor.isAfter(stop)) {
      final next = DateTime(cursor.year, cursor.month + 1, 1);
      double inc = 0, exp = 0;
      for (final t in tx) {
        if (t.date.isBefore(cursor) || !t.date.isBefore(next)) continue;
        if (t.isIncome) {
          inc += t.amount;
        } else {
          exp += t.amount;
        }
      }
      points.add(MonthPoint(month: cursor, income: inc, expense: exp));
      cursor = next;
    }
    return points;
  }
}
