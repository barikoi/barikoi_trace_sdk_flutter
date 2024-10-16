import 'dart:io' show Platform;

import 'package:barikoi_trace_sdk_flutter/kv.dart';
import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter/services.dart';

BarikoiTraceSdkFlutterPlatform get _platform =>
    BarikoiTraceSdkFlutterPlatform.instance;

/// Barikoi Trace SDK Flutter.
///
/// This class facilitates interaction with the Barikoi Trace SDK through a platform-specific implementation.
/// It is designed to be used as a singleton, ensuring that the SDK is initialized only once and can be accessed
/// globally throughout the application.
///
/// The class provides methods for initializing the SDK, managing user data, tracking location, and managing trips.
///
/// Usage:
/// ```dart
/// // Initialize the SDK
/// BarikoiTraceSdkFlutter sdk = BarikoiTraceSdkFlutter(sdkPlatform: BarikoiTraceSdkFlutterAndroid());
/// await sdk.initializeSdk(apiKey: 'YOUR_API_KEY');
///
/// // Set or create a user
/// await sdk.setOrCreateUser(name: 'John Doe', phone: '1234567890', onSuccess: (userId) {
///   print('User ID: $userId');
/// });
///
/// // Start tracking
/// await sdk.startTracking(updateInterval: 5, distanceInterval: 10);
///
/// // Begin a trip
/// await sdk.startTrip(updateInterval: 5, distanceInterval: 10, onSuccess: (tripId) {
///   print('Trip ID: $tripId');
/// });
/// ```
///
class BarikoiTraceSdkFlutter {
  // Static field to hold the single instance of the class
  static BarikoiTraceSdkFlutter? _instance;
  static String? _apiKey;

  BarikoiTraceSdkFlutter._({required String apiKey});

  factory BarikoiTraceSdkFlutter({required String apiKey}) {
    _apiKey = apiKey;
    _instance ??= BarikoiTraceSdkFlutter._(apiKey: apiKey);

    () async {
      final sharedPreferencesService = SharedPreferencesService();
      await sharedPreferencesService.init();
    }.call();
    // init android sdk
    if (Platform.isAndroid) {
      _platform.intAndroidSdk(apiKey);
    }
    // Return the singleton instance
    return _instance!;
  }

  // Static getter to access the singleton instance
  static BarikoiTraceSdkFlutter get instance {
    if (_instance == null) {
      throw Exception('SDK not initialized.');
    }
    return _instance!;
  }

  Future<void> startTracking({
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
  }) async {
    if (_apiKey == null) {
      throw Exception('SDK not initialized. API key is required.');
    }
    final userId = await getUserId();
    if (userId == null) {
      throw Exception(
        'User ID is null. Set or create a user before starting tracking.',
      );
    }
    await _platform.startTracking(userId: userId, apiKey: _apiKey!);
  }

  Future<void> stopTracking({
    void Function(String? userId)? onSuccess,
    void Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    if (_apiKey == null) {
      onError?.call('ERROR', 'SDK not initialized. API key is required.');
      throw Exception('SDK not initialized. API key is required.');
    }
    try {
      await _platform.stopTracking();
      onSuccess?.call(await getUserId());
    } catch (e) {
      onError?.call('ERROR', e.toString());
    }
  }

  Future<void> setOrCreateUser({
    required String name,
    required String phone,
    void Function(String? userId)? onSuccess,
    void Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    if (_apiKey == null) {
      onError?.call('ERROR', 'SDK not initialized. API key is required.');
      throw Exception('SDK not initialized. API key is required.');
    }
    try {
      final res = await _platform.setOrCreateUser(
        name: name,
        phone: phone,
        apiKey: _apiKey!,
      );
      final sharedPreferencesService = SharedPreferencesService();
      await sharedPreferencesService.setUserId(res.user.id);
      onSuccess?.call(res.user.id);
    } on PlatformException catch (e) {
      final errorCode = e.code;
      final errorMessage = e.message;
      onError?.call(errorCode, errorMessage);
    }
  }

  Future<String?> getUserId() async {
    final sharedPreferencesService = SharedPreferencesService();
    return sharedPreferencesService.getUserId();
  }

  Future<String?> getTripId() async {
    final sharedPreferencesService = SharedPreferencesService();
    return sharedPreferencesService.getTripId();
  }

  Future<String?> createTrip({
    required String userId,
    String? fieldForceId,
  }) async {
    if (_apiKey == null) {
      throw Exception('SDK not initialized. API key is required.');
    }
    final tripId = await _platform.createTrip(
      userId: userId,
      apiKey: _apiKey!,
      fieldForceId: fieldForceId,
    );

    return tripId;
  }

  Future<String?> startTrip({
    String? fieldforceId,
    int? updateInterval, // todo
    int? distaceInterval, // todo
    int? accuracyfilter, // todo
    String? tag,
    void Function(String? tripId)? onSuccess,
    void Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    if (_apiKey == null) {
      onError?.call('ERROR', 'SDK not initialized. API key is required.');
      throw Exception('SDK not initialized. API key is required.');
    }
    String? userId = '';
    String? tripId = '';

    if (Platform.isIOS) {
      userId = await getUserId();
      if (userId == null || userId.isEmpty) {
        onError?.call('ERROR',
            'User ID is null. Set or create a user before starting tracking.');
        throw Exception(
          'User ID is null. Set or create a user before starting tracking.',
        );
      }
      final tripId = await createTrip(
        userId: userId,
        fieldForceId: fieldforceId,
      );
      if (tripId == null || tripId.isEmpty) {
        onError?.call('ERROR', 'Trip ID is null. Start trip failed.');
        throw Exception('Trip ID is null. Start trip failed.');
      }
      final sharedPreferencesService = SharedPreferencesService();
      await sharedPreferencesService.setTripId(tripId);
      try {
        await startTracking(
          updateInterval: updateInterval,
          distaceInterval: distaceInterval,
          accuracyfilter: accuracyfilter,
          tag: tag,
        );
      } on PlatformException catch (e) {
        onError?.call(e.code, e.message);
      }
      try {
        await _platform.startTrip(
          tag: "test",
          apiKey: _apiKey!,
          userId: fieldforceId ?? userId,
          accuracyfilter: accuracyfilter,
          distaceInterval: distaceInterval,
          updateInterval: updateInterval,
        );
        onSuccess?.call(tripId);
        final sharedPreferencesService = SharedPreferencesService();
        await sharedPreferencesService.setTripId(tripId);
      } catch (e) {
        onError?.call('ERROR', e.toString());
      }
    }else{
      try {
        final tripIdAndroid = await _platform.startTrip(
          tag: "tag",
          apiKey: _apiKey!,
          userId: fieldforceId ?? userId,
          accuracyfilter: accuracyfilter,
          distaceInterval: distaceInterval,
          updateInterval: updateInterval,
        );
        onSuccess?.call(tripIdAndroid);
        final sharedPreferencesService = SharedPreferencesService();
        await sharedPreferencesService.setTripId(tripIdAndroid!);
      } catch (e) {
        onError?.call('ERROR', e.toString());
      }
    }

  }

  Future<void> endTrip({
    String? fieldforceId,
    void Function(String? tripId)? onSuccess,
    void Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    if (_apiKey == null) {
      throw Exception('SDK not initialized. API key is required.');
    }
    final tripId = await getTripId();
    if (tripId == null || tripId.isEmpty) {
      onError?.call('ERROR', 'Trip ID is null. End trip failed.');
      throw Exception('Trip ID is null. End trip failed.');
    }
    final userId = await getUserId();
    if (userId == null || userId.isEmpty) {
      onError?.call('ERROR', 'User ID is null. End trip failed.');
      throw Exception('User ID is null. End trip failed.');
    }
    try {
      await _platform.endTrip(
        apiKey: _apiKey!,
        userId: fieldforceId ?? userId,
      );
      onSuccess?.call(tripId);
      final sharedPreferencesService = SharedPreferencesService();
      await sharedPreferencesService.setTripId('');
      await stopTracking();
    } on PlatformException catch (e) {
      onError?.call(e.code, e.message);
    }
  }
}
