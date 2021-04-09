library umeng_analytics_with_push;

import 'dart:async';
import 'dart:convert';

import 'package:umeng_analytics_with_push_platform_interface/umeng_analytics_with_push_platform_interface.dart';

export 'src/observer.dart';

/// 包含了友盟推送与分析的基础功能
class UmengAnalyticsWithPush {
  const UmengAnalyticsWithPush._();

  /// 初始化推送和分析
  ///
  /// 调用前请先查看下方合规指南
  ///
  /// **合规指南：**
  ///  > [Android 合规指南](https://developer.umeng.com/docs/119267/detail/182050)
  ///
  ///  > [iOS 合规指南](https://developer.umeng.com/docs/119267/detail/185919)
  ///
  /// [catchUncaughtExceptions] 捕获漏网异常，只抓取原生异常
  ///
  static Future<void> initialize({
    UmengDeviceType type = UmengDeviceType.phone,
    bool? catchUncaughtExceptions,
  }) {
    return UmengAnalyticsWithPushPlatform.instance.initialize(
      type: type.name,
      catchUncaughtExceptions: catchUncaughtExceptions,
    );
  }

  /// 设备测试信息
  ///
  /// https://mobile.umeng.com/platform/integration/device/edit
  static Future<String?> get testDeviceInfo =>
      UmengAnalyticsWithPushPlatform.instance.testDeviceInfo.then((map) {
        if (map == null) return null;
        return jsonEncode(map);
      });

  /// OAID
  static Future<String?> get oaid =>
      UmengAnalyticsWithPushPlatform.instance.oaid;

  /// UTDID
  static Future<String?> get utdid =>
      UmengAnalyticsWithPushPlatform.instance.utdid;

  /// 统计事件
  ///
  /// params support [String], [Map]
  ///
  /// if params isn't Map, will ignore counter
  static Future<void> onEvent(String event, [dynamic? params, int? counter]) =>
      UmengAnalyticsWithPushPlatform.instance.onEvent(event, params, counter);

  /// 页面进入前台
  static Future<void> onPageStart(String page) =>
      UmengAnalyticsWithPushPlatform.instance.onPageStart(page);

  /// 页面退到后台
  static Future<void> onPageEnd(String page) =>
      UmengAnalyticsWithPushPlatform.instance.onPageEnd(page);

  /// 页面变化
  // static Future<void> onPageChanged(String page) {
  //   return _channel.invokeMethod("onPageChanged", page);
  // }

  /// 统计应用账号登录
  static Future<void> onProfileSignIn(String id, String provider) =>
      UmengAnalyticsWithPushPlatform.instance.onProfileSignIn(id, provider);

  /// 统计应用账号登出
  static Future<void> onProfileSignOut() =>
      UmengAnalyticsWithPushPlatform.instance.onProfileSignOut();

  /// 获取 PushToken
  ///
  /// 如果从未获取成功，则会从新获取
  static Future<String?> get deviceToken =>
      UmengAnalyticsWithPushPlatform.instance.deviceToken;

  /// 绑定别名
  ///
  /// 将某一类型的别名ID绑定至某设备，老的绑定设备信息被覆盖
  ///
  /// 别名ID和deviceToken是一对一的映射关系
  static Future<void> putAlias(String type, String alias) =>
      UmengAnalyticsWithPushPlatform.instance.putAlias(type, alias);

  /// 增加别名
  ///
  /// 将某一类型的别名ID绑定至某设备，老的绑定设备信息还在
  ///
  /// 别名ID和device_token是一对多的映射关系
  static Future<void> addAlias(String type, String alias) =>
      UmengAnalyticsWithPushPlatform.instance.addAlias(type, alias);

  /// 移除别名
  static Future<void> removeAlias(String type, String alias) =>
      UmengAnalyticsWithPushPlatform.instance.removeAlias(type, alias);

  /// 添加标签
  ///
  /// 示例：将“标签1”、“标签2”绑定至该设备
  ///
  /// ```dart
  ///
  /// UmengAnalysisWithPush.addTags(['标签1', '标签2']);
  ///
  /// ```
  static Future<void> addTags(List<String> tags) =>
      UmengAnalyticsWithPushPlatform.instance.addTags(tags);

  ///获取服务器端的所有标签
  static Future<List<String>> getTags() =>
      UmengAnalyticsWithPushPlatform.instance.getTags();

  /// 删除标签
  ///
  /// 将之前添加的标签中的一个或多个删除
  static Future<void> removeTags(List<String> tags) =>
      UmengAnalyticsWithPushPlatform.instance.removeTags(tags);
}

class UmengDeviceType {
  static const box = UmengDeviceType._("box");
  static const phone = UmengDeviceType._("phone");

  const UmengDeviceType._(this.name);

  final String name;
}