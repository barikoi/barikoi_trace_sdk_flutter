# barikoi_trace_sdk_flutter_ios

## iOS Setup Guide

Follow these steps to set up the necessary configurations for using this plugin on iOS.

### 1. Permissions Setup in `Info.plist`

To request location access, you need to add the following keys to your iOS project's `Info.plist`
file. This file is located in `ios/Runner/Info.plist`.

Add these permission keys to request location access both in the foreground and in the background:

``` xml

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track your trips.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>We need your location even when the app is in the background.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to provide real-time trip updates.</string>

```

Additionally, enable background location updates by adding this key:

``` xml

<key>UIBackgroundModes</key>
<array>
        <string>location</string>
</array>

```

> [!WARNING]  
> Make sure your app has a user-facing feature that justifies background location tracking; otherwise, the App Store may reject the app. 
