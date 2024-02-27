import 'package:flutter_test/flutter_test.dart';
import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:barikoi_trace_sdk_flutter/barikoi_trace_sdk_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBarikoiTraceSdkFlutterPlatform
    with MockPlatformInterfaceMixin
    implements BarikoiTraceSdkFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> getUser() {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<String?> getUserId() {
    // TODO: implement getUserId
    throw UnimplementedError();
  }

  @override
  void initialize({required String apiKey}) {
    // TODO: implement initialize
  }

  @override
  Future<bool> isLocationPermissionsGranted() {
    // TODO: implement isLocationPermissionsGranted
    throw UnimplementedError();
  }

  @override
  Future<bool> isLocationSettingsOn() {
    // TODO: implement isLocationSettingsOn
    throw UnimplementedError();
  }

  @override
  void setOrCreateUser({required String name,String? email, required String phone}) {
    // TODO: implement setOrCreateUser
  }

  @override
  void endTracking() {
    // TODO: implement endTracking
  }

  @override
  void startTracking({required String tag}) {
    // TODO: implement starTracking
  }
}

void main() {
  final BarikoiTraceSdkFlutterPlatform initialPlatform = BarikoiTraceSdkFlutterPlatform.instance;

  test('$MethodChannelBarikoiTraceSdkFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBarikoiTraceSdkFlutter>());
  });

  // test('getPlatformVersion', () async {
  //   BarikoiTraceSdkFlutter barikoiTraceSdkFlutterPlugin = BarikoiTraceSdkFlutter();
  //   MockBarikoiTraceSdkFlutterPlatform fakePlatform = MockBarikoiTraceSdkFlutterPlatform();
  //   BarikoiTraceSdkFlutterPlatform.instance = fakePlatform;
  //
  //   expect(await barikoiTraceSdkFlutterPlugin.getPlatformVersion(), '42');
  // });
}
