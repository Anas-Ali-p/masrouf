import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masrouf_v2/models/account.dart';
import 'package:masrouf_v2/providers/app_providers.dart';

/// All accounts, reactive.
final accountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAll();
});

/// A single account by id.
final accountByIdProvider = StreamProvider.family<Account?, String>((ref, id) {
  return ref.watch(accountRepositoryProvider).watchById(id);
});
