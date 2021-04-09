import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_umeng_analytics_with_push.dart';

/// The interface that implementations of umeng_analytics_with_push must implement.
///
/// Platform implementations should extend this class rather than implement it as `umeng_analytics_with_push`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [UmengAnalyticsWithPushPlatform] methods.
abstract class UmengAnalyticsWithPushPlatform extends PlatformInterface {
  /// Constructs a UmengAnalyticsWithPushPlatform.
  UmengAnalyticsWithPushPlatform() : super(token: _token);

  static final Object _token = Object();

  static UmengAnalyticsWithPushPlatform _instance =
      MethodChannelUmengAnalyticsWithPush();

  /// The default instance of [UmengAnalyticsWithPushPlatform] to use.
  ///
  /// Defaults to [MethodChannelUmengAnalyticsWithPush].
  static UmengAnalyticsWithPushPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UmengAnalyticsWithPushPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(UmengAnalyticsWithPushPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 设备测试信息
  ///
  /// https://mobile.umeng.com/platform/integration/device/edit
  Future<Map<String, String?>?> get testDeviceInfo;

  /// OAID
  Future<String?> get oaid;

  /// UTDID
  Future<String?> get utdid;

  /// 初始化推送和分析
  ///
  /// 调用前请先查看下方合规指南
  ///
  /// **合规指南：**
  ///  > [Android 合规指南](https://developer.umeng.com/docs/119267/detail/182050)
  ///
  ///  > [iOS 合规指南](https://developer.umeng.com/docs/119267/detail/185919)
  ///
  /// [type] only phone, box
  ///
  /// [catchUncaughtExceptions] 捕获漏网异常，只抓取原生异常
  ///
  ///  默认情况下，应用在前台是显示通知的。 开发者更改前台通知显示设置后，会根据更改生效。
  Future<void> initialize({
    String? type,
    bool? catchUncaughtExceptions,
  });

  /// 统计事件
  ///
  /// params support [String], [Map]
  ///
  /// if params isn't Map, will ignore counter
  Future<void> onEvent(String event, [dynamic? params, int? counter]);

  /// 页面进入前台
  Future<void> onPageStart(String page);

  /// 页面退到后台
  Future<void> onPageEnd(String page);

  /// 页面变化
  Future<void> onPageChanged(String page);

  /// 统计应用账号登录
  Future<void> onProfileSignIn(String id, String provider);

  /// 统计应用账号登出
  Future<void> onProfileSignOut();

  /// 获取 PushToken
  ///
  /// 如果从未获取成功，则会从新获取
  Future<String?> get deviceToken;

  /// 绑定别名
  ///
  /// 将某一类型的别名ID绑定至某设备，老的绑定设备信息被覆盖
  ///
  /// 别名ID和deviceToken是一对一的映射关系
  Future<void> putAlias(String type, String alias);

  /// 增加别名
  ///
  /// 将某一类型的别名ID绑定至某设备，老的绑定设备信息还在
  ///
  /// 别名ID和device_token是一对多的映射关系
  Future<void> addAlias(String type, String alias);

  /// 移除别名
  Future<void> removeAlias(String type, String alias);

  /// 添加标签
  ///
  /// 示例：将“标签1”、“标签2”绑定至该设备
  Future<void> addTags(List<String> tags);

  ///获取服务器端的所有标签
  Future<List<String>> getTags();

  /// 删除标签
  ///
  /// 将之前添加的标签中的一个或多个删除
  Future<void> removeTags(List<String> tags);
}

