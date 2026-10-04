// lib/data/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('DbAccount')
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get category => text().nullable()(); // ← new
  TextColumn get currency => text().withLength(min: 3, max: 3)();
  RealColumn get balance => real()();
  TextColumn get type => text()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get note => text().nullable()();
  IntColumn get accentColor => integer().nullable()(); // <-- ADD THIS LINE
  DateTimeColumn get createdAt => dateTime().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbTransaction')
class Transactions extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  RealColumn get destinationAmount => real().nullable()(); // ← new
  DateTimeColumn get date => dateTime()();
  TextColumn get icon => text()(); // Store icon code point
  IntColumn get iconColor => integer().nullable()(); // Store color value
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get toAccountId =>
      text().nullable().references(Accounts, #id)(); // For transfers

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Define the database
@DriftDatabase(tables: [Accounts, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // @override
  // int get schemaVersion => 1;

  // @override
  // MigrationStrategy get migration => MigrationStrategy(
  //   onCreate: (m) async {
  //     await m.createAll();
  //     // Optional: Seed with initial data on first run
  //   },
  // );
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(accounts, accounts.category);
      }
      if (from < 3) {
        await m.addColumn(transactions, transactions.destinationAmount);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(name: 'masrouf_db');
  });
}
