
import 'barikoi_trace_sdk_flutter_platform_interface.dart';

class BarikoiTraceSdkFlutter {
  Future<String?> getPlatformVersion() {
    return BarikoiTraceSdkFlutterPlatform.instance.getPlatformVersion();
  }
}
