import 'package:barikoi_trace_sdk_flutter_platform_interface/src/method_channel_barikoi_trace_sdk_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kPlatformName = 'platformName';

  group('$MethodChannelBarikoiTraceSdkFlutter', () {
    late MethodChannelBarikoiTraceSdkFlutter methodChannelBarikoiTraceSdkFlutter;
    final log = <MethodCall>[];

    setUp(() async {
      methodChannelBarikoiTraceSdkFlutter = MethodChannelBarikoiTraceSdkFlutter();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        methodChannelBarikoiTraceSdkFlutter.methodChannel,
        (methodCall) async {
          log.add(methodCall);
          switch (methodCall.method) {
            case 'getPlatformName':
              return kPlatformName;
            default:
              return null;
          }
        },
      );
    });

    tearDown(log.clear);

    test('getPlatformName', () async {
      final platformName = await methodChannelBarikoiTraceSdkFlutter.getPlatformName();
      expect(
        log,
        <Matcher>[isMethodCall('getPlatformName', arguments: null)],
      );
      expect(platformName, equals(kPlatformName));
    });
  });
}
