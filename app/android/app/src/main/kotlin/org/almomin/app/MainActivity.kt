package org.almomin.app

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "almomin/volume_tasbih"
    private var volumeChannel: MethodChannel? = null
    private var interceptVolumeUp: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        volumeChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        volumeChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "setVolumeInterception" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    interceptVolumeUp = enabled
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (interceptVolumeUp && keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            if (event == null || event.repeatCount == 0) {
                volumeChannel?.invokeMethod("onVolumeUpPressed", null)
            }
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent?): Boolean {
        if (interceptVolumeUp && keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
            return true
        }
        return super.onKeyUp(keyCode, event)
    }
}
