package com.example.money_manage

import io.flutter.embedding.android.FlutterActivity

import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {

    companion object {
        var flutterEngineInstance: FlutterEngine? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineInstance = flutterEngine
    }
}
