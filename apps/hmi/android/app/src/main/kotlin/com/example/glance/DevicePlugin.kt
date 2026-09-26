package com.example.glance

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.LocationListener
import android.location.LocationManager
import android.os.BatteryManager
import android.os.Build
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class DevicePlugin(private val activity: Activity, messenger: BinaryMessenger) : SensorEventListener {
    companion object {
        private const val BATTERY_TEMPERATURE_SCALE: Double = 10.0

        private const val REDUCED_REFRESH_HZ: Float = 30f

        private const val LOCATION_REQUEST: Int = 7

        private const val LOCATION_INTERVAL_MS: Long = 1000
        private const val WAKE_HOLD_MS: Long = 3000

        private const val HEAT_CHANNEL: String = "glance/device/heat"
        private const val LOCATION_CHANNEL: String = "glance/device/location"
        private const val LUX_CHANNEL: String = "glance/device/lux"
        private const val MAPS_KEY_META: String = "com.google.android.geo.API_KEY"
        private const val METHOD_CHANNEL: String = "glance/device"
        private const val WAKE_TAG: String = "glance:wake"

        private val LOCATION_PERMISSIONS: Array<String> = arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION)
    }

    private val batteryReceiver: BroadcastReceiver =
        object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) = emitHeat(intent)
        }

    private val admin: ComponentName = ComponentName(activity, GlanceAdminReceiver::class.java)

    private val devicePolicy: DevicePolicyManager = activity.getSystemService(DevicePolicyManager::class.java)

    private val heatChannel: EventChannel = EventChannel(messenger, HEAT_CHANNEL)
    private val locationChannel: EventChannel = EventChannel(messenger, LOCATION_CHANNEL)
    private val luxChannel: EventChannel = EventChannel(messenger, LUX_CHANNEL)

    private val locationListener: LocationListener =
        LocationListener { location ->
            locationSink?.success(mapOf("bearing" to if (location.hasBearing()) location.bearing.toDouble() else null, "latitude" to location.latitude, "longitude" to location.longitude))
        }

    private val locationManager: LocationManager = activity.getSystemService(LocationManager::class.java)

    private val methodChannel: MethodChannel = MethodChannel(messenger, METHOD_CHANNEL)

    private val powerManager: PowerManager = activity.getSystemService(PowerManager::class.java)

    private val sensorManager: SensorManager = activity.getSystemService(SensorManager::class.java)

    private var heatSink: EventChannel.EventSink? = null
    private var locationSink: EventChannel.EventSink? = null
    private var luxSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(::onMethodCall)
        heatChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onCancel(arguments: Any?) {
                    activity.unregisterReceiver(batteryReceiver)
                    heatSink = null
                }

                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    heatSink = events
                    val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        activity.registerReceiver(batteryReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                    } else {
                        activity.registerReceiver(batteryReceiver, filter)
                    }
                }
            },
        )
        luxChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onCancel(arguments: Any?) {
                    sensorManager.unregisterListener(this@DevicePlugin)
                    luxSink = null
                }

                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    luxSink = events
                    sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT)?.let { sensorManager.registerListener(this@DevicePlugin, it, SensorManager.SENSOR_DELAY_NORMAL) }
                }
            },
        )
        locationChannel.setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onCancel(arguments: Any?) {
                    locationManager.removeUpdates(locationListener)
                    locationSink = null
                }

                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    locationSink = events
                    startLocation()
                }
            },
        )
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
        heatChannel.setStreamHandler(null)
        luxChannel.setStreamHandler(null)
        locationChannel.setStreamHandler(null)
        locationManager.removeUpdates(locationListener)
        sensorManager.unregisterListener(this)
        if (heatSink != null) activity.unregisterReceiver(batteryReceiver)
        heatSink = null
        locationSink = null
        luxSink = null
    }

    fun onPermissionResult(requestCode: Int, granted: Boolean) {
        if (requestCode == LOCATION_REQUEST && granted && locationSink != null) startLocation()
    }

    private fun emitHeat(intent: Intent) {
        val tenths = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE)
        val celsius = if (tenths == Int.MIN_VALUE) null else tenths / BATTERY_TEMPERATURE_SCALE
        heatSink?.success(mapOf("batteryCelsius" to celsius, "thermalStatus" to powerManager.currentThermalStatus))
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "enterKiosk" -> enterKiosk()
            "exitKiosk" -> exitKiosk()
            "lockScreen" -> lockScreen()
            "mapsCredentials" -> {
                result.success(mapsCredentials())
                return
            }
            "setBrightness" -> setBrightness(call.arguments as Double?)
            "setKeepScreenOn" -> setKeepScreenOn(call.arguments as Boolean)
            "setReducedFrameRate" -> setReducedFrameRate(call.arguments as Boolean)
            "wakeScreen" -> wakeScreen()
            else -> {
                result.notImplemented()
                return
            }
        }
        result.success(null)
    }

    @SuppressLint("MissingPermission")
    private fun startLocation() {
        if (devicePolicy.isDeviceOwnerApp(activity.packageName)) {
            LOCATION_PERMISSIONS.forEach { devicePolicy.setPermissionGrantState(admin, activity.packageName, it, DevicePolicyManager.PERMISSION_GRANT_STATE_GRANTED) }
        }
        if (activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            activity.requestPermissions(LOCATION_PERMISSIONS, LOCATION_REQUEST)
            return
        }
        val provider = listOf(LocationManager.GPS_PROVIDER, LocationManager.NETWORK_PROVIDER).firstOrNull { it in locationManager.allProviders } ?: return
        locationManager.requestLocationUpdates(provider, LOCATION_INTERVAL_MS, 0f, locationListener, Looper.getMainLooper())
    }

    private fun enterKiosk() {
        if (!devicePolicy.isDeviceOwnerApp(activity.packageName)) return
        val home =
            IntentFilter(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                addCategory(Intent.CATEGORY_DEFAULT)
            }
        val plugged = BatteryManager.BATTERY_PLUGGED_AC or BatteryManager.BATTERY_PLUGGED_USB or BatteryManager.BATTERY_PLUGGED_WIRELESS
        devicePolicy.setLockTaskPackages(admin, arrayOf(activity.packageName))
        devicePolicy.addPersistentPreferredActivity(admin, home, ComponentName(activity, MainActivity::class.java))
        devicePolicy.setKeyguardDisabled(admin, true)
        devicePolicy.setStatusBarDisabled(admin, true)
        devicePolicy.setGlobalSetting(admin, Settings.Global.STAY_ON_WHILE_PLUGGED_IN, plugged.toString())
        activity.startLockTask()
    }

    private fun exitKiosk() {
        if (!devicePolicy.isDeviceOwnerApp(activity.packageName)) return
        activity.stopLockTask()
        devicePolicy.clearPackagePersistentPreferredActivities(admin, activity.packageName)
        devicePolicy.setStatusBarDisabled(admin, false)
        devicePolicy.setKeyguardDisabled(admin, false)
        devicePolicy.setGlobalSetting(admin, Settings.Global.STAY_ON_WHILE_PLUGGED_IN, "0")
        devicePolicy.setLockTaskPackages(admin, emptyArray())
        @Suppress("DEPRECATION")
        devicePolicy.clearDeviceOwnerApp(activity.packageName)
    }

    private fun lockScreen() {
        if (devicePolicy.isAdminActive(admin)) devicePolicy.lockNow()
    }

    @Suppress("DEPRECATION")
    private fun mapsCredentials(): Map<String, String?> {
        val packageManager = activity.packageManager
        val apiKey = packageManager.getApplicationInfo(activity.packageName, PackageManager.GET_META_DATA).metaData?.getString(MAPS_KEY_META)
        val signer = packageManager.getPackageInfo(activity.packageName, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo?.apkContentsSigners?.firstOrNull()
        val certificate = signer?.let { MessageDigest.getInstance("SHA-1").digest(it.toByteArray()).joinToString("") { byte -> "%02X".format(byte) } }
        return mapOf("apiKey" to apiKey, "certificate" to certificate, "package" to activity.packageName)
    }

    private fun setBrightness(level: Double?) {
        val attributes = activity.window.attributes
        attributes.screenBrightness = level?.toFloat() ?: WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        activity.window.attributes = attributes
    }

    private fun setKeepScreenOn(keepOn: Boolean) {
        if (keepOn) {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }

    private fun setReducedFrameRate(reduced: Boolean) {
        val display = activity.display ?: return
        val current = display.mode
        val sameResolution = display.supportedModes.filter { it.physicalWidth == current.physicalWidth && it.physicalHeight == current.physicalHeight }
        val target = if (reduced) sameResolution.filter { it.refreshRate >= REDUCED_REFRESH_HZ }.minByOrNull { it.refreshRate } else sameResolution.maxByOrNull { it.refreshRate }
        val attributes = activity.window.attributes
        attributes.preferredDisplayModeId = target?.modeId ?: 0
        activity.window.attributes = attributes
    }

    @Suppress("DEPRECATION")
    private fun wakeScreen() = powerManager.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP, WAKE_TAG).acquire(WAKE_HOLD_MS)

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) = Unit

    override fun onSensorChanged(event: SensorEvent) {
        luxSink?.success(event.values[0].toDouble())
    }
}
