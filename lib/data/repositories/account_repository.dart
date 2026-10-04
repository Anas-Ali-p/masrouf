// lib/data/repositories/account_repository.dart
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:masrouf_v2/data/database/app_database.dart';
import 'package:masrouf_v2/models/account.dart';

class AccountRepository {
  AccountRepository(this._db);
  final AppDatabase _db;

  /// Watch all non-archived accounts as a reactive stream.
  Stream<List<Account>> watchAll() {
    final query = _db.select(_db.accounts)
      ..where((a) => a.isArchived.equals(false))
      ..orderBy([(a) => OrderingTerm.asc(a.name)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  /// Watch a single account by its id.
  Stream<Account?> watchById(String id) {
    final query = _db.select(_db.accounts)..where((a) => a.id.equals(id));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toModel(row),
    );
  }

  /// Insert a new account into the database.
  Future<void> insert(Account account) async {
    await _db.into(_db.accounts).insert(_toCompanion(account));
  }

  /// Update an existing account.
  Future<void> update(Account account) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(account.id)))
        .write(_toCompanion(account, forUpdate: true));
  }

  /// Soft-delete (archive) an account.
  Future<void> archive(String id) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      const AccountsCompanion(isArchived: Value(true)),
    );
  }

  /// Hard-delete an account and all of its transactions.
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.transactions,
      )..where((t) => t.accountId.equals(id))).go();
      await (_db.delete(_db.accounts)..where((a) => a.id.equals(id))).go();
    });
  }

  /// Directly set the balance of an account (used by the "zero balance" feature).
  Future<void> setBalance(String id, double newBalance) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(balance: Value(newBalance)),
    );
  }

  // ── Mappers ──────────────────────────────────────────

  Account _toModel(DbAccount row) {
    return Account(
      id: row.id,
      name: row.name,
      category: row.category, // ← new
      currency: row.currency,
      balance: row.balance,
      accentColor: row.accentColor != null ? Color(row.accentColor!) : null,
      type: AccountType.values.firstWhere(
        (t) => t.name == row.type,
        orElse: () => AccountType.checking,
      ),
      accountNumber: row.accountNumber,
      note: row.note,
      createdAt: row.createdAt,
      monthlyIncome: 0, // Can be calculated later
      monthlyExpense: 0, // Can be calculated later
    );
  }

  AccountsCompanion _toCompanion(Account a, {bool forUpdate = false}) {
    return AccountsCompanion(
      id: forUpdate ? const Value.absent() : Value(a.id),
      name: Value(a.name),
      category: Value(a.category), // ← new
      currency: Value(a.currency),
      balance: Value(a.balance),
      type: Value(a.type.name),
      accentColor: Value(a.accentColor?.value),
      accountNumber: Value(a.accountNumber),
      note: Value(a.note),
      createdAt: Value(a.createdAt),
    );
  }
}
