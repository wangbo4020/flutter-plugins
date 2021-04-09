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
            RaisedButton(
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
            RaisedButton(
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
            RaisedButton(
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
            RaisedButton(
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
            RaisedButton(
              onPressed: () async {
                await UmengAnalyticsWithPush.addAlias("token", "flutter");
                print("addAlias ok");
              },
              child: Text("AddAlias type=\"token\", alias=\"flutter\""),
            ),
            RaisedButton(
              onPressed: () async {
                await UmengAnalyticsWithPush.putAlias("token", "flutter");
                print("putAlias ok");
              },
              child: Text("PutAlias type=\"token\", alias=\"flutter\""),
            ),
            RaisedButton(
              onPressed: () async {
                await UmengAnalyticsWithPush.removeAlias("token", "flutter");
                print("removeAlias ok");
              },
              child: Text("RemoveAlias type=\"token\", alias=\"flutter\""),
            ),
            RaisedButton(
              onPressed: () {
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
            RaisedButton(
              onPressed: () {
                UmengAnalyticsWithPush.addTags(
                    ["flutter_tag1", "flutter_tag2"]);
              },
              child: Text("AddTags \"flutter_tag1\", \"flutter_tag2\""),
            ),
            RaisedButton(
              onPressed: () {
                UmengAnalyticsWithPush.removeTags(
                    ["flutter_tag1", "flutter_tag2"]);
              },
              child: Text("RemoveTags \"flutter_tag1\", \"flutter_tag2\""),
            ),
            SizedBox(height: 16),
            if (_oaid != null) SelectableText("OAID: $_oaid"),
            SizedBox(height: 12),
            if (_utdid != null) SelectableText("UTDID: $_utdid"),
            SizedBox(height: 12),
            if (_devToken != null) SelectableText("DeviceToken: $_devToken"),
            SizedBox(height: 12),
            if (_tags != null) SelectableText("Tags: $_tags"),
          ],
        ),
      ),
    );
  }
}
