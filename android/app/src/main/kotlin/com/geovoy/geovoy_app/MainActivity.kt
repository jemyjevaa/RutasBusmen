package com.geovoy.geovoy_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.geovoy.geovoy_app/eta_foreground_service"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val tripId = call.argument<String>("tripId") ?: ""
                    val routeName = call.argument<String>("routeName") ?: ""
                    val eta = call.argument<Int>("eta") ?: 0
                    val status = call.argument<String>("status") ?: ""
                    
                    ETAForegroundService.start(this, tripId, routeName, eta, status)
                    result.success(true)
                }
                "updateService" -> {
                    val eta = call.argument<Int>("eta") ?: 0
                    val status = call.argument<String>("status") ?: ""
                    
                    ETAForegroundService.update(this, eta, status)
                    result.success(true)
                }
                "stopService" -> {
                    ETAForegroundService.stop(this)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
