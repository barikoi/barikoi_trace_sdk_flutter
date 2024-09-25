import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'barikoi_trace_sdk_flutter_platform_interface.dart';

/// An implementation of [BarikoiTraceSdkFlutterPlatform] that uses method channels.
class MethodChannelBarikoiTraceSdkFlutter extends BarikoiTraceSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('barikoi_trace_sdk_flutter');


  @override
  Future<void> initialize({required String apiKey}) async {
    var arguments = {
      'apiKey': apiKey,
    };
    await methodChannel.invokeMethod('initialize',arguments);
  }

  @override
  Future<void> setOrCreateUser({required String name,String? email, required String phone}) async {
    var arguments = {
      'name': name,
      'email': email,
      'phone': phone
    };
    await methodChannel.invokeMethod('setOrCreateUser',arguments);
  }

  @override
  Future<String?> getUserId() async {
    final userId = await methodChannel.invokeMethod<String>('getUserId');
    return userId;
  }

  @override
  Future<String?> getUser() async {
    final user = await methodChannel.invokeMethod<String>('getUser');
    return user;
  }

  @override
  Future<bool?> isLocationPermissionsGranted() async {
    final isLocationPermissionsGranted = await methodChannel.invokeMethod<bool>('isLocationPermissionsGranted');
    return isLocationPermissionsGranted;
  }

  @override
  Future<bool?> isLocationSettingsOn() async {
    final isLocationSettingsOn = await methodChannel.invokeMethod<bool>('isLocationSettingsOn');
    return isLocationSettingsOn;
  }

  @override
  Future<void> endTracking() async {
    await methodChannel.invokeMethod('endTracking');
  }

  @override
  Future<void> startTracking({required String tag}) async {
    var arguments = {
      'tag': tag,
    };
    await methodChannel.invokeMethod('startTracking',arguments);
  }

}
