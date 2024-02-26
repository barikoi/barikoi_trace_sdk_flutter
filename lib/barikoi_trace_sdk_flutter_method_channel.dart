import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barikoi_trace_sdk_flutter_platform_interface.dart';

/// An implementation of [BarikoiTraceSdkFlutterPlatform] that uses method channels.
class MethodChannelBarikoiTraceSdkFlutter extends BarikoiTraceSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('barikoi_trace_sdk_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
