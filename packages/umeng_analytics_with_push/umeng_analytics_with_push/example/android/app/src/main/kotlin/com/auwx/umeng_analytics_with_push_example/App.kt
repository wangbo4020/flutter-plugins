package com.auwx.umeng_analytics_with_push_example

import com.auwx.umeng_analytics_with_push.UmengAnalyticsWithPush
import io.flutter.app.FlutterApplication

class App: FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        UmengAnalyticsWithPush.preinitial(
                this,
                resourcePackageName = "com.auwx.umeng_analytics_with_push_example",
                enableLog = BuildConfig.DEBUG,
        )
    }
}