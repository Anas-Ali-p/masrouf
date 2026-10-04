package com.example.masrouf_v2

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider as BaseHomeWidgetProvider
import org.json.JSONObject

class HomeWidgetProvider : BaseHomeWidgetProvider() {

    companion object {
        private const val STATE_KEY = "widget_state_v2"
        private const val WIDGET_ADD_ACTION = "com.example.masrouf_v2.WIDGET_ADD"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        // Parse the shared state once per provider callback. The previous
        // implementation re-read/re-parsed the same preferences for every
        // widget instance in the batch.
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
                android.util.Log.e("WidgetDebug", "onUpdate failed for $widgetId", e)
            }
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)

        val widgetData = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
        val state = readState(widgetData)

        try {
            updateWidget(context, appWidgetManager, appWidgetId, state, widgetData)
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "onAppWidgetOptionsChanged failed for $appWidgetId", e)
        }
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        val widgetData = es.antonborri.home_widget.HomeWidgetPlugin.getData(context)
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

        editor.apply()
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

        val options = appWidgetManager.getAppWidgetOptions(widgetId)
        val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)

        val layoutId = when {
            minWidth >= 250 -> R.layout.widget_large
            minWidth >= 180 -> R.layout.widget_medium
            minWidth >= 110 -> R.layout.widget_small
            else -> R.layout.widget_tiny
        }

        val views = RemoteViews(context.packageName, layoutId).apply {
            setTextViewText(R.id.account_name, accountName)
            setTextViewText(R.id.account_balance, accountBalance)

            try {
                setTextViewText(R.id.account_currency, accountCurrency)
            } catch (_: Exception) {
                // The tiny/small layouts do not necessarily contain currency.
            }

            // Medium/large widgets are enriched from the same local SQLite
            // database used by the app. No Flutter/Dart state is changed.
            if (layoutId == R.layout.widget_medium || layoutId == R.layout.widget_large) {
                val snapshot = accountId?.let {
                    WidgetDatabaseReader.readSnapshot(context, it, limit = 3)
                } ?: WidgetDatabaseReader.Snapshot()

                val incomeText = WidgetDatabaseReader.formatAmount(snapshot.income)
                val expensesText = WidgetDatabaseReader.formatAmount(snapshot.expenses)

                try {
                    setTextViewText(R.id.summary_income, "+$incomeText")
                    setTextViewText(R.id.summary_expenses, "-$expensesText")
                } catch (_: Exception) {}

                if (layoutId == R.layout.widget_large) {
                    try {
                        removeAllViews(R.id.transactions_container)
                        for (transaction in snapshot.transactions) {
                            val row = RemoteViews(context.packageName, R.layout.widget_transaction_row)
                            row.setTextViewText(R.id.transaction_title, transaction.title)

                            val amount = WidgetDatabaseReader.formatAmount(kotlin.math.abs(transaction.amount))
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
                                    if (transaction.amount >= 0) R.color.widget_income
                                    else R.color.widget_expense
                                ),
                            )
                            addView(R.id.transactions_container, row)
                        }
                    } catch (_: Exception) {}
                }
            }
        }

        if (!accountId.isNullOrEmpty()) {
            val intent = Intent(context, WidgetConfigActivity::class.java).apply {
                action = WIDGET_ADD_ACTION
                putExtra("accountId", accountId)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                widgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

            try {
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            } catch (_: Exception) {}

            views.setOnClickPendingIntent(R.id.account_balance, pendingIntent)
            views.setOnClickPendingIntent(R.id.account_name, pendingIntent)

            try {
                views.setOnClickPendingIntent(R.id.quick_add_button, pendingIntent)
            } catch (_: Exception) {}

            try {
                // views.setOnClickPendingIntent(R.id.widget_icon, pendingIntent)
            } catch (_: Exception) {}
        }

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun readState(widgetData: SharedPreferences): JSONObject {
        val raw = widgetData.getString(STATE_KEY, null) ?: return JSONObject()

        return try {
            JSONObject(raw)
        } catch (_: Exception) {
            JSONObject()
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
