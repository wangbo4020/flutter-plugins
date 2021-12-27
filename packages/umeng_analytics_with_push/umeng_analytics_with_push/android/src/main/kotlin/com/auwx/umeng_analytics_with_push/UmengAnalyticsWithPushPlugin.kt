package com.auwx.umeng_analytics_with_push

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import com.umeng.commonsdk.statistics.common.DeviceConfig
import com.umeng.message.PushAgent
import com.umeng.message.api.UPushRegisterCallback
import com.ut.device.UTDevice
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.FlutterLifecycleAdapter
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** UmengAnalyticsWithPushPlugin */
class UmengAnalyticsWithPushPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {
        private const val LOG = false
        private const val TAG = "UmengAWithPPlugin"
    }

    private lateinit var context: Context

    private lateinit var channel: MethodChannel
    private lateinit var handler: Handler

    /**
     * 用于 Flutter 页面统计
     */
    private var currentPage: String? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        if (LOG) Log.d(TAG, "onAttachedToEngine: ")
        context = flutterPluginBinding.applicationContext
        handler = Handler(Looper.getMainLooper())

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.auwx.plugins/umeng_analytics_with_push")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        if (LOG) Log.i(TAG, "onMethodCall: ${call.method} ${call.arguments} on ${Thread.currentThread().name}")
        if (call.method == "initialize") {

            val deviceType = call.argument<String>("device-type")
            val cue = call.argument<Boolean>("catch-uncaught-exceptions")
            val nof = call.argument<Boolean>("notification-on-foreground")

            UmengAnalyticsWithPush.initialize(context, deviceType = deviceType?.run {
                return@run if (this == "box") {
                    UMConfigure.DEVICE_TYPE_BOX
                } else {
                    UMConfigure.DEVICE_TYPE_PHONE
                }
            }, catchUncaughtExceptions = cue, notificationOnForeground = nof)
            result.success(null)
        } else if (call.method == "getTestDeviceInfo") {
            result.success(mapOf(
                    "device_id" to DeviceConfig.getDeviceIdForGeneral(context),
                    "mac" to DeviceConfig.getMac(context),
            ))
        } else if (call.method == "putPushAlias") {

            val aliasType = call.argument<String>("alias-type")!!
            val aliasVal = call.argument<String>("alias-value")!!

            PushAgent.getInstance(context).setAlias(aliasVal, aliasType) { isSuccess, message ->
                if (LOG) Log.d(TAG, "setAlias: <$aliasType : $aliasVal> $isSuccess, $message")
                handler.post {
                    if (isSuccess) {
                        result.success(null);
                    } else {
                        result.error("PutAliasError", message ?: "setAlias fail", null)
                    }
                }
            }
        } else if (call.method == "addPushAlias") {

            val agent = PushAgent.getInstance(context)
            val aliasType = call.argument<String>("alias-type")
            val aliasVal = call.argument<String>("alias-value")

            agent.addAlias(aliasVal, aliasType) { successful, message ->
                if (LOG) Log.d(TAG, "addAlias: <$aliasType : $aliasVal> $successful, $message")

                handler.post {
                    if (successful) {
                        result.success(null);
                    } else {
                        result.error("AddAliasError", message ?: "setAlias fail", null)
                    }
                }
            }
        } else if (call.method == "removePushAlias") {

            val agent = PushAgent.getInstance(context)
            val aliasType = call.argument<String>("alias-type")
            val aliasVal = call.argument<String>("alias-value")
            agent.deleteAlias(aliasVal, aliasType) { successful, message ->
                handler.post {
                    if (LOG) Log.d(TAG, "deleteAlias: <$aliasType : $aliasVal> $successful, $message")
                    if (successful) {
                        result.success(null);
                    } else {
                        result.error("RemoveAliasError", message ?: "setAlias fail", null)
                    }
                }
            }
        } else if (call.method == "addPushTags") {

            val tags = (call.arguments as List<*>)
            val array = Array(tags.size) { i -> tags[i] as String }

            val agent = PushAgent.getInstance(context)
            agent.tagManager.addTags({ isSuccess, ret ->
                if (LOG) Log.d(TAG, "addTags: $isSuccess, $ret")

                handler.post {
                    if (isSuccess) {
                        result.success(null)
                    } else {
                        result.error("AddTagsError", ret.errors, ret.msg)
                    }
                }
            }, *array)
        } else if (call.method == "getPushTags") {
            val agent = PushAgent.getInstance(context)
            agent.tagManager.getTags { isSuccess, tags ->

                if (LOG) Log.d(TAG, "getTags: $isSuccess, $tags")
                handler.post {
                    if (isSuccess) {
                        result.success(tags)
                    } else {
                        result.error("GetTagsError", "Get tags fail", null)
                    }
                }
            }
        } else if (call.method == "removePushTags") {
            val tags = (call.arguments as List<*>)
            val array = Array(tags.size) { i -> tags[i] as String }

            val agent = PushAgent.getInstance(context)
            agent.tagManager.deleteTags({ isSuccess, ret ->

                handler.post {
                    if (LOG) Log.d(TAG, "deleteTags: $isSuccess, $ret")
                    if (isSuccess) {
                        result.success(null)
                    } else {
                        result.error("RemoveTagsError", ret.errors, ret.msg)
                    }
                }
            }, *array)
        } else if (call.method == "deviceToken") {
            UmengAnalyticsWithPush.getDeviceToken(context, object : UPushRegisterCallback {
                override fun onSuccess(deviceToken: String) {

                    handler.post { result.success(deviceToken) }
                }

                override fun onFailure(s: String?, s1: String?) {

                    handler.post { result.error("DeviceTokenError", s ?: "Push register fail", s1) }
                }
            })
        } else if (call.method == "oaid") {
//            Log.i(TAG, "oaid: ")
            UMConfigure.getOaid(context) { oaid ->
                if (LOG) Log.d(TAG, "getOaid: $oaid")
                handler.post { result.success(oaid) }
            }
        } else if (call.method == "utdid") {
//            Log.i(TAG, "utdid: ")
            result.success(UTDevice.getUtdid(context))
        } else if (call.method == "onPageStart") {
            val name = call.arguments as String
            MobclickAgent.onPageStart(name)
            result.success(null)
        } else if (call.method == "onPageEnd") {
            val name = call.arguments as String
            MobclickAgent.onPageEnd(name)
            result.success(null)
        } else if (call.method == "onPageChanged") {
            // 这个方法为了统计 Flutter 页面
            val newPage = call.arguments as String?

            if (newPage != this.currentPage) {
                var log = ""
                this.currentPage?.apply {
                    MobclickAgent.onPageEnd(this)
                    log += "Pop $this. "
                }
                newPage?.apply {
                    MobclickAgent.onPageStart(this)
                    log += "Push $this. "
                }

                if (LOG) Log.d(TAG, "onPageChanged: $log")
                this.currentPage = newPage
            }
            result.success(null)
        } else if (call.method == "onEvent") {
            val event = call.argument<String>("event")!!
            val params = call.argument<Any>("params")
            if (params is Map<*, *>) {
                val counter = call.argument<Int>("counter")
                val attrs = params.entries.fold(mutableMapOf<String, String?>()) { p, e ->
                    p.apply { this[e.key as String] = e.value?.toString() }
                }
                if (counter == null) {
                    MobclickAgent.onEvent(context, event, attrs)
                } else {
                    MobclickAgent.onEventValue(context, event, attrs, counter)
                }
            } else if (params is String) {
                MobclickAgent.onEvent(context, event, params)
            } else {
                MobclickAgent.onEvent(context, event)
            }
            result.success(null)
        } else if (call.method == "onProfileSignIn") {
            val id = call.argument<String>("id")
            val provider = call.argument<String>("provider")
            MobclickAgent.onProfileSignIn(provider, id)
            result.success(null)
        } else if (call.method == "onProfileSignOut") {
            MobclickAgent.onProfileSignOff()
            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
//        handler.removeCallbacksAndMessages(null)
        channel.setMethodCallHandler(null)
        if (LOG) Log.d(TAG, "onDetachedFromEngine: ")
    }

    private var activity: Activity? = null
    private var lifecycle: Lifecycle? = null
    private val onLifecycleChanged = object : LifecycleObserver {
        @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
        fun onCreate() {
            if (LOG) Log.d(TAG, "onCreate: ")
            PushAgent.getInstance(context).onAppStart()
        }

        @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
        fun onResume() {
            if (LOG) Log.d(TAG, "onResume: ")
            MobclickAgent.onResume(activity)
        }

        @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
        fun onPause() {
            if (LOG) Log.d(TAG, "onPause: ")
            MobclickAgent.onPause(activity)
        }

    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        lifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
        lifecycle!!.addObserver(onLifecycleChanged)
        if (LOG) Log.d(TAG, "onAttachedToActivity: ${lifecycle?.currentState}")
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onDetachedFromActivity() {
        var log = ""
        currentPage?.apply {
            MobclickAgent.onPageEnd(this)
            log += "Pop $this"
        }
        lifecycle?.removeObserver(onLifecycleChanged)
        lifecycle = null
        activity = null
        if (LOG) Log.d(TAG, "onDetachedFromActivity: $log")
    }
}
