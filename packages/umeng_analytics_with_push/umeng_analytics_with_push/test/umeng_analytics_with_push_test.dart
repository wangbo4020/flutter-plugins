import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umeng_analytics_with_push/umeng_analytics_with_push.dart';

void main() {
  const MethodChannel channel = MethodChannel('umeng_analytics_with_push');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    await UmengAnalyticsWithPush.initialize();
  });
}
