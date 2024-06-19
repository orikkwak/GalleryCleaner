package com.example.dg_imagex

import android.database.ContentObserver
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "screenshot_detector"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "onCreate called")

        flutterEngine?.dartExecutor?.binaryMessenger?.let { binaryMessenger ->
            MethodChannel(binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                if (call.method == "startScreenshotDetection") {
                    Log.d("MainActivity", "startScreenshotDetection called")
                    startScreenshotDetection()
                    result.success(null)
                }
            }
        }
    }

    private fun startScreenshotDetection() {
        Log.d("MainActivity", "startScreenshotDetection method entered")
        contentResolver.registerContentObserver(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            true,
            object : ContentObserver(Handler()) {
                override fun onChange(selfChange: Boolean, uri: Uri?) {
                    super.onChange(selfChange, uri)
                    Log.d("MainActivity", "Screenshot detected")
                    flutterEngine?.dartExecutor?.binaryMessenger?.let { binaryMessenger ->
                        MethodChannel(binaryMessenger, CHANNEL).invokeMethod("onScreenshotDetected", null)
                    }
                }
            }
        )
    }
}
