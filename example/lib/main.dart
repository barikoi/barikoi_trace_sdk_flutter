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

  sdk.initializeSdk(apiKey: "BARIKOI_API_KEY");

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
  }

  Future<void> setOrCreateUser() async {
    BarikoiTraceSdkFlutter.instance
        .setOrCreateUser(name: 'sakib 4', phone: '01676529696');
  }

  Future<void> startTracing() async {
    BarikoiTraceSdkFlutter.instance
        .startTracking(tag: "test", updateInterval: 15, accuracyfilter: 100);
  }

  Future<void> stopTracing() async {
    BarikoiTraceSdkFlutter.instance.stopTracking();
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
                    stopTracing();
                  },
                  child: const Text("Stop Trace")),
            ],
          ),
        ),
      ),
    );
  }
}
