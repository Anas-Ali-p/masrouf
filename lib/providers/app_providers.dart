import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/data/database/app_database.dart';
import 'package:masrouf_v2/data/repositories/account_repository.dart';
import 'package:masrouf_v2/data/repositories/settings_repository.dart';
import 'package:masrouf_v2/data/repositories/transaction_repository.dart';

// ── Infrastructure ────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(),
);

// ── Repositories ──────────────────────────────────────────
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(databaseProvider)),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(databaseProvider)),
);
