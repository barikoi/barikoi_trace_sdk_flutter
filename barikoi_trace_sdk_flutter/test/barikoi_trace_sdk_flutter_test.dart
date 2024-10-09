import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter.dart';
import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBarikoiTraceSdkFlutterPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements BarikoiTraceSdkFlutterPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BarikoiTraceSdkFlutter', () {
    late BarikoiTraceSdkFlutterPlatform barikoiTraceSdkFlutterPlatform;

    setUp(() {
      barikoiTraceSdkFlutterPlatform = MockBarikoiTraceSdkFlutterPlatform();
      BarikoiTraceSdkFlutterPlatform.instance = barikoiTraceSdkFlutterPlatform;
    });

    /*group('getPlatformName', () {
      test('returns correct name when platform implementation exists',
          () async {
        const platformName = '__test_platform__';
        when(
          () => barikoiTraceSdkFlutterPlatform.getPlatformName(),
        ).thenAnswer((_) async => platformName);

        final actualPlatformName = await getPlatformName();
        expect(actualPlatformName, equals(platformName));
      });

      test('throws exception when platform implementation is missing',
          () async {
        when(
          () => barikoiTraceSdkFlutterPlatform.getPlatformName(),
        ).thenAnswer((_) async => null);

        expect(getPlatformName, throwsException);
      });
    });*/
  });
}
