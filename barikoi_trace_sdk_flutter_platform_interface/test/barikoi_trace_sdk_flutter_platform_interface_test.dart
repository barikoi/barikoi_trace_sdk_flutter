import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class BarikoiTraceSdkFlutterMock extends BarikoiTraceSdkFlutterPlatform {
  static const mockPlatformName = 'Mock';

  @override
  Future<String?> getPlatformName() async => mockPlatformName;

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
  Future<void> setOrCreateUser(
      {required String name, String? email, required String phone}) {
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
  Future<String?> startTrip(
      {int? updateInterval,
      int? distaceInterval,
      int? accuracyfilter,
      String? tag}) {
    // TODO: implement startTrip
    throw UnimplementedError();
  }

  @override
  Future<void> stopTracking() {
    // TODO: implement stopTracking
    throw UnimplementedError();
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
