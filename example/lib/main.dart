import 'package:flutter/material.dart';
import 'dart:async';
import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

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
    await _barikoiTraceSdkFlutterPlugin.initialize(apiKey: "BARIKOI_API_KEY");
  }

  Future<void> setOrCreateUser() async {
    _barikoiTraceSdkFlutterPlugin.setOrCreateUser(name: 'sakib 4', phone: 'PHONE_NUMBER',
    onSuccess: (userid){
      Fluttertoast.showToast( msg:"user id: $userid");
    }, onError: (errorCode,errorMessage){
      Fluttertoast.showToast( msg:"Error: $errorCode, $errorMessage");
    });
  }

  startTracing() async {
    if( await Permission.location.request().isGranted) {
      if(await Permission.notification.request().isGranted) {
        _barikoiTraceSdkFlutterPlugin.startTrip(tag: "test",
            updateInterval: 15,
            accuracyfilter: 100,
            onSuccess: (tripid) {
              Fluttertoast.showToast( msg:"Trip id: $tripid");
            },
            onError: (errorCode, errorMessage) {
              Fluttertoast.showToast( msg: "Error: $errorCode, $errorMessage");
            });
      } else Fluttertoast.showToast( msg:"Notification permission not granted");
    }else Fluttertoast.showToast( msg:"Location permission not granted");
  }

  stopTracing() async {
     _barikoiTraceSdkFlutterPlugin.endTrip(onSuccess:(tripid){
       Fluttertoast.showToast( msg:"ended Trip id: $tripid");
    }, onError: (errorCode,errorMessage){
       Fluttertoast.showToast( msg:"Error: $errorCode, $errorMessage");
    });
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
