# barikoi_trace_sdk_flutter

A  Flutter plugin that allows you to integrate Barikoi trace functionality into your Flutter applications.


## Getting Started

To include the library in your project, add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  barikoi_trace_sdk_flutter: 
    git: 
      url: https://github.com/barikoi/barikoi_trace_sdk_flutter.git
    ref: master
```

in your android project add the following to your project level `build.gradle` file:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        // Add the following line for the Trace library
        maven { url 'https://jitpack.io' }
    }
}
```

To use the plugin, use the following code in dart file:

```dart
// to immport the package
import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter.dart';

// to initialize the plugin
final _barikoiTrace = BarikoiTraceSdkFlutter();
await _barikoiTrace.initialize(apiKey: "BARIKOI_API_KEY_HERE");

// to set the user with phone, email and name 
_barikoiTrace.setOrCreateUser(name: 'sakib 4', phone: 'PHONE_NUMBER',
    onSuccess: (userid){
      Fluttertoast.showToast( msg:"user id: $userid");
    }, onError: (errorCode,errorMessage){
      Fluttertoast.showToast( msg:"Error: $errorCode, $errorMessage");
  });

// to start tracking 
_barikoiTrace.startTracking(tag: "test", updateInterval: 15, accuracyfilter: 100).then((value) {
      Fluttertoast.showToast(msg: "suscessfully started");
    }).catchError((error){
      Fluttertoast.showToast(msg: error.toString());
    });

//to stop tracking 
await _barikoiTrace.stopTracking();

// to start a trip and get the rip id
if( await Permission.location.request().isGranted) { // check if location permission is granted, here used permission_handler, you can user any package for permission management
    if(await Permission.notification.request().isGranted) { //check if notification permission is granted
        _barikoiTrace.startTrip(tag: "test", // tag for the trip, optional
            updateInterval: 15, // update interval in seconds
            accuracyfilter: 100, // accuracy filtering for location update in meters
            onSuccess: (tripid) { // get the trip id
              Fluttertoast.showToast( msg:"Trip id: $tripid");
            },
            onError: (errorCode, errorMessage) {
              Fluttertoast.showToast( msg: "Error: $errorCode, $errorMessage");
            });
    } else Fluttertoast.showToast( msg:"Notification permission not granted");
}else Fluttertoast.showToast( msg:"Location permission not granted");


// to end a trip
_barikoiTraceSdkFlutterPlugin.endTrip(onSuccess:(tripid){
    Fluttertoast.showToast( msg:"ended Trip id: $tripid");
  }, onError: (errorCode,errorMessage){
    Fluttertoast.showToast( msg:"Error: $errorCode, $errorMessage");
});
```


