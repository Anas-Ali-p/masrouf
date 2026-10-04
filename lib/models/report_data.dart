import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/transaction.dart';

@immutable
class CategorySlice {
  const CategorySlice({
    required this.category,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String category;
  final double amount;
  final Color color;
  final IconData icon;
}

@immutable
class MonthPoint {
  const MonthPoint({
    required this.month,
    required this.income,
    required this.expense,
  });

  final DateTime month;
  final double income;
  final double expense;
}

@immutable
class ReportData {
  const ReportData({
    required this.range,
    required this.income,
    required this.expense,
    required this.categories,
    required this.months,
  });

  final DateTimeRange range;
  final double income;
  final double expense;
  final List<CategorySlice> categories;
  final List<MonthPoint> months;

  double get net => income - expense;

  bool get isEmpty => income == 0 && expense == 0;
}
