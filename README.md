# barikoi_trace_sdk_flutter

A  Flutter plugin that allows you to integrate Barikoi trace functionality into your Flutter applications.


## Getting Started

To include the library in your project, add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  barikoi_trace_sdk_flutter: 
    git: url:https://github.com/barikoi/barikoi_trace_sdk_flutter.git
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
 await _barikoiTrace.initialize(apiKey: "BARIKOI_API_KEY_HERE");

// to set the user with phone, email and name 
await _barikoiTrace.setOrCreateUser(name: 'sakib 4', phone: '02898138757405947942531335326' )
    .then((value) { 
      Fluttertoast.showToast(msg: "suscessfully set user");
    }).catchError((error){
    // Handle error
      Fluttertoast.showToast(msg: error.toString());
    });

// to start tracking 
_barikoiTrace.startTracking(tag: "test", updateInterval: 15, accuracyfilter: 100).then((value) {
      Fluttertoast.showToast(msg: "suscessfully started");
    }).catchError((error){
      Fluttertoast.showToast(msg: error.toString());
    });

//to stop tracking 
await _barikoiTrace.stopTracking();
```


