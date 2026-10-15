package com.crn.tubeflow.cellular

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyDisplayInfo
import android.telephony.TelephonyManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Reports "5g" | "4g" | "3g" | "2g" | "unknown" | "permission_denied".
 * Registered through the Flutter plugin registrant, so it exists in the UI,
 * foreground-service and WorkManager engines alike.
 */
class CellularGenerationPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private companion object {
        // TelephonyManager.NETWORK_TYPE_LTE_CA is hidden API; value is stable.
        const val NETWORK_TYPE_LTE_CA = 19
    }

    private var channel: MethodChannel? = null
    private var context: Context? = null

    // 5G NSA shows up as LTE in dataNetworkType; only the display-info
    // override (Android 11+) tells it apart. 0 = none/unknown.
    @Volatile private var overrideType = 0
    private var listening = false
    private var callback: Any? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "tubeflow/cellular").also {
            it.setMethodCallHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        stopListening()
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "generation") result.success(generation()) else result.notImplemented()
    }

    private fun telephony(): TelephonyManager? =
        context?.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager

    private fun generation(): String {
        val ctx = context ?: return "unknown"
        if (ctx.checkSelfPermission(Manifest.permission.READ_PHONE_STATE) !=
            PackageManager.PERMISSION_GRANTED
        ) return "permission_denied"
        val tm = telephony() ?: return "unknown"
        return try {
            startListening(tm)
            when (tm.dataNetworkType) {
                TelephonyManager.NETWORK_TYPE_NR -> "5g"
                TelephonyManager.NETWORK_TYPE_LTE, NETWORK_TYPE_LTE_CA ->
                    // 3 = NR_NSA, 4 = NR_NSA_MMWAVE (old), 5 = NR_ADVANCED
                    if (overrideType == 3 || overrideType == 4 || overrideType == 5) "5g" else "4g"
                TelephonyManager.NETWORK_TYPE_HSPAP, TelephonyManager.NETWORK_TYPE_HSPA,
                TelephonyManager.NETWORK_TYPE_HSDPA, TelephonyManager.NETWORK_TYPE_HSUPA,
                TelephonyManager.NETWORK_TYPE_UMTS, TelephonyManager.NETWORK_TYPE_TD_SCDMA,
                TelephonyManager.NETWORK_TYPE_EVDO_0, TelephonyManager.NETWORK_TYPE_EVDO_A,
                TelephonyManager.NETWORK_TYPE_EVDO_B, TelephonyManager.NETWORK_TYPE_EHRPD -> "3g"
                TelephonyManager.NETWORK_TYPE_GPRS, TelephonyManager.NETWORK_TYPE_EDGE,
                TelephonyManager.NETWORK_TYPE_CDMA, TelephonyManager.NETWORK_TYPE_1xRTT,
                TelephonyManager.NETWORK_TYPE_IDEN, TelephonyManager.NETWORK_TYPE_GSM -> "2g"
                else -> "unknown"
            }
        } catch (e: SecurityException) {
            "permission_denied"
        } catch (e: Exception) {
            "unknown"
        }
    }

    /** Tracks the 5G-NSA display override (Android 11+; older versions just see LTE). */
    private fun startListening(tm: TelephonyManager) {
        if (listening || Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return
        val ctx = context ?: return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val cb = object : TelephonyCallback(), TelephonyCallback.DisplayInfoListener {
                    override fun onDisplayInfoChanged(info: TelephonyDisplayInfo) {
                        overrideType = info.overrideNetworkType
                    }
                }
                tm.registerTelephonyCallback(ctx.mainExecutor, cb)
                callback = cb
            } else {
                @Suppress("DEPRECATION")
                val l = object : PhoneStateListener() {
                    @Deprecated("Deprecated in Java")
                    override fun onDisplayInfoChanged(info: TelephonyDisplayInfo) {
                        overrideType = info.overrideNetworkType
                    }
                }
                @Suppress("DEPRECATION")
                tm.listen(l, PhoneStateListener.LISTEN_DISPLAY_INFO_CHANGED)
                callback = l
            }
            listening = true
        } catch (e: Exception) {
            // Without the listener NSA 5G reads as 4G; SA 5G still works.
        }
    }

    private fun stopListening() {
        val tm = telephony()
        val cb = callback
        if (tm != null && cb != null) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && cb is TelephonyCallback) {
                    tm.unregisterTelephonyCallback(cb)
                } else if (cb is PhoneStateListener) {
                    @Suppress("DEPRECATION")
                    tm.listen(cb, PhoneStateListener.LISTEN_NONE)
                }
            } catch (_: Exception) {
            }
        }
        callback = null
        listening = false
    }
}
