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
  Future<String?> endTrip() {
    // TODO: implement endTrip
    throw UnimplementedError();
  }

  @override
  Future<String?> getUserId() {
    // TODO: implement getUserId
    throw UnimplementedError();
  }

  @override
  Future<TraceUserResponse> setOrCreateUser({
    String? name,
    String? email,
    required String phone,
    required String apiKey,
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
      {int? updateInterval,
      int? distaceInterval,
      int? accuracyfilter,
      String? tag,
      required String userId,
      required String apiKey}) async {
    await methodChannel.invokeMethod<String>('startTracking', {
      'userId': userId,
      'apiKey': apiKey,
    });
  }

  @override
  Future<String?> startTrip({
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
  }) {
    // TODO: implement startTrip
    throw UnimplementedError();
  }

  @override
  Future<void> stopTracking() async {
    await methodChannel.invokeMethod('stopTracking');
  }
}
