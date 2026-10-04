package com.example.masrouf_v2

import android.app.Application
import io.flutter.embedding.engine.FlutterEngineGroup
import io.flutter.embedding.engine.FlutterEngineGroupCache

class MasroufApplication : Application() {

    companion object {
        const val WIDGET_ENGINE_GROUP_ID = "masrouf_widget_engine_group"
    }

    override fun onCreate() {
        super.onCreate()

        if (!FlutterEngineGroupCache.getInstance().contains(WIDGET_ENGINE_GROUP_ID)) {
            FlutterEngineGroupCache.getInstance().put(
                WIDGET_ENGINE_GROUP_ID,
                FlutterEngineGroup(applicationContext),
            )
        }
    }
}
