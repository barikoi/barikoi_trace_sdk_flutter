# barikoi_trace_sdk_flutter_android

## Getting Started

To include the library in your project, add the following to your `pubspec.yaml` file:

``` yaml
dependencies:
  barikoi_trace_sdk_flutter: 
    git: url:https://github.com/barikoi/barikoi_trace_sdk_flutter.git
    ref: master
```

in your android project add the following to your project level `build.gradle` file:

``` gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        // Add the following line for the Trace library
        maven { url 'https://jitpack.io' }
    }
}
```

add those following permissions to your `AndroidManifest.xml` file:

``` xml  

<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

```