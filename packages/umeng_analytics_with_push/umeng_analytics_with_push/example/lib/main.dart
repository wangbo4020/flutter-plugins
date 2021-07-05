import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:umeng_analytics_with_push/umeng_analytics_with_push.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized;
  dynamic _errorOnInit;

  String _oaid;
  String _utdid;
  String _devToken;
  String _tags;

  bool get _hasDeviceToken => _devToken != null && _devToken != "Getting";

  @override
  void initState() {
    super.initState();
    _initialized = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [UmengAnalyticsObserver(log: !kReleaseMode)],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          children: [
            ElevatedButton(
              onPressed: _initialized
                  ? null
                  : () {
                      UmengAnalyticsWithPush.initialize().then((_) {
                        setState(() {
                          _initialized = true;
                        });
                      }).catchError((e, s) {
                        setState(() {
                          _errorOnInit = e;
                        });
                      });
                    },
              child: Text("Init"),
            ),
            ElevatedButton(
              onPressed: () {
                UmengAnalyticsWithPush.oaid.then((oaid) {
                  setState(() {
                    _oaid = oaid ?? "null";
                  });
                }).catchError((e, s) {
                  setState(() {
                    _oaid = e.toString();
                  });
                });
              },
              child: Text("Got OAID"),
            ),
            ElevatedButton(
              onPressed: () {
                UmengAnalyticsWithPush.utdid.then((utdid) {
                  setState(() {
                    _utdid = utdid ?? "null";
                  });
                }).catchError((e, s) {
                  setState(() {
                    _utdid = e.toString();
                  });
                });
              },
              child: Text("Got UtdId"),
            ),
            ElevatedButton(
              onPressed: !_initialized
                  ? null
                  : () {
                      setState(() {
                        _devToken = "Getting";
                      });
                      UmengAnalyticsWithPush.deviceToken.then((dt) {
                        print("deviceToken: $dt");
                        setState(() {
                          _devToken = dt ?? "null";
                        });
                      }).catchError((e, s) {
                        print("deviceToken: $e" + (s != null ? "\n$s" : ""));
                        setState(() {
                          _devToken = e.toString();
                        });
                      });
                    },
              child: Text("Got DeviceToken"),
            ),
            ElevatedButton(
              onPressed: !_hasDeviceToken
                  ? null
                  : () async {
                      await UmengAnalyticsWithPush.addAlias("token", "flutter");
                      print("addAlias ok");
                    },
              child: Text("AddAlias type=\"token\", alias=\"flutter\""),
            ),
            ElevatedButton(
              onPressed: !_hasDeviceToken
                  ? null
                  : () async {
                      await UmengAnalyticsWithPush.putAlias("token", "flutter");
                      print("putAlias ok");
                    },
              child: Text("PutAlias type=\"token\", alias=\"flutter\""),
            ),
            ElevatedButton(
              onPressed: !_hasDeviceToken
                  ? null
                  : () async {
                      await UmengAnalyticsWithPush.removeAlias(
                          "token", "flutter");
                      print("removeAlias ok");
                    },
              child: Text("RemoveAlias type=\"token\", alias=\"flutter\""),
            ),
            ElevatedButton(
              onPressed: !_hasDeviceToken
                  ? null
                  : () {
                      UmengAnalyticsWithPush.getTags().then((tags) {
                        print("getTags: $tags");
                        setState(() {
                          _tags = tags?.join(", ") ?? "null";
                        });
                      }).catchError((e, s) {
                        print("getTags: $e" + (s != null ? "\n$s" : ""));
                        setState(() {
                          _tags = e.toString();
                        });
                      });
                    },
              child: Text("getTags \"flutter_tag1\", \"flutter_tag2\""),
            ),
            ElevatedButton(
              onPressed: !_hasDeviceToken
                  ? null
                  : () {
                      UmengAnalyticsWithPush.addTags(
                          ["flutter_tag1", "flutter_tag2"]);
                    },
              child: Text("AddTags \"flutter_tag1\", \"flutter_tag2\""),
            ),
            ElevatedButton(
              onPressed: !_hasDeviceToken
                  ? null
                  : () {
                      UmengAnalyticsWithPush.removeTags(
                          ["flutter_tag1", "flutter_tag2"]);
                    },
              child: Text("RemoveTags \"flutter_tag1\", \"flutter_tag2\""),
            ),
            SizedBox(height: 16),
            Text(_initialized ? "Initialized!" : "Please click Init"),
            if (_oaid != null) SizedBox(height: 12),
            if (_oaid != null) SelectableText("OAID: $_oaid"),
            if (_utdid != null) SizedBox(height: 12),
            if (_utdid != null) SelectableText("UTDID: $_utdid"),
            SizedBox(height: 12),
            SelectableText(_devToken == null
                ? "Please click Got DeviceToken"
                : "DeviceToken: $_devToken"),
            SizedBox(height: 12),
            if (_tags != null) SelectableText("Tags: $_tags"),
          ],
        ),
      ),
    );
  }
}
