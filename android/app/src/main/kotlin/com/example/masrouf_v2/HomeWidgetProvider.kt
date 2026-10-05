package com.prettysoft.masrouf

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.res.ColorStateList
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider as BaseHomeWidgetProvider
import java.util.concurrent.Executors
import org.json.JSONObject

class HomeWidgetProvider : BaseHomeWidgetProvider() {

    companion object {
        private const val TAG = "HomeWidgetProvider"
        private const val STATE_KEY = "widget_state_v2"
        private const val WIDGET_ADD_ACTION = "com.prettysoft.masrouf.WIDGET_ADD"
        private const val EXTRA_ACCOUNT_ID = "accountId"

        // Widget callbacks are BroadcastReceiver callbacks. Keep database work
        // off the receiver main thread and serialize updates to avoid races.
        private val updateExecutor = Executors.newSingleThreadExecutor()
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val pendingResult = goAsync()
        updateExecutor.execute {
            try {
                val state = readState(widgetData)
                for (widgetId in appWidgetIds) {
                    try {
                        updateWidget(
                            context,
                            appWidgetManager,
                            widgetId,
                            state,
                            widgetData,
                        )
                    } catch (e: Exception) {
                        Log.e(TAG, "onUpdate failed for widgetId=$widgetId", e)
                    }
                }
            } finally {
                pendingResult.finish()
            }
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)

        val pendingResult = goAsync()
        updateExecutor.execute {
            try {
                val widgetData = HomeWidgetPlugin.getData(context)
                val state = readState(widgetData)
                try {
                    updateWidget(context, appWidgetManager, appWidgetId, state, widgetData)
                } catch (e: Exception) {
                    Log.e(TAG, "onAppWidgetOptionsChanged failed for widgetId=$appWidgetId", e)
                }
            } finally {
                pendingResult.finish()
            }
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val editor = widgetData.edit()
        val root = readState(widgetData)
        val widgets = root.optJSONObject("widgets")

        if (widgets != null) {
            for (widgetId in appWidgetIds) {
                widgets.remove(widgetId.toString())
                removeLegacyKeys(editor, widgetId)
            }
            root.put("widgets", widgets)
            editor.putString(STATE_KEY, root.toString())
        } else {
            for (widgetId in appWidgetIds) {
                removeLegacyKeys(editor, widgetId)
            }
        }

        if (!editor.commit()) {
            Log.e(TAG, "Failed to persist widget deletion state")
        }
        super.onDeleted(context, appWidgetIds)
    }

    override fun onRestored(
        context: Context,
        oldWidgetIds: IntArray,
        newWidgetIds: IntArray,
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val editor = widgetData.edit()
        val root = readState(widgetData)
        val widgets = root.optJSONObject("widgets") ?: JSONObject().also {
            root.put("widgets", it)
        }

        val count = minOf(oldWidgetIds.size, newWidgetIds.size)
        for (index in 0 until count) {
            val oldId = oldWidgetIds[index]
            val newId = newWidgetIds[index]
            val oldKey = oldId.toString()
            val newKey = newId.toString()

            widgets.optString(oldKey, "")
                .takeIf { it.isNotEmpty() }
                ?.let { accountId ->
                    widgets.put(newKey, accountId)
                    widgets.remove(oldKey)
                }

            // Also remap legacy per-widget keys when restoring widgets created
            // by an older app version.
            copyLegacyKeys(widgetData, editor, oldId, newId)
        }

        if (count != oldWidgetIds.size || count != newWidgetIds.size) {
            Log.w(TAG, "Widget restore id arrays have different sizes")
        }

        editor.putString(STATE_KEY, root.toString())
        if (!editor.commit()) {
            Log.e(TAG, "Failed to persist restored widget state")
        }

        val manager = AppWidgetManager.getInstance(context)
        for (widgetId in newWidgetIds) {
            manager.updateAppWidgetOptions(widgetId, Bundle().apply {
                putBoolean(
                    AppWidgetManager.OPTION_APPWIDGET_RESTORE_COMPLETED,
                    true,
                )
            })
        }

        super.onRestored(context, oldWidgetIds, newWidgetIds)
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        state: JSONObject,
        widgetData: SharedPreferences,
    ) {
        var accountName = "غير محدد"
        var accountBalance = "0.00"
        var accountCurrency = ""
        var accountId: String? = null

        val widgets = state.optJSONObject("widgets")
        accountId = widgets
            ?.optString(widgetId.toString(), "")
            ?.takeIf { it.isNotEmpty() }

        if (accountId != null) {
            val accounts = state.optJSONObject("accounts")
            val account = accounts?.optJSONObject(accountId)
            if (account != null) {
                accountName = account.optString("name", accountName)
                accountBalance = account.optString("balance", accountBalance)
                accountCurrency = account.optString("currency", accountCurrency)
            }
        }

        // Backward-compatible fallback for widgets created before widget_state_v2.
        if (accountId == null) {
            accountId = widgetData.getString("account_id_$widgetId", null)
            accountName = widgetData.getString(
                "account_name_$widgetId",
                accountName,
            ) ?: accountName
            accountBalance = widgetData.getString(
                "account_balance_$widgetId",
                accountBalance,
            ) ?: accountBalance
            accountCurrency = widgetData.getString(
                "account_currency_$widgetId",
                accountCurrency,
            ) ?: accountCurrency
        }

        val theme = state.optJSONObject("theme")
        val widgetBackgroundColor = theme?.optInt(
            "background",
            context.resources.getColor(R.color.widget_background),
        ) ?: context.resources.getColor(R.color.widget_background)
        val widgetTextColor = theme?.optInt(
            "text",
            context.resources.getColor(R.color.widget_text_primary),
        ) ?: context.resources.getColor(R.color.widget_text_primary)

        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)

        // Only the one-row target group (1x1..1x4, where the second number is
        // horizontal width) uses the new width-driven layouts. Taller widget
        // instances keep the existing layout-selection behavior unchanged.
        val isTargetOneRow = minHeight < 110
        val layoutId = if (isTargetOneRow) {
            when {
                minWidth >= 250 -> R.layout.widget_1x4
                minWidth >= 180 -> R.layout.widget_1x3
                minWidth >= 110 -> R.layout.widget_1x2
                else -> R.layout.widget_1x1
            }
        } else {
            // Existing behavior for all non-target widget sizes.
            when {
                minWidth >= 250 && minHeight >= 170 -> R.layout.widget_large
                minWidth >= 180 && minHeight >= 105 -> R.layout.widget_medium
                minWidth >= 110 && minHeight >= 60 -> R.layout.widget_small
                else -> R.layout.widget_tiny
            }
        }

        val isTiny = layoutId == R.layout.widget_tiny || layoutId == R.layout.widget_1x1
        val hasCurrency = layoutId == R.layout.widget_medium || layoutId == R.layout.widget_large
        val hasTargetSummary =
            layoutId == R.layout.widget_1x3 || layoutId == R.layout.widget_1x4
        val hasSummary = hasCurrency || hasTargetSummary
        val hasRecentTransactions = layoutId == R.layout.widget_large

        val views = RemoteViews(context.packageName, layoutId).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                setColorStateList(
                    R.id.widget_root,
                    "setBackgroundTintList",
                    ColorStateList.valueOf(widgetBackgroundColor),
                )
            } else {
                setInt(R.id.widget_root, "setBackgroundColor", widgetBackgroundColor)
            }

            // Only target IDs that exist in the selected RemoteViews layout.
            setTextViewText(R.id.account_name, accountName)
            setTextColor(R.id.account_name, widgetTextColor)
            if (!isTiny) {
                setTextViewText(R.id.account_balance, accountBalance)
                setTextColor(R.id.account_balance, widgetTextColor)
            }
            if (hasCurrency) {
                setTextViewText(R.id.account_currency, accountCurrency)
                setTextColor(R.id.account_currency, widgetTextColor)
            }
            if (hasSummary) {
                val snapshot = accountId?.let {
                    WidgetDatabaseReader.readSnapshot(
                        context,
                        it,
                        limit = if (hasTargetSummary) 0 else 3,
                    )
                } ?: WidgetDatabaseReader.Snapshot()

                val incomeText = WidgetDatabaseReader.formatAmount(snapshot.income)
                val expensesText = WidgetDatabaseReader.formatAmount(snapshot.expenses)
                setTextViewText(R.id.summary_income, "+$incomeText")
                setTextViewText(R.id.summary_expenses, "-$expensesText")

                if (hasRecentTransactions) {
                    removeAllViews(R.id.transactions_container)
                    for (transaction in snapshot.transactions) {
                        val row = RemoteViews(
                            context.packageName,
                            R.layout.widget_transaction_row,
                        )
                        row.setTextViewText(R.id.transaction_title, transaction.title)
                        row.setTextColor(R.id.transaction_title, widgetTextColor)

                        val amount = WidgetDatabaseReader.formatAmount(
                            kotlin.math.abs(transaction.amount),
                        )
                        val prefix = when {
                            transaction.isTransfer && transaction.amount >= 0 -> "↗ "
                            transaction.isTransfer -> "↙ "
                            transaction.isIncome -> "+ "
                            else -> "- "
                        }
                        row.setTextViewText(R.id.transaction_amount, prefix + amount)
                        row.setTextColor(
                            R.id.transaction_amount,
                            context.resources.getColor(
                                if (transaction.amount >= 0) {
                                    R.color.widget_income
                                } else {
                                    R.color.widget_expense
                                },
                            ),
                        )
                        addView(R.id.transactions_container, row)
                    }
                }
            }
        }

        if (!accountId.isNullOrEmpty()) {
            val intent = Intent(context, WidgetConfigActivity::class.java).apply {
                action = WIDGET_ADD_ACTION
                putExtra(EXTRA_ACCOUNT_ID, accountId)
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                widgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

            // Root is present in every supported layout. Child click targets are
            // only registered when their IDs are actually present.
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            views.setOnClickPendingIntent(R.id.account_name, pendingIntent)
            if (!isTiny) {
                views.setOnClickPendingIntent(R.id.account_balance, pendingIntent)
            }
            if (hasRecentTransactions) {
                views.setOnClickPendingIntent(R.id.quick_add_button, pendingIntent)
            }
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun readState(widgetData: SharedPreferences): JSONObject {
        val raw = widgetData.getString(STATE_KEY, null) ?: return JSONObject()
        return try {
            JSONObject(raw)
        } catch (e: Exception) {
            Log.e(TAG, "Invalid widget state", e)
            JSONObject()
        }
    }

    private fun copyLegacyKeys(
        widgetData: SharedPreferences,
        editor: SharedPreferences.Editor,
        oldWidgetId: Int,
        newWidgetId: Int,
    ) {
        val prefixes = listOf(
            "account_id",
            "account_name",
            "account_balance",
            "account_currency",
        )

        for (prefix in prefixes) {
            val oldKey = "${prefix}_$oldWidgetId"
            val newKey = "${prefix}_$newWidgetId"
            val value = widgetData.all[oldKey]
            when (value) {
                is String -> editor.putString(newKey, value)
                is Int -> editor.putInt(newKey, value)
                is Long -> editor.putLong(newKey, value)
                is Float -> editor.putFloat(newKey, value)
                is Boolean -> editor.putBoolean(newKey, value)
            }
            editor.remove(oldKey)
        }
    }

    private fun removeLegacyKeys(
        editor: SharedPreferences.Editor,
        widgetId: Int,
    ) {
        editor.remove("account_id_$widgetId")
        editor.remove("account_name_$widgetId")
        editor.remove("account_balance_$widgetId")
        editor.remove("account_currency_$widgetId")
    }
}
