import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:masrouf_v2/data/database/app_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataBackup {
  DataBackup._();

  static const _automaticBackupDateKey = 'lastAutomaticBackupDate';
  static const _storagePermissionPromptedKey =
      'backupStoragePermissionPrompted';
  static bool _automaticBackupInProgress = false;

  static Future<void> export(AppDatabase db) async {
    final bytes = await _buildBackupBytes(db);
    final file = await _createBackupFile(bytes, automatic: false);

    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/json'),
    ], subject: 'نسخة احتياطية - Masrouf');
  }

  /// Creates at most one automatic backup per calendar day.
  ///
  /// Missed days are intentionally not backfilled: when the app is opened
  /// after several days, only the current day's backup is created.
  /// Returns true when a new backup was created.
  static Future<bool> createDailyBackup(AppDatabase db) async {
    if (_automaticBackupInProgress) return false;
    _automaticBackupInProgress = true;

    try {
      final now = DateTime.now();
      final today = _dateStamp(now);
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString(_automaticBackupDateKey) == today) {
        return false;
      }

      final bytes = await _buildBackupBytes(db);
      final dir = await _backupDirectory();
      final file = File('${dir.path}/masrouf_backup_auto_$today.json');

      if (await file.exists()) {
        await prefs.setString(_automaticBackupDateKey, today);
        return false;
      }

      await file.writeAsBytes(bytes, flush: true);
      await prefs.setString(_automaticBackupDateKey, today);
      return true;
    } catch (e, stackTrace) {
      debugPrint('[AUTO BACKUP] skipped: $e');
      debugPrint('[AUTO BACKUP STACK] $stackTrace');
      return false;
    } finally {
      _automaticBackupInProgress = false;
    }
  }

  static Future<Uint8List> _buildBackupBytes(AppDatabase db) async {
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

    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
  }

  static Future<File> _createBackupFile(
    Uint8List bytes, {
    required bool automatic,
  }) async {
    final dir = await _backupDirectory();
    final now = DateTime.now();
    final stamp = now.toIso8601String().replaceAll(':', '-').substring(0, 19);
    final name = automatic
        ? 'masrouf_backup_auto_${_dateStamp(now)}.json'
        : 'masrouf_backup_$stamp.json';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static Future<Directory> _backupDirectory() async {
    final base = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : null;

    if (Platform.isAndroid && base != null) {
      final publicDir = await _tryPublicBackupDirectory(base);
      if (publicDir != null) return publicDir;
    }

    // Permission was unavailable/denied, or the public location cannot be
    // used by the current Android storage model. Keep backups working in
    // app-specific storage instead.
    final privateBase = base ?? await getApplicationDocumentsDirectory();
    final dir = Directory('${privateBase.path}/masrouf_v2');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory?> _tryPublicBackupDirectory(
    Directory appExternalDirectory,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    var granted = await _hasPublicStoragePermission();

    if (!granted && prefs.getBool(_storagePermissionPromptedKey) != true) {
      granted = await _requestPublicStoragePermission();
    }

    if (!granted) return null;

    final publicRoot = _findPublicStorageRoot(appExternalDirectory);
    if (publicRoot == null) return null;

    try {
      final dir = Directory('$publicRoot/masrouf_v2');
      await dir.create(recursive: true);
      return dir;
    } catch (e) {
      debugPrint('[BACKUP STORAGE] public directory unavailable: $e');
      return null;
    }
  }

  static Future<bool> _hasPublicStoragePermission() async {
    try {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      if (sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      }
      return await Permission.storage.isGranted;
    } catch (e) {
      debugPrint('[BACKUP PERMISSION] storage check failed: $e');
      return false;
    }
  }

  static Future<bool> _requestPublicStoragePermission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storagePermissionPromptedKey, true);

    try {
      final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
      final status = sdkInt >= 30
          ? await Permission.manageExternalStorage.request()
          : await Permission.storage.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('[BACKUP PERMISSION] request failed: $e');
      return false;
    }
  }

  static String? _findPublicStorageRoot(Directory appExternalDirectory) {
    const marker = '/Android/data/';
    final path = appExternalDirectory.path;
    final markerIndex = path.indexOf(marker);
    if (markerIndex <= 0) return null;
    return path.substring(0, markerIndex);
  }

  static String _dateStamp(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

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
