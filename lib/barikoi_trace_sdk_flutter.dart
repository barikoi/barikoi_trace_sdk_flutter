
import 'package:flutter/services.dart';

class BarikoiTraceSdkFlutter {
  static const MethodChannel _channel = MethodChannel('barikoi_trace_sdk_flutter');
  Future<void> initialize({required String apiKey}) async {
    var arguments = {
      'apiKey': apiKey,
    };
    await _channel.invokeMethod('initialize',arguments);
  }

  Future<void> setOrCreateUser({required String name,String? email, required String phone}) async {
    var arguments = {
      'name': name,
      'email': email,
      'phone': phone
    };
    await _channel.invokeMethod('setOrCreateUser',arguments);
  }

  Future<void> startTracking({int? updateInterval, int? distaceInterval, int? accuracyfilter , String? tag}) async {
    var arguments = {
      'tag': tag,
      updateInterval: updateInterval,
      distaceInterval: distaceInterval,
      accuracyfilter: accuracyfilter
    };
    await _channel.invokeMethod('startTracking',arguments);
  }

  Future<void> stopTracking() async {
    await _channel.invokeMethod('endTracking');
  }

  // Future<bool?> isLocationPermissionsGranted() async {
  //   return BarikoiTraceSdkFlutterPlatform.instance.isLocationPermissionsGranted();
  // }
}
