import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:masrouf_v2/data/database/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart';

class DataBackup {
  DataBackup._();

  static Future<void> export(AppDatabase db) async {
    final accounts = await db.select(db.accounts).get();
    final transactions = await db.select(db.transactions).get();

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'accounts': accounts
          .map(
            (a) => {
              'id': a.id,
              'name': a.name,
              'category': a.category,
              'currency': a.currency,
              'balance': a.balance,
              'type': a.type,
              'accountNumber': a.accountNumber,
              'note': a.note,
              'accentColor': a.accentColor,
              'createdAt': a.createdAt?.toIso8601String(),
              'isArchived': a.isArchived,
            },
          )
          .toList(),
      'transactions': transactions
          .map(
            (t) => {
              'id': t.id,
              'title': t.title,
              'category': t.category,
              'amount': t.amount,
              'date': t.date.toIso8601String(),
              'icon': t.icon,
              'iconColor': t.iconColor,
              'isIncome': t.isIncome,
              'accountId': t.accountId,
              'toAccountId': t.toAccountId,
            },
          )
          .toList(),
    };

    final bytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19);
    final file = File('${dir.path}/masrouf_backup_$stamp.json');
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/json'),
    ], subject: 'نسخة احتياطية - Masrouf');
  }

  /// Restores from a raw JSON string. Returns the number of records
  /// imported, or throws on failure.
  static Future<({int accounts, int transactions})> restoreFromJson(
    AppDatabase db,
    String jsonStr, {
    bool replaceAll = false,
  }) async {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final accounts = (map['accounts'] as List).cast<Map<String, dynamic>>();
    final transactions = (map['transactions'] as List)
        .cast<Map<String, dynamic>>();

    await db.transaction(() async {
      if (replaceAll) {
        await db.delete(db.transactions).go();
        await db.delete(db.accounts).go();
      }

      for (final a in accounts) {
        await db
            .into(db.accounts)
            .insertOnConflictUpdate(
              AccountsCompanion.insert(
                id: a['id'] as String,
                name: a['name'] as String,
                currency: a['currency'] as String,
                balance: (a['balance'] as num).toDouble(),
                type: a['type'] as String,
                category: Value(a['category'] as String?),
                accountNumber: Value(a['accountNumber'] as String?),
                note: Value(a['note'] as String?),
                accentColor: Value(a['accentColor'] as int?),
                createdAt: Value(
                  a['createdAt'] != null
                      ? DateTime.parse(a['createdAt'] as String)
                      : null,
                ),
                isArchived: Value(a['isArchived'] as bool? ?? false),
              ),
            );
      }

      for (final t in transactions) {
        await db
            .into(db.transactions)
            .insertOnConflictUpdate(
              TransactionsCompanion.insert(
                id: t['id'] as String,
                title: t['title'] as String,
                category: t['category'] as String,
                amount: (t['amount'] as num).toDouble(),
                date: DateTime.parse(t['date'] as String),
                icon: t['icon'] as String,
                accountId: t['accountId'] as String,
                iconColor: Value(t['iconColor'] as int?),
                isIncome: Value(t['isIncome'] as bool? ?? false),
                toAccountId: Value(t['toAccountId'] as String?),
              ),
            );
      }
    });

    return (accounts: accounts.length, transactions: transactions.length);
  }
}
