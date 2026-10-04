import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:masrouf_v2/data/database/app_database.dart';
import 'package:masrouf_v2/models/transaction.dart';

class TransactionRepository {
  TransactionRepository(this._db);
  final AppDatabase _db;

  // ─────────────────────────────────────────────────────────
  //  Queries
  // ─────────────────────────────────────────────────────────

  /// Watch all transactions, newest first.
  Stream<List<Transaction>> watchAll() {
    final query = _db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Watch transactions for a specific account.
  Stream<List<Transaction>> watchByAccount(String accountId) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.accountId.equals(accountId))
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Watch transactions for one account, including transfers pointing to it.
  Stream<List<Transaction>> watchInvolvingAccount(String accountId) {
    final query = _db.select(_db.transactions)
      ..where(
        (t) => t.accountId.equals(accountId) | t.toAccountId.equals(accountId),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.date)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  // ─────────────────────────────────────────────────────────
  //  Mutations
  // ─────────────────────────────────────────────────────────

  /// Insert a transaction and adjust the affected account balances atomically.
  Future<void> addTransaction(Transaction tx) async {
    await _db.transaction(() async {
      // 1. Insert the row (destinationAmount already set in tx)
      await _db.into(_db.transactions).insert(_toCompanion(tx));

      // 2. Apply the balance effect
      await _applyEffect(tx, reverse: false);
    });
  }

  Future<void> deleteTransaction(String id) async {
    await _db.transaction(() async {
      // 1. Read the row
      final row = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(id))).getSingle();

      // 2. Reverse the effect (uses destinationAmount when present)
      await _applyEffect(row, reverse: true);

      // 3. Delete the row
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> updateTransaction(Transaction tx) async {
    await _db.transaction(() async {
      // 1. Load the old row
      final old = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(tx.id))).getSingle();

      // 2. Reverse the old effect
      await _applyEffect(old, reverse: true);

      // 3. Update the row
      await (_db.update(_db.transactions)..where((t) => t.id.equals(tx.id)))
          .write(_toCompanion(tx, forUpdate: true));

      // 4. Apply the new effect
      final updated = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(tx.id))).getSingle();
      await _applyEffect(updated, reverse: false);
    });
  }

  // ── Helpers ──────────────────────────────────────────────

  Future<void> _adjustBalance(String accountId, double delta) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(accountId))).getSingle();
    await (_db.update(_db.accounts)..where((a) => a.id.equals(accountId)))
        .write(AccountsCompanion(balance: Value(row.balance + delta)));
  }

  /// Applies (or reverses) the balance effect of a transaction.
  ///
  /// Works for both `Transaction` (in-memory model) and `DbTransaction`
  /// (Drift-generated row) because we read the same fields off both.
  Future<void> _applyEffect(dynamic row, {required bool reverse}) async {
    final isTransfer = row.toAccountId != null;
    final sign = reverse ? -1 : 1;

    if (isTransfer) {
      final double srcAmount = (row.amount as num).toDouble();
      final double destAmount =
          (row.destinationAmount as num?)?.toDouble() ?? srcAmount;

      await _adjustBalance(row.accountId as String, -srcAmount * sign);
      await _adjustBalance(row.toAccountId as String, destAmount * sign);
    } else {
      final double amt = (row.amount as num).toDouble();
      final bool isIncome = row.isIncome as bool;
      final delta = isIncome ? amt : -amt;
      await _adjustBalance(row.accountId as String, delta * sign);
    }
  }

  // ─────────────────────────────────────────────────────────
  //  Mappers
  // ─────────────────────────────────────────────────────────

  // Keep transaction icons statically referenced so Flutter can tree-shake
  // the Material Icons font. The database still stores the code point exactly
  // as before; only the in-memory reconstruction changes.
  static const Map<int, IconData> _transactionIcons = {
    0xf0058: Icons.payments_rounded,
    0xf0171: Icons.shopping_cart_rounded,
    0xf866: Icons.local_cafe_rounded,
    0xf86d: Icons.local_gas_station_rounded,
    0xf02bf: Icons.wifi_rounded,
    0xf0108: Icons.restaurant_rounded,
    0xf8b0: Icons.medical_services_rounded,
    0xf8e7: Icons.movie_rounded,
    0xf61a: Icons.card_giftcard_rounded,
    0xf5ca: Icons.bolt_rounded,
    0xf016f: Icons.shopping_bag_rounded,
    0xf6b3: Icons.directions_car_rounded,
    0xf00e1: Icons.receipt_long_rounded,
    0xf8d9: Icons.more_horiz_rounded,
    0xf01e1: Icons.storefront_rounded,
  };

  IconData _iconFromRow(DbTransaction row) {
    final codePoint = int.tryParse(row.icon);
    final icon = codePoint == null ? null : _transactionIcons[codePoint];
    if (icon != null) return icon;

    // Safe fallback for older/unknown stored icons without creating a
    // dynamic IconData instance that disables icon tree-shaking.
    if (row.toAccountId != null) return Icons.swap_horiz_rounded;
    if (row.isIncome) return Icons.payments_rounded;

    return switch (row.category) {
      'مطاعم' => Icons.restaurant_rounded,
      'تسوق' => Icons.shopping_bag_rounded,
      'مواصلات' => Icons.directions_car_rounded,
      'فواتير' => Icons.receipt_long_rounded,
      'صحة' => Icons.medical_services_rounded,
      'ترفيه' => Icons.movie_rounded,
      'وقود' => Icons.local_gas_station_rounded,
      _ => Icons.more_horiz_rounded,
    };
  }

  Transaction _toModel(DbTransaction row) {
    return Transaction(
      id: row.id,
      title: row.title,
      category: row.category,
      amount: row.amount,
      destinationAmount: row.destinationAmount, // ← new
      date: row.date,
      icon: _iconFromRow(row),
      accountId: row.accountId,
      iconColor: row.iconColor != null ? Color(row.iconColor!) : null,
      isIncome: row.isIncome,
      toAccountId: row.toAccountId,
    );
  }

  TransactionsCompanion _toCompanion(Transaction tx, {bool forUpdate = false}) {
    return TransactionsCompanion(
      id: forUpdate ? const Value.absent() : Value(tx.id),
      title: Value(tx.title),
      category: Value(tx.category),
      amount: Value(tx.amount),
      destinationAmount: Value(tx.destinationAmount), // ← new
      date: Value(tx.date),
      icon: Value(tx.icon.codePoint.toString()),
      accountId: Value(tx.accountId),
      iconColor: Value(tx.iconColor?.toARGB32()),
      isIncome: Value(tx.isIncome),
      toAccountId: Value(tx.toAccountId),
    );
  }
}
