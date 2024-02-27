import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _barikoiTraceSdkFlutterPlugin = BarikoiTraceSdkFlutter();

  @override
  void initState() {
    super.initState();
    initBarikoiTrace();
  }

  Future<void> initBarikoiTrace() async {
    await _barikoiTraceSdkFlutterPlugin.initialize(apiKey: "Barikoi_api");
  }

  Future<void> setOrCreateUser() async {
    await _barikoiTraceSdkFlutterPlugin.setOrCreateUser(name: 'sakib 4', phone: '01676529696');
  }

  Future<void> startTracing() async {
    await _barikoiTraceSdkFlutterPlugin.startTracking(tag: "test");
  }

  Future<void> stopTracing() async {
    await _barikoiTraceSdkFlutterPlugin.stopTracking();
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
              ElevatedButton(onPressed: (){
                setOrCreateUser();
              }, child: const Text("set user")),
              ElevatedButton(onPressed: (){
                startTracing();
              }, child: const Text("Start Trace")),
              ElevatedButton(onPressed: (){
                stopTracing();
              }, child: const Text("Stop Trace")),
            ],
          ),
        ),
      ),
    );
  }
}
