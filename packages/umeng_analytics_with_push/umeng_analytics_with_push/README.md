# umeng_analytics_with_push

友盟统计 (U-App) 与友盟分析 (U-Push) Flutter Plugin.  

容易集成的友盟分析和Push，集成分析只需两步，集成 Push 再加两步。
  
## Usage  
  
To use this plugin, add `umeng_analytics_with_push` as a [dependency in your `pubspec.yaml` file](https://flutter.io/platform-plugins/).  
For example:  
```yaml  
dependencies:  
    umeng_analytics_with_push: ^0.2.0
```

#### 该插件已遵循[合规指南](https://developer.umeng.com/docs/67966/detail/207155)

该插件只集成了分析和Push必须的依赖项，其他可选项依赖由使用者根据实际需求添加。  
比如 Crash, Push 厂商通道等，请参考 Example 添加。  
Push 厂商通道会根据依赖和配置自动初始化，请参考[厂商Push配置](#vendor)。

#### 记录事件
```dart
  // 无参数记录事件
  UmengAnalyticsWithPush.onEvent("app_startup");
  // or
  // 参数
  UmengAnalyticsWithPush.onEvent("app_startup", {
    "time": DateTime.now().toISOString()
  });
  // or
  // 参数 + counter
  UmengAnalyticsWithPush.onEvent("app_startup", {
    "time": DateTime.now().toISOString()
  }, 1);
```

#### 获取 DeviceToken，集成 Push 时调用
```dart
  final deviceToken = await UmengAnalyticsWithPush.deviceToken;
```

#### 统计路由
```dart
import 'package:umeng_analytics_with_push/umeng_analytics_with_push.dart';

class App extends StatelessWidget {

  // ... other code 
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [UmengAnalyticsObserver(log: !kReleaseMode)],
      // ...
  }
}
```

#### 其他 API
```dart
  // 获取 OAID
  final String oaid = await UmengAnalyticsWithPush.oaid;
  // 获取 UTDID
  final String utdid = await UmengAnalyticsWithPush.utdid;
  // 用户登录
  await UmengAnalyticsWithPush.onProfileSignIn("ID", "Provider");
  // 用户登出
  await UmengAnalyticsWithPush.onProfileSignOut();
  // 获取测试设备信息
  final String testInfo = await UmengAnalyticsWithPush.testDeviceInfo;
  // 以下 API 在集成 Push 时可调用
  // Alias
  await UmengAnalyticsWithPush.putAlias("from", "I'm from flutter"); 
  await UmengAnalyticsWithPush.addAlias("from", "I'm from flutter"); 
  await UmengAnalyticsWithPush.removeAlias("from", "I'm from flutter"); 
  // Tags
  await UmengAnalyticsWithPush.addTags(["flutter_tag1", "flutter_tag2"]);
  final List<String> tags = await UmengAnalyticsWithPush.getTags();
  await UmengAnalyticsWithPush.removeTags(["flutter_tag1", "flutter_tag2"]);
```

## Setup

  **暂不支持 Dart 处理自定义消息**

### Flutter

#### Initialization

可在用户同意隐私协议后再调用该方法，建议每次都调用
```dart
await UmengAnalyticsWithPush.initialize();
```


### [Android](https://developer.umeng.com/docs/67966/detail/153908#h1--sdk-3)

#### Initialization
```kotlin
import com.auwx.umeng_analytics_with_push.UmengAnalyticsWithPush
import io.flutter.app.FlutterApplication

class App: FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        UmengAnalyticsWithPush.preinitial(
            this,
            // AppKey, secret, channel 也可配置在 AndroidManifest 中
            // Required here or AndroidManifest.application
            //   <meta-data android:name="UMENG_APPKEY" android:value="aaaaaaaaaaaaaaaaaa" />
            //   <meta-data android:name="UMENG_SECRET" android:value="aaaaaaaaaaaaaaaaaa" />
            //   <meta-data android:name="UMENG_CHANNEL" android:value="${CHANNEL}" />
            appKey = getString(R.string.umeng_app_key),
            secret = getString(R.string.umeng_secret),
            channel = BuildConfig.FLAVOR,
            enableLog = BuildConfig.DEBUG,
            // ... other arguments    
        )
    }
}
```

## 进阶

#### <p id="vendor">配置厂商 Push 通道</p>

**厂商配置需要使用者手动添加，需要同时添加厂商通道的依赖并在 AndroidManifest 中配置相应的id才会生效**  
**配置成功后插件会自动调用厂商Push的初始化**


* app build.gradle
```groovy
dependencies {
    // 以下配置请根据需求选择性添加
    // Umeng Push 厂商 SDK  https://developer.umeng.com/docs/67966/detail/98589
    // 小米 Push 通道
    implementation 'com.umeng.umsdk:xiaomi-push:4.8.1'
    implementation 'com.umeng.umsdk:xiaomi-umengaccs:1.2.6'
    // 华为 Push 通道
    implementation 'com.huawei.hms:push:6.1.0.300'
    implementation 'com.umeng.umsdk:huawei-umengaccs:1.3.6'
    // Vivo Push 通道
    implementation 'com.umeng.umsdk:vivo-push:3.0.0.3'
    implementation 'com.umeng.umsdk:vivo-umengaccs:1.1.5'
    // Meizu Push 通道
    implementation 'com.umeng.umsdk:meizu-push:4.1.4'
    implementation 'com.umeng.umsdk:meizu-umengaccs:1.1.5'
    // Oppo Push 通道
    implementation 'com.umeng.umsdk:oppo-push:2.1.0'
    implementation 'com.umeng.umsdk:oppo-umengaccs:1.0.7-fix'
}
```
* 华为Push还需添加额外依赖，请参考[此处链接](https://developer.umeng.com/docs/67966/detail/98589#h2--push-sdk12) 完成配置


* AndroidManifest.xml
```xml
<manifest>
    <application android:name=".App">
        <!-- ** Umeng Start ** -->
        <!-- Required Here or UmengAnalyticsWithPush.preinitial() -->
        <meta-data
            android:name="UMENG_APPKEY"
            android:value="@string/umeng_app_key" /> <!-- Channel ID用来标识App的推广渠道，作为推送消息时给用户分组的一个维度。 -->
        <!-- Option your flavor name,
         in your build.gradle manifestPlaceholders = [UMENG_CHANNEL: ""]
         请参考 example app build.gradle
        -->
        <meta-data
            android:name="UMENG_CHANNEL"
            android:value="${UMENG_CHANNEL}" />
        <!-- Under tag is umeng_analysis_with_push plugin define -->
        <!-- Option if don't need push -->
        <meta-data
            android:name="UMENG_SECRET"
            android:value="@string/umeng_secret" />
        <!-- 以下为厂商推送配置，具体请参考Umeng官方文档 https://developer.umeng.com/docs/67966/detail/98589 -->
        <!-- 以下配置请根据需求选择性添加 -->
        <!-- huawei push参数声明 -->
        <!-- huawei start Option -->
        <meta-data
            android:name="com.huawei.hms.client.appid"
            android:value="appid=000000000" />
        <!-- huawei end -->
        <!-- Vivo push参数声明 -->
        <!-- Vivo start-->
        <meta-data
            android:name="com.vivo.push.app_id"
            android:value="000000000" />
        <meta-data
            android:name="com.vivo.push.api_key"
            android:value="aaaaaaaaaaaaaaaaaaaaaaaa" />
        <!-- Vivo end-->
        <!-- Oppo push参数声明 -->
        <!-- Oppo start-->
        <!-- Under tag is umeng_analysis_with_push plugin define -->
        <meta-data
            android:name="com.oppo.push.app_key"
            android:value="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" />
        <meta-data
            android:name="com.oppo.push.app_secret"
            android:value="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" />
        <!-- Oppo end-->
        <!-- Meizu push 参数声明 https://developer.umeng.com/docs/67966/detail/98589#h1--push-4 -->
        <!-- Meizu start-->
        <!-- Under tag is umeng_analysis_with_push plugin define -->
        <meta-data
            android:name="com.meizu.push.app_id"
            android:value="aaaaaaaaaaaaaaaaaaa" />
        <meta-data
            android:name="com.meizu.push.app_key"
            android:value="aaaaaaaaaaaaaaaaaaaa" />
        <!-- Meizu end-->
        <!-- XiaoMi start-->
        <!-- Under tag is umeng_analysis_with_push plugin define -->
        <!-- Android 会将纯数字的 meta-data 识别为 Number 类型
        所有数字形式的 meta-data 请在加前缀 "\ " 或定义到 strings.xml 中在此处引用以识别为 String -->
        <meta-data
            android:name="com.xiaomi.push.app_id"
            android:value="\ 000000000000000000000" />
        <meta-data
            android:name="com.xiaomi.push.app_key"
            android:value="\ 0000000000000" />
        <!-- XiaoMi end-->
        <!-- ** Umeng End ** -->
    </application>
</manifest>
```

#### [魅族接入](https://developer.umeng.com/docs/67966/detail/98589#h1--push-4)
1. 受魅族接入限制，魅族需要在包名目录下实现一个自定义Recevier，继承自MeizuPushReceiver，例如：
```java
public class MeizuTestReceiver extends MeizuPushReceiver {
}
```
1. 然后在AndroidManifest.xml中配置该Recevier，例如：

```xml
<!--魅族push应用定义消息receiver声明 -->
<receiver android:name="${applicationId}.MeizuTestReceiver">
    <intent-filter>
        <!-- 接收push消息 -->
        <action android:name="com.meizu.flyme.push.intent.MESSAGE" />
        <!-- 接收register消息 -->
        <action android:name="com.meizu.flyme.push.intent.REGISTER.FEEDBACK" />
        <!-- 接收unregister消息-->
        <action android:name="com.meizu.flyme.push.intent.UNREGISTER.FEEDBACK" />
        <!-- 兼容低版本Flyme3推送服务配置 -->
        <action android:name="com.meizu.c2dm.intent.REGISTRATION" />
        <action android:name="com.meizu.c2dm.intent.RECEIVE" />

        <category android:name="${applicationId}" />
    </intent-filter>
</receiver>
```
1. 请在drawable目录下添加一个图标，命名为stat_sys_third_app_notify.png，建议尺寸64px * 64px，图标四周留有透明。若不添加此图标，可能在部分魅族手机上无法弹出通知。

#### Crash 收集
自己在主工程添加依赖项即可
* app build.gradle
```groovy
dependencies {
    implementation 'com.umeng.umsdk:crash:0.0.5'
}
```

### iOS
  暂未支持
  
## Usage

  Look at [exapmle](example/lib/main.dart)
