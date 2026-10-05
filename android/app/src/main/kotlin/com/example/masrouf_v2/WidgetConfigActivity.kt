package com.prettysoft.masrouf

import io.flutter.embedding.android.FlutterActivityLaunchConfigs

/**
 * Lightweight Flutter host used by both widget configuration and widget taps.
 *
 * The activity runs a dedicated Dart entrypoint and creates engines from a
 * shared FlutterEngineGroup so subsequent widget launches reuse Dart VM/code
 * resources instead of paying the full engine startup cost each time.
 */
class WidgetConfigActivity : MainActivity() {

    override fun getCachedEngineGroupId(): String {
        return MasroufApplication.WIDGET_ENGINE_GROUP_ID
    }

    override fun getDartEntrypointFunctionName(): String {
        return "widgetEntryPoint"
    }

    override fun getDartEntrypointArgs(): List<String> {
        val action = intent?.action

        return when (action) {
            "android.appwidget.action.APPWIDGET_CONFIGURE" -> {
                val widgetId = intent?.getIntExtra(
                    android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_ID,
                    android.appwidget.AppWidgetManager.INVALID_APPWIDGET_ID,
                ) ?: android.appwidget.AppWidgetManager.INVALID_APPWIDGET_ID

                listOf("config", widgetId.toString())
            }

            "com.prettysoft.masrouf.WIDGET_ADD" -> {
                val accountId = intent?.getStringExtra("accountId")

                listOf("action", accountId.orEmpty())
            }

            else -> listOf("", "")
        }
    }

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode {
        return FlutterActivityLaunchConfigs.BackgroundMode.transparent
    }

    override fun onDestroy() {
        // The engine itself is owned by the Activity/engine-group lifecycle.
        // Do not retain Activity references here.
        super.onDestroy()
    }
}
