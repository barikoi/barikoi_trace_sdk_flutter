import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// An implementation of [BarikoiTraceSdkFlutterPlatform] that uses method channels.
class MethodChannelBarikoiTraceSdkFlutter
    extends BarikoiTraceSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('barikoi_trace_sdk_flutter');

  @override
  Future<String?> getPlatformName() {
    return methodChannel.invokeMethod<String>('getPlatformName');
  }

  @override
  Future<String?> endTrip({
    required String tripId,
    required String apiKey,
    String? fieldforceId,
  }) {
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
  }) {
    // TODO: implement setOrCreateUser
    throw UnimplementedError();
  }

  @override
  Future<void> startTracking(
      {int? updateInterval,
      int? distaceInterval,
      int? accuracyfilter,
      String? tag,
      required String userId,
      required String apiKey}) {
    // TODO: implement startTracking
    throw UnimplementedError();
  }

  @override
  Future<String?> startTrip({
    required String tripId,
    required String apiKey,
    String? fieldforceId,
  }) {
    // TODO: implement startTrip
    throw UnimplementedError();
  }

  @override
  Future<void> stopTracking() {
    // TODO: implement stopTracking
    throw UnimplementedError();
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
}
