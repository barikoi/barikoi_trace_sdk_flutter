
import 'barikoi_trace_sdk_flutter_platform_interface.dart';

class BarikoiTraceSdkFlutter {

  Future<void> initialize({required String apiKey}) async {
    return BarikoiTraceSdkFlutterPlatform.instance.initialize(apiKey: apiKey);
  }

  Future<void> setOrCreateUser({required String name,String? email, required String phone}) async {
    return BarikoiTraceSdkFlutterPlatform.instance.setOrCreateUser(name: name, phone: phone,email: email);
  }

  Future<void> startTracking({required String tag}) async {
    return BarikoiTraceSdkFlutterPlatform.instance.startTracking(tag: tag);
  }

  Future<void> stopTracking() async {
    return BarikoiTraceSdkFlutterPlatform.instance.endTracking();
  }

  Future<bool?> isLocationPermissionsGranted() async {
    return BarikoiTraceSdkFlutterPlatform.instance.isLocationPermissionsGranted();
  }
}
