import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The Android implementation of [BarikoiTraceSdkFlutterPlatform].
class BarikoiTraceSdkFlutterAndroid extends BarikoiTraceSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel =
      const MethodChannel('barikoi_trace_sdk_flutter_android');

  /// Registers this class as the default instance of [BarikoiTraceSdkFlutterPlatform]
  static void registerWith() {
    BarikoiTraceSdkFlutterPlatform.instance = BarikoiTraceSdkFlutterAndroid();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  void intAndroidSdk(String apiKey) {
    methodChannel.invokeMethod('initialize', {
      'apiKey': apiKey,
    });
  }

  @override
  Future<String?> endTrip({
    required String userId,
    required String apiKey,
  }) async {
    return methodChannel.invokeMethod('endTrip');
  }

  @override
  Future<String?> getUserId() async {
    return methodChannel.invokeMethod<String>('getUserId');
  }

  @override
  Future<TraceUserResponse> setOrCreateUser({
    required String phone,
    required String apiKey,
    String? name,
    String? email,
  }) async {
    final arguments = {
      'name': name,
      'email': email,
      'phone': phone,
    };
    String? uid = '';
    try {
      await methodChannel.invokeMethod('setOrCreateUser', arguments);
    } on PlatformException catch (e) {
      debugPrint('User ID: $uid');
      debugPrint(e.toString());
    }
    uid = await methodChannel.invokeMethod<String>('getUserId');

    return TraceUserResponse(
      user: User(id: uid ?? '1'),
    );
  }

  @override
  Future<void> startTracking({
    required String userId,
    required String apiKey,
    int? updateInterval,
    int? distanceInterval,
    int? accuracyFilter,
    String? tag,
  }) async {
    final arguments = {
      'tag': tag,
      updateInterval: updateInterval,
      distanceInterval: distanceInterval,
      accuracyFilter: accuracyFilter,
    };
    await methodChannel.invokeMethod('startTracking', arguments);
  }

  @override
  Future<String?> startTrip({
    required String apiKey,
    required String userId,
    int? updateInterval,
    int? distanceInterval,
    int? accuracyFilter,
    String? tag,
  }) async {
    final arguments = {
      'tag': tag,
      'updateInterval': updateInterval,
      'distanceInterval': distanceInterval,
      'accuracyFilter': accuracyFilter,
    };
    return methodChannel.invokeMethod('startTrip', arguments);
  }

  @override
  Future<void> stopTracking() async {
    await methodChannel.invokeMethod('endTracking');
  }

  @override
  Future<String?> createTrip({
    required String userId,
    required String apiKey,
    String? fieldForceId,
  }) {
    // TODO: implement createTrip
    throw UnimplementedError();
  }

  @override
  Future<dynamic> getCurrentTrip({required String apiKey, required String userId}) {
    // TODO: implement getCurrentTrip
    throw UnimplementedError();
  }
}
