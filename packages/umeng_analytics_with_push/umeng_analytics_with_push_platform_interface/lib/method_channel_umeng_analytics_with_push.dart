import 'package:flutter/services.dart';

import 'umeng_analytics_with_push_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('com.auwx.plugins/umeng_analytics_with_push');

/// An implementation of [UmengAnalyticsWithPushPlatform] that uses method channels.
class MethodChannelUmengAnalyticsWithPush
    extends UmengAnalyticsWithPushPlatform {
  @override
  Future<void> initialize({
    String? type,
    bool? catchUncaughtExceptions,
  }) {
    return _channel.invokeMethod("initialize", {
      "device-type": type,
      "catch-uncaught-exceptions": catchUncaughtExceptions,
    });
  }

  @override
  Future<Map<String, String?>?> get testDeviceInfo =>
      _channel.invokeMethod<Map<String, String?>?>("getTestDeviceInfo");

  @override
  Future<String?> get oaid => _channel.invokeMethod("oaid");

  @override
  Future<String?> get utdid => _channel.invokeMethod("utdid");

  @override
  Future<void> onEvent(String event, [dynamic? params, int? counter]) {
    return _channel.invokeMethod("onEvent", {
      "event": event,
      "params": params,
      "counter": counter,
    });
  }

  @override
  Future<void> onPageStart(String page) {
    return _channel.invokeMethod("onPageStart", page);
  }

  @override
  Future<void> onPageEnd(String page) {
    return _channel.invokeMethod("onPageEnd", page);
  }

  @override
  Future<void> onPageChanged(String page) {
    return _channel.invokeMethod("onPageChanged", page);
  }

  @override
  Future<void> onProfileSignIn(String id, String provider) {
    return _channel.invokeMethod("onProfileSignIn", {
      "id": id,
      "provider": provider,
    });
  }

  @override
  Future<void> onProfileSignOut() {
    return _channel.invokeMethod("onProfileSignOut");
  }

  @override
  Future<String?> get deviceToken => _channel.invokeMethod("deviceToken");

  @override
  Future<void> putAlias(String type, String alias) {
    return _channel.invokeMethod("putPushAlias", {
      "alias-type": type,
      "alias-value": alias,
    });
  }

  @override
  Future<void> addAlias(String type, String alias) {
    return _channel.invokeMethod("addPushAlias", {
      "alias-type": type,
      "alias-value": alias,
    });
  }

  @override
  Future<void> removeAlias(String type, String alias) {
    return _channel.invokeMethod("removePushAlias", {
      "alias-type": type,
      "alias-value": alias,
    });
  }

  @override
  Future<void> addTags(List<String> tags) {
    return _channel.invokeMethod("addPushTags", tags);
  }

  @override
  Future<List<String>> getTags() {
    return _channel.invokeListMethod<String>("getPushTags").then((value) {
      return value ?? List<String>.empty(growable: false);
    });
  }

  @override
  Future<void> removeTags(List<String> tags) {
    return _channel.invokeMethod("removePushTags", tags);
  }
}
