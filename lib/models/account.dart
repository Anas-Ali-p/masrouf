import 'package:flutter/material.dart';

enum AccountType { checking, savings, wallet, credit }

@immutable
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.currency,
    required this.balance,
    this.category, // ← new
    this.accentColor,
    this.type = AccountType.checking,
    this.accountNumber,
    this.note,
    this.createdAt,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
  });

  final String id;
  final String name;
  final String? category; // ← new
  final String currency;
  final double balance;
  final Color? accentColor;
  final AccountType type;

  /// Masked display number, e.g. "···· 4821".
  final String? accountNumber;
  final String? note;
  final DateTime? createdAt;

  /// Aggregates for the current month.
  final double monthlyIncome;
  final double monthlyExpense;

  double get monthlyNet => monthlyIncome - monthlyExpense;
}

extension AccountTypeX on AccountType {
  String get label => switch (this) {
    AccountType.checking => 'حساب جاري',
    AccountType.savings => 'حساب توفير',
    AccountType.wallet => 'محفظة',
    AccountType.credit => 'بطاقة ائتمان',
  };

  IconData get icon => switch (this) {
    AccountType.checking => Icons.account_balance_rounded,
    AccountType.savings => Icons.savings_rounded,
    AccountType.wallet => Icons.account_balance_wallet_rounded,
    AccountType.credit => Icons.credit_card_rounded,
  };
}
