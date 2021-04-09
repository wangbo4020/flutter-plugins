// part of umeng_analysis_with_push;

import 'package:flutter/widgets.dart';
import 'package:umeng_analytics_with_push_platform_interface/umeng_analytics_with_push_platform_interface.dart';

/// Signature for a function that extracts a screen name from [RouteSettings].
///
/// Usually, the route name is not a plain string, and it may contains some
/// unique ids that makes it difficult to aggregate over them in Umeng
/// Analytics.
typedef String? ScreenNameExtractor(RouteSettings settings);

String? defaultNameExtractor(RouteSettings settings) => settings.name;

/// A [NavigatorObserver] that sends events to Umeng Analytics when the
/// currently active [PageRoute] changes.
///
/// When a route is pushed or popped, [nameExtractor] is used to extract a name
/// from [RouteSettings] of the now active route and that name is sent to Umeng.
///
/// The following operations will result in sending a screen view event:
/// ```dart
/// Navigator.pushNamed(context, '/contact/123');
///
/// Navigator.push<void>(context, MaterialPageRoute(
///   settings: RouteSettings(name: '/contact/123'),
///   builder: (_) => ContactDetail(123)));
///
/// Navigator.pushReplacement<void>(context, MaterialPageRoute(
///   settings: RouteSettings(name: '/contact/123'),
///   builder: (_) => ContactDetail(123)));
///
/// Navigator.pop(context);
/// ```
///
/// To use it, add it to the `navigatorObservers` of your [Navigator], e.g. if
/// you're using a [MaterialApp]:
/// ```dart
/// MaterialApp(
///   home: MyAppHome(),
///   navigatorObservers: [
///     UmengAnalyticsObserver(),
///   ],
/// );
/// ```
///
/// You can also track screen views within your [PageRoute] by implementing
/// [PageRouteAware] and subscribing it to [UmengAnalyticsObserver]. See the
/// [PageRouteObserver] docs for an example.
class UmengAnalyticsObserver extends RouteObserver<PageRoute<dynamic>> {
  UmengAnalyticsObserver({
    this.log = false,
    this.nameExtractor = defaultNameExtractor,
  });

  final bool log;
  final ScreenNameExtractor nameExtractor;

  void _sendScreenView(PageRoute<dynamic> route) {
    final String? screenName = nameExtractor(route.settings);
    if (screenName != null) {
      UmengAnalyticsWithPushPlatform.instance.onPageChanged(screenName);
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
