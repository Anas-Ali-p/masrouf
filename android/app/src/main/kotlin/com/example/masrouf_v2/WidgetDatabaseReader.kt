package com.prettysoft.masrouf

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import java.io.File
import java.text.NumberFormat
import java.util.Locale

/**
 * Read-only access to the existing Drift SQLite database for widget content.
 *
 * The widget never starts Flutter just to render. It reads the account state
 * from the widget SharedPreferences payload and uses this reader only for the
 * larger widget's summary/recent-transaction section.
 */
object WidgetDatabaseReader {

    private const val TAG = "WidgetDatabaseReader"

    data class Snapshot(
        val income: Double = 0.0,
        val expenses: Double = 0.0,
        val transactions: List<Transaction> = emptyList(),
    )

    data class Transaction(
        val title: String,
        val amount: Double,
        val isIncome: Boolean,
        val isTransfer: Boolean,
    )

    fun readSnapshot(context: Context, accountId: String, limit: Int = 3): Snapshot {
        if (accountId.isBlank()) return Snapshot()

        val safeLimit = limit.coerceIn(0, 20)
        val databaseFile = databaseFile(context) ?: run {
            Log.w(TAG, "Database file not found for widget snapshot")
            return Snapshot()
        }

        return try {
            SQLiteDatabase.openDatabase(
                databaseFile.absolutePath,
                null,
                SQLiteDatabase.OPEN_READONLY,
            ).use { db ->
                val (income, expenses) = readSummary(db, accountId)
                val transactions = readRecentTransactions(db, accountId, safeLimit)

                Snapshot(
                    income = income,
                    expenses = expenses,
                    transactions = transactions,
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Unable to read widget snapshot", e)
            Snapshot()
        }
    }

    fun formatAmount(value: Double): String {
        return NumberFormat.getNumberInstance(Locale.US).apply {
            minimumFractionDigits = 2
            maximumFractionDigits = 2
        }.format(value)
    }

    private fun readSummary(
        db: SQLiteDatabase,
        accountId: String,
    ): Pair<Double, Double> {
        db.rawQuery(
            """
            SELECT
                COALESCE(SUM(CASE
                    WHEN to_account_id IS NULL AND is_income != 0 THEN amount
                    ELSE 0
                END), 0),
                COALESCE(SUM(CASE
                    WHEN to_account_id IS NULL AND is_income = 0 THEN amount
                    ELSE 0
                END), 0)
            FROM transactions
            WHERE account_id = ? AND to_account_id IS NULL
            """.trimIndent(),
            arrayOf(accountId),
        ).use { cursor ->
            if (!cursor.moveToFirst()) return 0.0 to 0.0
            return cursor.getDouble(0) to cursor.getDouble(1)
        }
    }

    private fun readRecentTransactions(
        db: SQLiteDatabase,
        accountId: String,
        limit: Int,
    ): List<Transaction> {
        if (limit == 0) return emptyList()

        val transactions = ArrayList<Transaction>(limit)
        db.rawQuery(
            """
            SELECT amount, destination_amount, is_income, to_account_id, title
            FROM transactions
            WHERE account_id = ? OR to_account_id = ?
            ORDER BY date DESC
            LIMIT ?
            """.trimIndent(),
            arrayOf(accountId, accountId, limit.toString()),
        ).use { cursor ->
            while (cursor.moveToNext()) {
                val sourceAmount = cursor.getDouble(0)
                val destinationAmount = if (cursor.isNull(1)) null else cursor.getDouble(1)
                val isIncome = cursor.getInt(2) != 0
                val toAccountId = if (cursor.isNull(3)) null else cursor.getString(3)
                val title = cursor.getString(4).orEmpty().ifBlank { "عملية" }
                val isTransfer = !toAccountId.isNullOrBlank()

                // Transfers are displayed with the source/destination direction;
                // they intentionally do not affect the income/expense summary.
                val displayAmount = when {
                    isTransfer && toAccountId == accountId -> destinationAmount ?: sourceAmount
                    isTransfer -> -sourceAmount
                    isIncome -> sourceAmount
                    else -> -sourceAmount
                }

                transactions += Transaction(
                    title = title,
                    amount = displayAmount,
                    isIncome = isIncome,
                    isTransfer = isTransfer,
                )
            }
        }
        return transactions
    }

    private fun databaseFile(context: Context): File? {
        val candidates = listOf(
            File(context.applicationInfo.dataDir, "app_flutter/masrouf_db.sqlite"),
            File(context.filesDir.parentFile, "app_flutter/masrouf_db.sqlite"),
            File(context.filesDir, "masrouf_db.sqlite"),
        )

        return candidates.firstOrNull { it.isFile && it.canRead() }
    }
}
