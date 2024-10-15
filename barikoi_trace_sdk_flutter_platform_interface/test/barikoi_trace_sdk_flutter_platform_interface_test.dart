import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class BarikoiTraceSdkFlutterMock extends BarikoiTraceSdkFlutterPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

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
  Future<TraceUserResponse> setOrCreateUser(
      {String? name, String? email, required String phone,required String apiKey,}) {
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
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
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

  @override
  void intAndroidSdk(String apiKey) {
    // TODO: implement intAndroidSdk
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('BarikoiTraceSdkFlutterPlatformInterface', () {
    late BarikoiTraceSdkFlutterPlatform barikoiTraceSdkFlutterPlatform;

    setUp(() {
      barikoiTraceSdkFlutterPlatform = BarikoiTraceSdkFlutterMock();
      BarikoiTraceSdkFlutterPlatform.instance = barikoiTraceSdkFlutterPlatform;
    });

    group('getPlatformName', () {
      test('returns correct name', () async {
        expect(
          await BarikoiTraceSdkFlutterPlatform.instance.getPlatformName(),
          equals(BarikoiTraceSdkFlutterMock.mockPlatformName),
        );
      });
    });
  });
}
