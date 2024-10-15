import 'package:barikoi_trace_sdk_flutter_android/barikoi_trace_sdk_flutter_android.dart';
import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BarikoiTraceSdkFlutterAndroid', () {
    const kPlatformName = 'Android';
    late BarikoiTraceSdkFlutterAndroid barikoiTraceSdkFlutter;
    late List<MethodCall> log;

    setUp(() async {
      barikoiTraceSdkFlutter = BarikoiTraceSdkFlutterAndroid();

      log = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(barikoiTraceSdkFlutter.methodChannel,
              (methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'getPlatformName':
            return kPlatformName;
          default:
            return null;
        }
      });
    });

    test('can be registered', () {
      BarikoiTraceSdkFlutterAndroid.registerWith();
      expect(BarikoiTraceSdkFlutterPlatform.instance,
          isA<BarikoiTraceSdkFlutterAndroid>());
    });

    test('getPlatformName returns correct name', () async {
      final name = await barikoiTraceSdkFlutter.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(name, equals(kPlatformName));
    });
  });
}
