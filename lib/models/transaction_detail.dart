import 'package:flutter/material.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/models/transaction.dart';

@immutable
class TransactionDetail {
  const TransactionDetail({
    required this.transaction,
    this.account,
    this.toAccount,
    this.note,
    this.reference,
    this.balanceBefore,
    this.balanceAfter,
  });

  final Transaction transaction;

  /// Full account — lets the screen navigate to AccountDetailsScreen.
  final Account? account;
  final Account? toAccount;

  final String? note;
  final String? reference;
  final double? balanceBefore;
  final double? balanceAfter;

  String get currency => account?.currency ?? 'SAR';

  bool get hasBalanceHistory => balanceBefore != null && balanceAfter != null;
}
