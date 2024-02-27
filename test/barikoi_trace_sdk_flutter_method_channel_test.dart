import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelBarikoiTraceSdkFlutter platform = MethodChannelBarikoiTraceSdkFlutter();
  const MethodChannel channel = MethodChannel('barikoi_trace_sdk_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
