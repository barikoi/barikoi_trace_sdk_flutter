import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'barikoi_trace_sdk_flutter_method_channel.dart';

abstract class BarikoiTraceSdkFlutterPlatform extends PlatformInterface {
  /// Constructs a BarikoiTraceSdkFlutterPlatform.
  BarikoiTraceSdkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BarikoiTraceSdkFlutterPlatform _instance = MethodChannelBarikoiTraceSdkFlutter();

  /// The default instance of [BarikoiTraceSdkFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelBarikoiTraceSdkFlutter].
  static BarikoiTraceSdkFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BarikoiTraceSdkFlutterPlatform] when
  /// they register themselves.
  static set instance(BarikoiTraceSdkFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
