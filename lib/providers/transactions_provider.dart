import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/models/transaction.dart';
import 'package:masrouf_v2/providers/app_providers.dart';

/// All transactions, reactive.
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// Transactions for one account.
final transactionsByAccountProvider =
    StreamProvider.family<List<Transaction>, String>((ref, accountId) {
      return ref.watch(transactionRepositoryProvider).watchByAccount(accountId);
    });

/// Combined list of the last N transactions across all accounts.
final recentTransactionsProvider =
    Provider.family<AsyncValue<List<Transaction>>, int>((ref, count) {
      final all = ref.watch(allTransactionsProvider);
      return all.whenData((list) => list.take(count).toList());
    });

/// All transactions where the account is either the source or destination.
final transactionsInvolvingAccountProvider =
    StreamProvider.family<List<Transaction>, String>((ref, accountId) {
      return ref
          .watch(transactionRepositoryProvider)
          .watchInvolvingAccount(accountId);
    });
