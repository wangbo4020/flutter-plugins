package com.auwx.umeng_analytics_with_push

import android.app.Application
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.util.Log
import com.taobao.accs.ACCSClient
import com.taobao.accs.AccsClientConfig
import com.taobao.agoo.TaobaoRegister
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import com.umeng.commonsdk.utils.UMUtils
import com.umeng.message.PushAgent
import com.umeng.message.api.UPushRegisterCallback


object UmengAnalyticsWithPush {

    private const val TAG = "UmengAnalysisWithPush"
    private const val KEY_INITIALIZED = "umeng_analytics_with_push:was_initialized"
    private const val KEY_DEVICE_TYPE = "umeng_analytics_with_push:device_type"

    private var LOG = false
    private var appKey: String? = null
    private var secret: String? = null

    private var deviceToken: String? = null
    private val registerCallbacks = mutableListOf<UPushRegisterCallback>()

    /**
     * 预初始化
     *
     * [appKey] if null, will obtain from AndroidManifest , UMENG_APPKEY field
     *
     * [channel] if null, will obtain from AndroidManifest
     *
     * 请参考友盟集成[合规指南](https://developer.umeng.com/docs/119267/detail/182050)
     */
    @JvmStatic
    fun preinitial(
            context: Context,
            appKey: String? = null,
            secret: String? = null,
            channel: String? = null,
            resourcePackageName: String? = null,
            eventProcess: Boolean? = null,
            enableEncrypt: Boolean? = null,
            enableLog: Boolean? = null,
    ) {
        appKey?.let { this.appKey = it }
        secret?.let { this.secret = it }
        enableLog?.let { this.LOG = it }
        enableEncrypt?.apply { UMConfigure.setEncryptEnabled(this) }
        enableLog?.apply { UMConfigure.setLogEnabled(this) }
        eventProcess?.apply { UMConfigure.setProcessEvent(this) }

        val app = context.packageManager.getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)
        // 该功能为独立模块，尽量不引用其他工具
        fixGarbledCode(context)

        UMConfigure.preInit(context, getUmengAppKey(app), channel)// Should config in AndroidManifest.xml

        val agent = PushAgent.getInstance(context)
        if (resourcePackageName != null) {
            agent.resourcePackageName = resourcePackageName
        }

        // 使用文件保存初始化状态，因为文件跨进程
//        val lock = File(context.filesDir, ".umeng_analytics_with_push-initialized")
//        val wasInitialized = lock.exists()
        val pref = context.getSharedPreferences(context.packageName + "_preferences", Context.MODE_PRIVATE)
        val wasInitialized = pref.getBoolean(KEY_INITIALIZED, false)
        if (LOG) Log.d(TAG, "preinitial: wasInitialized is $wasInitialized")
        if (!wasInitialized && UMUtils.isMainProgress(context)) {
            return
        }
        // 应该在子线程中执行
        initUmeng(context, pref.getInt(KEY_DEVICE_TYPE, UMConfigure.DEVICE_TYPE_PHONE))
    }

    @JvmStatic
    fun initialize(context: Context, deviceType: Int? = null,
                   catchUncaughtExceptions: Boolean? = null,
                   notificationOnForeground: Boolean? = null) {

        MobclickAgent.setCatchUncaughtExceptions(catchUncaughtExceptions ?: false)
//        agent.setNotificaitonOnForeground(notificationOnForeground ?: true)

        val pref = context.getSharedPreferences(context.packageName + "_preferences", Context.MODE_PRIVATE)
        pref.edit().putInt(KEY_DEVICE_TYPE, deviceType ?: UMConfigure.DEVICE_TYPE_PHONE).apply()
        val wasInitialized = pref.getBoolean(KEY_INITIALIZED, false)
        if (LOG) Log.d(TAG, "initialize: wasInitialized is $wasInitialized")
        if (wasInitialized) {
            if (LOG) Log.d(TAG, "initialize: Already initialize")
            return
        }
        pref.edit().putBoolean(KEY_INITIALIZED, true).apply()

        initUmeng(context, deviceType)
    }

    @JvmStatic
    private fun initUmeng(context: Context, deviceType: Int? = null) {
        val app = context.packageManager.getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)
        val umengSecret = getUmengMessageSecret(app)
        UMConfigure.init(context, deviceType ?: UMConfigure.DEVICE_TYPE_PHONE, umengSecret)
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO)

        PushAgent.getInstance(context).register(mRegisterCallback)
        if (UMUtils.isMainProgress(context)) {
            registerDevice(context)
        }
    }

    @JvmStatic
    fun getDeviceToken(context: Context, callback: UPushRegisterCallback) {
//        assert(agent.registerCallback == this)
        if (deviceToken != null) {
            callback.onSuccess(deviceToken)
        } else {
            PushAgent.getInstance(context).register(mRegisterCallback)
            registerCallbacks.add(object : UPushRegisterCallback {
                override fun onSuccess(p0: String?) {
                    registerCallbacks.remove(this)
                    callback.onSuccess(p0)
                }

                override fun onFailure(p0: String?, p1: String?) {
                    registerCallbacks.remove(this)
                    callback.onFailure(p0, p1)
                }
            })
        }
    }

    private fun registerDevice(context: Context) {
//        org.android.agoo.huawei.HuaWeiRegister
//        org.android.agoo.mezu.MeizuRegister
//        org.android.agoo.oppo.OppoRegister
//        org.android.agoo.vivo.VivoRegister
//        org.android.agoo.xiaomi.MiPushRegistar

        val app = context.packageManager.getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)

        // XiaoMi
        val xiaomiAppId = app.metaData.getString("com.xiaomi.push.app_id")
        val xiaomiAppKey = app.metaData.getString("com.xiaomi.push.app_key")
        val hasXiaomi = hasClass("org.android.agoo.xiaomi.MiPushRegistar")
        if (hasXiaomi && xiaomiAppId != null && xiaomiAppKey != null) {
//        Log.d(TAG, "${context.packageName}/xiaomiAppId: $xiaomiAppId, xiaomiAppKey: $xiaomiAppKey")
            org.android.agoo.xiaomi.MiPushRegistar.register(context, xiaomiAppId.trim(), xiaomiAppKey.trim())
            if (LOG) Log.i(TAG, "Xiaomi is registered")
        } else if (hasXiaomi) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "* Not found Xiaomi appId, appKey in AndroidManifest *")
            Log.w(TAG, "<meta-data android:name=\"com.xiaomi.push.app_id\" android:value=\"\" /> <meta-data android:name=\"com.xiaomi.push.app_key\" android:value=\"\" />")
            Log.w(TAG, "*****************************************************")
        } else if (xiaomiAppKey != null && xiaomiAppId != null) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "*********** Not found Xiaomi dependencies ***********")
            Log.w(TAG, "https://developer.umeng.com/docs/67966/detail/98589#h2--push-sdk3")
            Log.w(TAG, "*****************************************************")
        }

        // HuaWei
        val hasHuawei = hasClass("org.android.agoo.huawei.HuaWeiRegister")
        val hasHuaweiAppId = app.metaData.containsKey("com.huawei.hms.client.appid")
        if (hasHuawei && hasHuaweiAppId) {
            // huawei 通道
            org.android.agoo.huawei.HuaWeiRegister.register(context as Application)
            if (LOG) Log.i(TAG, "Huawei is registered")
        } else if (hasHuawei) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "* Not found Huawei appId in AndroidManifest *")
            Log.w(TAG, "<meta-data android:name=\"com.huawei.hms.client.appid\" android:value=\"\" />")
            Log.w(TAG, "*****************************************************")
        } else if (hasHuaweiAppId) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "*********** Not found Huawei dependencies ***********")
            Log.w(TAG, "https://developer.umeng.com/docs/67966/detail/98589#h2--push-sdk12")
            Log.w(TAG, "*****************************************************")
        }

        // MeiZu
        val hasMeizu = hasClass("org.android.agoo.mezu.MeizuRegister")
        val meizuAppId = app.metaData.getString("com.meizu.push.app_id")
        val meizuAppKey = app.metaData.getString("com.meizu.push.app_key")
        if (hasMeizu && meizuAppId != null && meizuAppKey != null) {
            org.android.agoo.mezu.MeizuRegister.register(context, meizuAppId.trim(), meizuAppKey.trim())
            if (LOG) Log.i(TAG, "Meizu is registered")
        } else if (hasMeizu) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "* Not found Meizu appId in AndroidManifest *")
            Log.w(TAG, "<meta-data android:name=\"com.meizu.push.app_id\" android:value=\"\" /> <meta-data android:name=\"com.meizu.push.app_key\" android:value=\"\" />")
            Log.w(TAG, "*****************************************************")
        } else if (meizuAppId != null && meizuAppKey != null) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "*********** Not found Meizu dependencies ***********")
            Log.w(TAG, "https://developer.umeng.com/docs/67966/detail/98589#h2--push-sdk22")
            Log.w(TAG, "*****************************************************")
        }

        // Vivo
        val hasVivo = hasClass("org.android.agoo.vivo.VivoRegister")
        val hasVivoAppId = app.metaData.containsKey("com.vivo.push.app_id")
        val hasVivoApiKey = app.metaData.containsKey("com.vivo.push.api_key")
        if (hasVivo && hasVivoAppId && hasVivoApiKey) {
            // vivo 通道
            org.android.agoo.vivo.VivoRegister.register(context)
            if (LOG) Log.i(TAG, "Vivo is registered")
        } else if (hasVivo) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "* Not found Vivo appId, appKey in AndroidManifest *")
            Log.w(TAG, "<meta-data android:name=\"com.vivo.push.app_id\" android:value=\"\" /> <meta-data android:name=\"com.vivo.push.api_key\" android:value=\"\" />")
            Log.w(TAG, "*****************************************************")
        } else if (hasVivoAppId && hasVivoApiKey) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "*********** Not found Vivo dependencies ***********")
            Log.w(TAG, "https://developer.umeng.com/docs/67966/detail/98589#h2--vivo-push-sdk36")
            Log.w(TAG, "*****************************************************")
        }

        // Oppo
        val hasOppo = hasClass("org.android.agoo.oppo.OppoRegister")
        val oppoAppKey = app.metaData.getString("com.oppo.push.app_key")
        val oppoAppSecret = app.metaData.getString("com.oppo.push.app_secret")
        if (hasOppo && oppoAppKey != null && oppoAppSecret != null) {
            org.android.agoo.oppo.OppoRegister.register(context, oppoAppKey.trim(), oppoAppSecret.trim())
            if (LOG) Log.i(TAG, "Oppo is registered")
        } else if (hasOppo) {

            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "* Not found Oppo appKey, appSecret in AndroidManifest *")
            Log.w(TAG, "<meta-data android:name=\"com.oppo.push.app_key\" android:value=\"\" /> <meta-data android:name=\"com.oppo.push.app_secret\" android:value=\"\" />")
            Log.w(TAG, "*****************************************************")
        } else if (oppoAppKey != null && oppoAppSecret != null) {
            Log.w(TAG, "*****************************************************")
            Log.w(TAG, "*********** Not found Oppo dependencies ***********")
            Log.w(TAG, "https://developer.umeng.com/docs/67966/detail/98589#h2--oppo-push-sdk29")
            Log.w(TAG, "*****************************************************")
        }
    }

    private fun getUmengAppKey(info: ApplicationInfo): String? {
        return this.appKey ?: info.metaData.getString("UMENG_APPKEY")
        ?: info.metaData.getString("UMENG_APPKEY")
    }

    private fun getUmengMessageSecret(info: ApplicationInfo): String? {
        return this.secret ?: info.metaData.getString("UMENG_SECRET")
        ?: info.metaData.getString("UMENG_MESSAGE_SECRET")
    }

    private val mRegisterCallback = object : UPushRegisterCallback {
        override fun onSuccess(deviceToken: String) {
            if (LOG) Log.d(TAG, "onSuccess: $deviceToken")
            this@UmengAnalyticsWithPush.deviceToken = deviceToken
            registerCallbacks.forEach { it.onSuccess(deviceToken) }
        }

        override fun onFailure(p0: String?, p1: String?) {
            if (LOG) Log.d(TAG, "onFailure: $p0, $p1")
            registerCallbacks.forEach { it.onFailure(p0, p1) }
        }
    }

    private fun fixGarbledCode(context: Context) {
        val app = context.packageManager.getApplicationInfo(context.packageName, PackageManager.GET_META_DATA)
        try {
            //解决厂商通道推送乱码问题
            val builder = AccsClientConfig.Builder()
            builder.setAppKey("umeng:" + getUmengAppKey(app))
            builder.setAppSecret(getUmengMessageSecret(app))
            builder.setTag(AccsClientConfig.DEFAULT_CONFIGTAG)
            ACCSClient.init(context, builder.build())
            TaobaoRegister.setAccsConfigTag(context, AccsClientConfig.DEFAULT_CONFIGTAG)
        } catch (e: Exception) {
            if (LOG) Log.w(TAG, "fix garbled code warring", e)
        }
    }

    private fun hasClass(className: String): Boolean {
        return try {
            Class.forName(className)
            true
//            return Class.forName(className) != null
        } catch (ignored: ClassNotFoundException) {
            false
        }
    }
}