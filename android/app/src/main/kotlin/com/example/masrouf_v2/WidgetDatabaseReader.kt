package com.example.masrouf_v2

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import java.io.File
import java.text.NumberFormat
import java.util.Date
import java.util.Locale

/**
 * Native-only reader for the existing Drift SQLite database.
 *
 * This keeps the Flutter/Dart side untouched while allowing the larger Android
 * home widgets to show the same account/transaction data already stored by
 * the app.
 */
object WidgetDatabaseReader {

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
        val date: Date?,
    )

    fun readSnapshot(context: Context, accountId: String, limit: Int = 3): Snapshot {
        if (accountId.isBlank()) return Snapshot()

        val databaseFile = databaseFile(context) ?: return Snapshot()

        return try {
            SQLiteDatabase.openDatabase(
                databaseFile.absolutePath,
                null,
                SQLiteDatabase.OPEN_READONLY,
            ).use { db ->
                var income = 0.0
                var expenses = 0.0
                val transactions = ArrayList<Transaction>(limit)

                db.rawQuery(
                    """
                    SELECT amount, destination_amount, is_income, to_account_id, title, date
                    FROM transactions
                    WHERE account_id = ? OR to_account_id = ?
                    ORDER BY date DESC
                    """.trimIndent(),
                    arrayOf(accountId, accountId),
                ).use { cursor ->
                    while (cursor.moveToNext()) {
                        val sourceAmount = cursor.getDouble(0)
                        val destinationAmount = if (cursor.isNull(1)) null else cursor.getDouble(1)
                        val isIncome = cursor.getInt(2) != 0
                        val toAccountId = if (cursor.isNull(3)) null else cursor.getString(3)
                        val title = cursor.getString(4).orEmpty().ifBlank { "عملية" }
                        val date = if (cursor.isNull(5)) null else decodeDate(cursor.getLong(5))
                        val isTransfer = !toAccountId.isNullOrBlank()

                        // Transfers are deliberately excluded from the income/expense
                        // summary: they move money between accounts rather than changing
                        // the user's overall income/expense totals.
                        if (!isTransfer) {
                            if (isIncome) income += sourceAmount else expenses += sourceAmount
                        }

                        if (transactions.size < limit) {
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
                                date = date,
                            )
                        }
                    }
                }

                Snapshot(
                    income = income,
                    expenses = expenses,
                    transactions = transactions,
                )
            }
        } catch (_: Exception) {
            Snapshot()
        }
    }

    fun formatAmount(value: Double): String {
        return NumberFormat.getNumberInstance(Locale.US).apply {
            minimumFractionDigits = 2
            maximumFractionDigits = 2
        }.format(value)
    }

    private fun databaseFile(context: Context): File? {
        val candidates = listOf(
            File(context.applicationInfo.dataDir, "app_flutter/masrouf_db.sqlite"),
            File(context.filesDir.parentFile, "app_flutter/masrouf_db.sqlite"),
            File(context.filesDir, "masrouf_db.sqlite"),
        )

        return candidates.firstOrNull { it.isFile && it.canRead() }
    }

    private fun decodeDate(raw: Long): Date {
        // Drift's native DateTime encoding stores milliseconds since epoch.
        return Date(raw)
    }
}
