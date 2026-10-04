import 'package:flutter/material.dart';

enum TransactionType { expense, income, transfer }

@immutable
class NewTransactionDraft {
  const NewTransactionDraft({
    required this.type,
    this.amount = 0,
    this.categoryId,
    this.accountId,
    this.toAccountId,
    this.date,
    this.note,
  });

  final TransactionType type;
  final double amount;
  final String? categoryId;
  final String? accountId;
  final String? toAccountId;
  final DateTime? date;
  final String? note;

  bool get isValid =>
      amount > 0 &&
      accountId != null &&
      (type != TransactionType.transfer || toAccountId != null);

  NewTransactionDraft copyWith({
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    DateTime? date,
    String? note,
  }) => NewTransactionDraft(
    type: type ?? this.type,
    amount: amount ?? this.amount,
    categoryId: categoryId ?? this.categoryId,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId ?? this.toAccountId,
    date: date ?? this.date,
    note: note ?? this.note,
  );
}
