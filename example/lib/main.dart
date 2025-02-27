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
  final _barikoiTrace = BarikoiTraceSdkFlutter();

  @override
  void initState() {
    super.initState();
    initBarikoiTrace();
  }

  Future<void> initBarikoiTrace() async {
    await _barikoiTrace.initialize(apiKey: "BARIKOI_API_KEY");
  }

  Future<void> setOrCreateUser() async {
    _barikoiTrace.setOrCreateUser(name: 'sakib 4', phone: 'PHONE_NUMBER',
    onSuccess: (userid){
      Fluttertoast.showToast( msg:"user id: $userid");
      _barikoiTrace.syncTrip(onSuccess: (TripId){
        if(TripId != null) Fluttertoast.showToast( msg:"Synced Trip id: $TripId");
        else Fluttertoast.showToast( msg:"No trip to sync");
      }, onError: (errorCode,errorMessage){
        Fluttertoast.showToast( msg:"Error: $errorCode, $errorMessage");
      });
    }, onError: (errorCode,errorMessage){
      Fluttertoast.showToast( msg:"Error: $errorCode, $errorMessage");
    });
  }

  startTracing() async {
    // if( await Permission.location.request().isGranted) {
      if(await Permission.notification.request().isGranted) {
        _barikoiTrace.startTrip(tag: "test",
            updateInterval: 15,
            accuracyfilter: 100,
            onSuccess: (tripid) {
              Fluttertoast.showToast( msg:"tracking started");
            },
            onError: (errorCode, errorMessage) {
              Fluttertoast.showToast( msg: "Error: $errorCode, $errorMessage");
            });
      } else Fluttertoast.showToast( msg:"Notification permission not granted");
    // }else Fluttertoast.showToast( msg:"Location permission not granted");
  }

  stopTracing() async {
     _barikoiTrace.endTrip(
         onSuccess: (tripid) {
       Fluttertoast.showToast( msg:"tracking started");
     },
         onError: (errorCode, errorMessage) {
           Fluttertoast.showToast( msg: "Error: $errorCode, $errorMessage");
         });
  }

  synctrace() async {
    _barikoiTrace.syncTrip(onSuccess: (TripId){
      if(TripId != null) Fluttertoast.showToast( msg:"Synced Trip id: $TripId");
      else Fluttertoast.showToast( msg:"No trip to sync");
    }, onError: (errorCode,errorMessage){
      Fluttertoast.showToast( msg:"Error: $errorCode, $errorMessage");
    });
  }

  checkTrace() async {
    bool istrackingon= await _barikoiTrace.isLocationTracking();
    Fluttertoast.showToast( msg:"Tracking: $istrackingon");
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
              ElevatedButton(onPressed: (){
                checkTrace();
              }, child: const Text("check service")),
              ElevatedButton(onPressed: (){
                synctrace();
              }, child: const Text("Sync Trip "))
            ],
          ),
        ),
      ),
    );
  }
}
