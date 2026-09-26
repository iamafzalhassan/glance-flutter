package com.example.glance

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var devicePlugin: DevicePlugin? = null

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        devicePlugin?.dispose()
        devicePlugin = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        devicePlugin = DevicePlugin(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        devicePlugin?.onPermissionResult(requestCode, grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED)
    }
}
