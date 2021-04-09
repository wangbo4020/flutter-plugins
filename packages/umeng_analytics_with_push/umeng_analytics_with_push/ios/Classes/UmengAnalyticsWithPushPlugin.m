#import "UmengAnalyticsWithPushPlugin.h"
#if __has_include(<umeng_analytics_with_push/umeng_analytics_with_push-Swift.h>)
#import <umeng_analytics_with_push/umeng_analytics_with_push-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "umeng_analytics_with_push-Swift.h"
#endif

@implementation UmengAnalyticsWithPushPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUmengAnalyticsWithPushPlugin registerWithRegistrar:registrar];
}
@end
