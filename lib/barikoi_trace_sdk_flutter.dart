
import 'package:flutter/services.dart';

class BarikoiTraceSdkFlutter {
  static const MethodChannel _channel = MethodChannel('barikoi_trace_sdk_flutter');
  Future<void> initialize({required String apiKey}) async {
    var arguments = {
      'apiKey': apiKey,
    };
    await _channel.invokeMethod('initialize',arguments);
  }

  setOrCreateUser({required String name,String? email, required String phone,   Function(String? userid)? onSuccess,   Function(String? errorCode,String? errorMessage)? onError }) async {
    var arguments = {
      'name': name,
      'email': email,
      'phone': phone
    };
    _channel.invokeMethod('setOrCreateUser',arguments).then((userid){
       onSuccess?.call(userid);
      }).onError((PlatformException error, stackTrace) {
      onError?.call(error.code,error.message);
    });
  }

  Future<void> startTracking({int? updateInterval, int? distaceInterval, int? accuracyfilter , String? tag}) async {
    var arguments = {
      'tag': tag,
      updateInterval: updateInterval,
      distaceInterval: distaceInterval,
      accuracyfilter: accuracyfilter
    };
    await _channel.invokeMethod('startTracking',arguments);
  }

  Future<void> stopTracking() async {
    await _channel.invokeMethod('endTracking');
  }

  startTrip({int? updateInterval, int? distaceInterval, int? accuracyfilter , String? tag,  required Function(String? tripid) onSuccess,  required Function(String? errorCode,String? errorMessage) onError }) async {
    var arguments = {
      'tag': tag,
      updateInterval: updateInterval,
      distaceInterval: distaceInterval,
      accuracyfilter: accuracyfilter
    };

      _channel.invokeMethod('startTrip',arguments).then((tripid){
       onSuccess(tripid);
      }).onError((PlatformException error, stackTrace) {
        onError(error.code,error.message);
      });
    }

  endTrip({ required Function(String? tripid) onSuccess,  required Function(String? errorCode,String? errorMessage) onError }) async {
       _channel.invokeMethod('endTrip').then((tripid){
       onSuccess(tripid);
      }).onError((PlatformException error, stackTrace) {
         onError(error.code,error.message);
       });
    }

  Future<String?> getUserId() async {
    final userId = await _channel.invokeMethod<String>('getUserId');
    return userId;
  }
}
