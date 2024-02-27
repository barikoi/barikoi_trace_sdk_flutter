package com.barikoi.barikoi_trace_sdk_flutter

import android.app.Activity
import android.content.Context
import android.util.Log
import android.widget.Toast
import com.barikoi.barikoitrace.BarikoiTrace
import com.barikoi.barikoitrace.TraceMode
import com.barikoi.barikoitrace.callback.BarikoiTraceTripStateCallback
import com.barikoi.barikoitrace.callback.BarikoiTraceUserCallback
import com.barikoi.barikoitrace.models.BarikoiTraceError
import com.barikoi.barikoitrace.models.BarikoiTraceUser
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** BarikoiTraceSdkFlutterPlugin */
class BarikoiTraceSdkFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "barikoi_trace_sdk_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                val key = call.argument("apiKey") ?: "BARIKOI_API_KEY"
                BarikoiTrace.initialize(context, key)
                activity.let {
                    BarikoiTrace.requestNotificationPermission(it)
                    if (!BarikoiTrace.isLocationPermissionsGranted()) {
                        BarikoiTrace.requestLocationPermissions(it)
                    }
                    if (!BarikoiTrace.isLocationSettingsOn()) {
                        BarikoiTrace.requestLocationServices(it)
                    }
                    BarikoiTrace.checkAppServicePermission(it)
                }
                result.success(true)
            }

            "setOrCreateUser" -> {
                val userName = call.argument("name") ?: "Not Found"
                val userEmail = call.argument("email") ?: ""
                val userPhone = call.argument("phone") ?: "Not Found"
                activity.let {
                    if (BarikoiTrace.isOnTrip()) {
                        Toast.makeText(it, "cannot change user mid journey!", Toast.LENGTH_SHORT)
                            .show()
                        result.success(true)
                    }
                    BarikoiTrace.setOrCreateUser(
                        userName,
                        userEmail,
                        userPhone,
                        object : BarikoiTraceUserCallback {
                            override fun onFailure(barikoiError: BarikoiTraceError?) {
                                if (barikoiError != null) {
                                    Toast.makeText(it, barikoiError.message, Toast.LENGTH_SHORT)
                                        .show()
                                }
                            }

                            override fun onSuccess(traceUser: BarikoiTraceUser?) {
                                if (traceUser != null) {
                                    Toast.makeText(
                                        it,
                                        "user set: " + traceUser.userId,
                                        Toast.LENGTH_SHORT
                                    ).show()
                                }
                                BarikoiTrace.syncTripstate(object : BarikoiTraceTripStateCallback {
                                    override fun onSuccess() {

                                    }

                                    override fun onFailure(barikoiError: BarikoiTraceError) {
                                        Log.e("trip-state", barikoiError.message)
                                    }
                                })
                            }
                        })
                }
                result.success(true)
            }

            "startTracking" -> {
                val tag = call.argument("tag") ?: "test"
                activity.let {
                    BarikoiTrace.requestNotificationPermission(it)
                    if (!BarikoiTrace.isLocationPermissionsGranted()) {
                        BarikoiTrace.requestLocationPermissions(it)
                    }
                    if (!BarikoiTrace.isLocationSettingsOn()) {
                        BarikoiTrace.requestLocationServices(it)
                    }
                    BarikoiTrace.checkAppServicePermission(it)

                    BarikoiTrace.startTracking(TraceMode.ACTIVE)
                }
                result.success(true)
            }

            "endTracking" -> {
                BarikoiTrace.stopTracking()
                result.success(true)
            }

            "getUserId" -> {}
            "getUser" -> {}
            "isLocationPermissionsGranted" -> {}
            "isLocationSettingsOn" -> {}
            else -> result.notImplemented()
        }

    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}