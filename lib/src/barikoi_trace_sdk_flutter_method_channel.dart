import 'package:flutter/services.dart';

import 'barikoi_trace_sdk_flutter_platform_interface.dart';

/// An implementation of [BarikoiTraceSdkFlutterPlatform] that uses method channels for Android.
///
/// This class communicates with the native Android code using Method Channels, allowing for interaction with
/// the Barikoi Trace SDK functionalities from Flutter. It implements all the required methods defined in
/// [BarikoiTraceSdkFlutterPlatform] to manage user settings, location tracking, and trip management.
///
/// Usage:
/// ```dart
/// // Create an instance of the Android platform implementation
/// BarikoiTraceSdkFlutterPlatform sdkPlatform = BarikoiTraceSdkFlutterAndroid();
///
/// // Initialize the SDK with the API key
/// await sdkPlatform.initialize(apiKey: 'YOUR_API_KEY');
///
/// // Set or create a user
/// await sdkPlatform.setOrCreateUser(name: 'Jane Doe', phone: '9876543210');
///
/// // Start tracking the user's location
/// await sdkPlatform.startTracking(updateInterval: 5, distanceInterval: 10);
///
/// // Begin a trip
/// await sdkPlatform.startTrip(updateInterval: 5, distanceInterval: 10);
///
/// // Stop tracking
/// await sdkPlatform.stopTracking();
///
/// // End the trip
/// await sdkPlatform.endTrip();
/// ```
///
class BarikoiTraceSdkFlutterAndroid extends BarikoiTraceSdkFlutterPlatform {
  static const MethodChannel _channel =
      MethodChannel('barikoi_trace_sdk_flutter');

  /// Initializes the SDK with the provided API key.
  ///
  /// This method calls the native method `initialize` and passes the API key as an argument.
  ///
  /// Parameters:
  /// - [apiKey]: The API key required for SDK initialization.
  @override
  Future<void> initialize({required String apiKey}) async {
    final arguments = {'apiKey': apiKey};
    await _channel.invokeMethod('initialize', arguments);
  }

  /// Sets or creates a user with the provided details.
  ///
  /// This method calls the native method `setOrCreateUser` with the user's name, email, and phone number.
  ///
  /// Parameters:
  /// - [name]: The name of the user.
  /// - [email]: Optional email of the user.
  /// - [phone]: The phone number of the user.
  @override
  Future<void> setOrCreateUser({
    required String name,
    String? email,
    required String phone,
  }) async {
    final arguments = {
      'name': name,
      'email': email,
      'phone': phone,
    };
    await _channel.invokeMethod('setOrCreateUser', arguments);
  }

  /// Starts tracking the user's location with the specified parameters.
  ///
  /// This method calls the native method `startTracking` with the provided tracking parameters.
  ///
  /// Parameters:
  /// - [updateInterval]: Optional update interval in seconds.
  /// - [distaceInterval]: Optional distance interval in meters.
  /// - [accuracyfilter]: Optional accuracy filter in meters.
  /// - [tag]: Optional tag for tracking.
  @override
  Future<void> startTracking({
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
  }) async {
    final arguments = {
      'tag': tag,
      'updateInterval': updateInterval,
      'distaceInterval': distaceInterval,
      'accuracyfilter': accuracyfilter,
    };
    await _channel.invokeMethod('startTracking', arguments);
  }

  /// Stops the location tracking.
  ///
  /// This method calls the native method `endTracking` to stop tracking the user's location.
  @override
  Future<void> stopTracking() async {
    await _channel.invokeMethod('endTracking');
  }

  /// Starts a trip with the specified parameters.
  ///
  /// This method calls the native method `startTrip` with the provided trip parameters.
  ///
  /// Parameters:
  /// - [updateInterval]: Optional update interval in seconds.
  /// - [distaceInterval]: Optional distance interval in meters.
  /// - [accuracyfilter]: Optional accuracy filter in meters.
  /// - [tag]: Optional tag for the trip.
  @override
  Future<void> startTrip({
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
  }) async {
    final arguments = {
      'tag': tag,
      'updateInterval': updateInterval,
      'distaceInterval': distaceInterval,
      'accuracyfilter': accuracyfilter,
    };
    await _channel.invokeMethod('startTrip', arguments);
  }

  /// Ends the current trip.
  ///
  /// This method calls the native method `endTrip` to stop the current trip.
  @override
  Future<void> endTrip() async {
    await _channel.invokeMethod('endTrip');
  }

  /// Retrieves the user ID.
  ///
  /// This method calls the native method `getUserId` and returns the user ID as a string.
  ///
  /// Returns:
  /// - A [String] containing the user ID, or `null` if not available.
  @override
  Future<String?> getUserId() async {
    return await _channel.invokeMethod<String>('getUserId');
  }
}
