import Flutter
import UIKit

public class SwiftUmengAnalyticsWithPushPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "umeng_analytics_with_push", binaryMessenger: registrar.messenger())
    let instance = SwiftUmengAnalyticsWithPushPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
