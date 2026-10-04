import 'package:flutter/material.dart';

@immutable
class Transaction {
  const Transaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.accountId,
    this.destinationAmount, // ← new
    this.iconColor,
    this.isIncome = false,
    this.toAccountId, // ← add this
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final double? destinationAmount;
  final DateTime date;
  final IconData icon;
  final String accountId;
  final Color? iconColor;
  final bool isIncome;

  /// When set, this transaction is a transfer to another account.
  final String? toAccountId; // ← and this

  bool get isTransfer => toAccountId != null;
}
