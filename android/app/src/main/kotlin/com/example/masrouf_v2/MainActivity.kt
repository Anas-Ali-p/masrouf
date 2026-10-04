package com.example.masrouf_v2

import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

open class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "com.example.masrouf_v2/widget_config"
        private const val WIDGET_PREFERENCES = "HomeWidgetPreferences"
        private const val WIDGET_STATE_KEY = "widget_state_v2"
        private val widgetStorageExecutor = Executors.newSingleThreadExecutor()
        private val mainHandler = Handler(Looper.getMainLooper())
    }

    // القيمة الافتراضية الصحيحة: 0 (INVALID_APPWIDGET_ID)
    private var widgetId: Int = AppWidgetManager.INVALID_APPWIDGET_ID
    private var widgetActionAccountId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        readWidgetIdFromIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "saveWidgetState" -> {
                    val state = call.argument<String>("state")
                    if (state == null) {
                        result.error(
                            "invalid_state",
                            "Widget state must be a String",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    widgetStorageExecutor.execute {
                        try {
                            val ok = applicationContext
                                .getSharedPreferences(
                                    WIDGET_PREFERENCES,
                                    MODE_PRIVATE,
                                )
                                .edit()
                                .putString(WIDGET_STATE_KEY, state)
                                .commit()

                            mainHandler.post { result.success(ok) }
                        } catch (e: Exception) {
                            mainHandler.post {
                                result.error(
                                    "save_state_error",
                                    e.message,
                                    null,
                                )
                            }
                        }
                    }
                }
                "getAppWidgetId" -> {
                    // نُعيد 0 إذا لم يكن هناك تهيئة فعلية
                    result.success(widgetId)
                }
                "getWidgetActionAccountId" -> {
                    result.success(widgetActionAccountId)
                }
                "finishConfiguration" -> {
                    try {
                        finishWidgetConfiguration()
                        result.success(true)
                    } catch (e: Exception) {
                        android.util.Log.e("WidgetDebug", "finish failed", e)
                        result.error("finish_error", e.message, null)
                    }
                }
                "cancelConfiguration" -> {
                    setResult(RESULT_CANCELED)
                    finish()
                    result.success(true)
                }
                "finishWidgetAction" -> {
                    setResult(RESULT_OK)
                    finish()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        readWidgetIdFromIntent(intent)
    }

    /**
     * نستخرج widgetId فقط إذا كان الـ Intent قادماً من تهيئة widget.
     * أي إجراء آخر (تشغيل عادي) يُعيد 0 (INVALID).
     */
    private fun readWidgetIdFromIntent(intent: Intent?) {
        val action = intent?.action
        android.util.Log.d(
            "WidgetDebug",
            "readWidgetIdFromIntent: action=$action"
        )

        widgetId = if (action == "android.appwidget.action.APPWIDGET_CONFIGURE") {
            intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
        } else {
            AppWidgetManager.INVALID_APPWIDGET_ID
        }

        widgetActionAccountId = if (action == "com.example.masrouf_v2.WIDGET_ADD") {
            intent.getStringExtra("accountId")?.takeIf { it.isNotEmpty() }
        } else {
            null
        }

        android.util.Log.d("WidgetDebug", "widgetId = $widgetId")
        android.util.Log.d("WidgetDebug", "widgetActionAccountId = $widgetActionAccountId")
    }

    private fun finishWidgetConfiguration() {
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            android.util.Log.w("WidgetDebug", "finish called with invalid id")
            setResult(RESULT_CANCELED)
            finish()
            return
        }

        android.util.Log.d("WidgetDebug", "finish with widgetId=$widgetId")

        setResult(
            RESULT_OK,
            Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
            }
        )
        finish()
    }
}