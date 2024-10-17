import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The iOS implementation of [BarikoiTraceSdkFlutterPlatform].
class BarikoiTraceSdkFlutterIOS extends BarikoiTraceSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('barikoi_trace_sdk_flutter_ios');

  /// Registers this class as the default instance of [BarikoiTraceSdkFlutterPlatform]
  static void registerWith() {
    BarikoiTraceSdkFlutterPlatform.instance = BarikoiTraceSdkFlutterIOS();
  }

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<String?> endTrip({
    required String userId,
    required String apiKey,
  }) async {
    await methodChannel.invokeMethod('endTrip', {
      'userId': userId,
      'apiKey': apiKey,
    });
    return "1";
  }

  @override
  Future<String?> getUserId() {
    // TODO: implement getUserId
    throw UnimplementedError();
  }

  @override
  Future<TraceUserResponse> setOrCreateUser({
    required String phone,
    required String apiKey,
    String? name,
    String? email,
  }) async {
    final user = await methodChannel.invokeMethod('getOrCreateUser', {
      'phoneNumber': phone,
      'apiKey': apiKey,
    });
    return TraceUserResponse.fromJson({
      'user': {
        '_id': user['user']['_id'],
      },
    });
  }

  @override
  Future<void> startTracking(
      {required String userId,
      required String apiKey,
      int? updateInterval,
      int? distanceInterval,
      int? accuracyFilter,
      String? tag}) async {
    await methodChannel.invokeMethod<String>('startTracking', {
      'userId': userId,
      'apiKey': apiKey,
    });
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
    await methodChannel.invokeMethod('startTrip', {
      'tag': tag,
      'user_id': userId,
      'apiKey': apiKey,
    });
    return "";
  }

  @override
  Future<void> stopTracking() async {
    await methodChannel.invokeMethod('stopTracking');
  }

  @override
  Future<String?> createTrip({
    required String userId,
    required String apiKey,
    String? fieldForceId,
  }) async {
    final trip = await methodChannel.invokeMethod('createTrip', {
      'userId': userId,
      'fieldForceId': fieldForceId ?? userId,
      'apiKey': apiKey,
    });
    return trip['_id'] as String;
  }

  @override
  void intAndroidSdk(String apiKey) {
    // TODO: implement intAndroidSdk
  }

  @override
  Future<dynamic> getCurrentTrip({
    required String apiKey,
    required String userId,
  }) async {
    final trip = await methodChannel.invokeMethod('getCurrentTrip', {
      'apiKey': apiKey,
      'userId': userId,
    });
    return trip;
  }
}
