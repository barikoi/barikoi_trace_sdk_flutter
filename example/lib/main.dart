import 'package:flutter/material.dart';
import 'dart:async';

import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final platform = BarikoiTraceSdkFlutterAndroid();

  /// method 1
  // platform.initialize(apiKey: "BARIKOI_API_KEY");
  // BarikoiTraceSdkFlutter(sdkPlatform: platform);

  final sdk = BarikoiTraceSdkFlutter(sdkPlatform: platform);

  sdk.initializeSdk(apiKey: "MjA1NDo4MjBSTUxLTEs5");

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    setOrCreateUser();
  }

  Future<void> setOrCreateUser() async {
    BarikoiTraceSdkFlutter.instance
        .setOrCreateUser(name: 'sakib 4', phone: '01676529696');
  }

  Future<void> startTracing() async {
    BarikoiTraceSdkFlutter.instance
        .startTracking(tag: "test", updateInterval: 15, accuracyfilter: 100);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              const Text('Running on: '),
              ElevatedButton(
                  onPressed: () {
                    setOrCreateUser();
                  },
                  child: const Text("set user")),
              ElevatedButton(
                  onPressed: () {
                    startTracing();
                  },
                  child: const Text("Start Trace")),
              ElevatedButton(
                  onPressed: () {
                    BarikoiTraceSdkFlutter.instance.stopTracking(
                      onError: (errorCode, errorMessage) {
                        print("errorMessage");
                        print(errorMessage);
                      },
                      onSuccess: (userid) {
                        print("userid");
                        print(userid);
                      },
                    );
                  },
                  child: const Text("Stop Trace")),
              Divider(),
              ElevatedButton(
                  onPressed: () {
                    BarikoiTraceSdkFlutter.instance.startTrip(
                      accuracyfilter: 100,
                      distaceInterval: 1,
                      tag: "test 2",
                      updateInterval: 15,
                      onError: (errorCode, errorMessage) {
                        print("errorMessage");
                        print(errorMessage);
                      },
                      onSuccess: (userid) {
                        print("userid");
                        print(userid);
                      },
                    );
                  },
                  child: const Text("Start Trip")),
              ElevatedButton(
                  onPressed: () {
                    BarikoiTraceSdkFlutter.instance.endTrip(
                      onError: (errorCode, errorMessage) {
                        print("errorMessage");
                        print(errorMessage);
                        print(errorCode);
                      },
                      onSuccess: (userid) {
                        print("userid");
                        print(userid);
                      },
                    );
                  },
                  child: const Text("Stop Trip")),
            ],
          ),
        ),
      ),
    );
  }
}
