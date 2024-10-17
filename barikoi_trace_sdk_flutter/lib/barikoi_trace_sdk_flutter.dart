import 'dart:io' show Platform;

import 'package:barikoi_trace_sdk_flutter/kv.dart';
import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';
import 'package:flutter/services.dart';

BarikoiTraceSdkFlutterPlatform get _platform =>
    BarikoiTraceSdkFlutterPlatform.instance;

/// Barikoi Trace SDK Flutter.
///
/// This class provides a singleton interface for interacting with the Barikoi Trace SDK.
/// It manages SDK initialization, user data, location tracking, and trip management.
///
/// ## Usage:
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

  // Private constructor to initialize the SDK with the provided API key
  BarikoiTraceSdkFlutter._({required String apiKey});

  /// Factory constructor to create or return the singleton instance of the SDK.
  /// This constructor initializes shared preferences and the SDK for the current platform.
  factory BarikoiTraceSdkFlutter({required String apiKey}) {
    _apiKey = apiKey;
    _instance ??= BarikoiTraceSdkFlutter._(apiKey: apiKey);

    // Initialize shared preferences service asynchronously
    () async {
      final sharedPreferencesService = SharedPreferencesService();
      await sharedPreferencesService.init();
    }.call();

    // Initialize the SDK for Android or iOS
    if (Platform.isAndroid) {
      _platform.intAndroidSdk(apiKey);
    }
    if (Platform.isIOS) {
      _instance!._syncIosTrip();
    }
    // Return the singleton instance
    return _instance!;
  }

  /// Synchronizes ongoing trip information for iOS platform.
  /// This method checks if there is an active trip and starts tracking if necessary.
  Future<void> _syncIosTrip() async {
    final userId = await getUserId();
    final tripId = await getTripId();
    if (tripId == null || userId == null) {
      return; // Exit if either tripId or userId is null
    }

    final onGoingTrip = await _platform.getCurrentTrip(
      userId: userId,
      apiKey: _apiKey!,
    );

    if (onGoingTrip['active'] as bool && onGoingTrip['trip']['_id'] == tripId) {
      await _platform.startTracking(userId: userId, apiKey: _apiKey!);
    }
  }

  /// Static getter to access the singleton instance of the SDK.
  /// Throws an exception if the SDK is not initialized.
  static BarikoiTraceSdkFlutter get instance {
    if (_instance == null) {
      throw Exception('SDK not initialized.');
    }
    return _instance!;
  }

  /// Starts tracking the user's location.
  ///
  /// Requires the SDK to be initialized and a user to be set or created.
  ///
  /// Parameters:
  /// - [updateInterval]: The interval in seconds for location updates.
  /// - [distanceInterval]: The distance in meters between location updates.
  /// - [accuracyFilter]: (Optional) The desired accuracy for location tracking.
  /// - [tag]: (Optional) A tag for the tracking session.
  Future<void> startTracking({
    int? updateInterval,
    int? distanceInterval,
    int? accuracyFilter,
    String? tag,
  }) async {
    if (_apiKey == null) {
      throw Exception('SDK not initialized. API key is required.');
    }

    final userId = await getUserId();
    if (userId == null) {
      throw Exception(
          'User ID is null. Set or create a user before starting tracking.');
    }

    await _platform.startTracking(userId: userId, apiKey: _apiKey!);
  }

  /// Stops location tracking for the user.
  ///
  /// Parameters:
  /// - [onSuccess]: A callback function that is called with the user ID on successful stopping of tracking.
  /// - [onError]: A callback function that is called with error details if an error occurs.
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

  /// Sets or creates a user with the specified name and phone number.
  ///
  /// Parameters:
  /// - [name]: The name of the user.
  /// - [email]: The email of the user.
  /// - [phone]: The phone number of the user.
  /// - [onSuccess]: A callback function that is called with the user ID on success.
  /// - [onError]: A callback function that is called with error details if an error occurs.
  Future<void> setOrCreateUser({
    required String phone,
    String? name,
    String? email,
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
        email: email,
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

  /// Retrieves the user ID from shared preferences.
  ///
  /// Returns:
  /// - The user ID as a [String?] or null if not found.
  Future<String?> getUserId() async {
    final sharedPreferencesService = SharedPreferencesService();
    return sharedPreferencesService.getUserId();
  }

  /// Retrieves the trip ID from shared preferences.
  ///
  /// Returns:
  /// - The trip ID as a [String?] or null if not found.
  Future<String?> getTripId() async {
    final sharedPreferencesService = SharedPreferencesService();
    return sharedPreferencesService.getTripId();
  }

  /// Creates a new trip for the specified user.
  ///
  /// Parameters:
  /// - [userId]: The ID of the user for whom the trip is created.
  /// - [fieldForceId]: (Optional) The field force ID associated with the trip.
  ///
  /// Returns:
  /// - The ID of the created trip as a [String?].
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

  /// Starts a new trip for the user.
  ///
  /// Parameters:
  /// - [fieldForceId]: (Optional) The field force ID for the trip.
  /// - [updateInterval]: The interval in seconds for trip updates (currently a TODO).
  /// - [distanceInterval]: The distance in meters between trip updates (currently a TODO).
  /// - [accuracyFilter]: The desired accuracy for trip tracking (currently a TODO).
  /// - [tag]: (Optional) A tag for the trip.
  /// - [onSuccess]: A callback function called with the trip ID on success.
  /// - [onError]: A callback function called with error details if an error occurs.
  Future<void> startTrip({
    String? fieldForceId,
    int? updateInterval, // todo
    int? distanceInterval, // todo
    int? accuracyFilter, // todo
    String? tag,
    void Function(String? tripId)? onSuccess,
    void Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    if (_apiKey == null) {
      onError?.call('ERROR', 'SDK not initialized. API key is required.');
      throw Exception('SDK not initialized. API key is required.');
    }

    String? userId = await getUserId();
    if (userId == null) {
      onError?.call('ERROR',
          'User ID is null. Set or create a user before starting tracking.');
      throw Exception(
          'User ID is null. Set or create a user before starting tracking.');
    }

    if (Platform.isIOS) {
      final tripId = await getTripId();
      final res =
          await _platform.getCurrentTrip(apiKey: _apiKey!, userId: userId);
      if (res['active'] == true && res['trip']['_id'] != tripId) {
        await SharedPreferencesService().setTripId('');
        onError?.call('ERROR', 'Trip already active');
        throw Exception('Trip already active');
      }

      await _platform.startTracking(apiKey: _apiKey!, userId: userId);
      onSuccess?.call(tripId);
      return;
    }

    try {
      final tripIdAndroid = await _platform.startTrip(
        tag: "tag",
        apiKey: _apiKey!,
        userId: fieldForceId ?? userId ?? '',
        accuracyFilter: accuracyFilter,
        distanceInterval: distanceInterval,
        updateInterval: updateInterval,
      );
      onSuccess?.call(tripIdAndroid);

      final sharedPreferencesService = SharedPreferencesService();
      await sharedPreferencesService.setTripId(tripIdAndroid!);
    } catch (e) {
      onError?.call('ERROR', e.toString());
    }
    return;
  }

  /// Ends the current trip for the user.
  ///
  /// Parameters:
  /// - [fieldForceId]: (Optional) The field force ID for the trip.
  /// - [onSuccess]: A callback function called with the trip ID on success.
  /// - [onError]: A callback function called with error details if an error occurs.
  Future<void> endTrip({
    String? fieldForceId,
    void Function(String? tripId)? onSuccess,
    void Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    if (_apiKey == null) {
      throw Exception('SDK not initialized. API key is required.');
    }

    final userId = await getUserId();
    if (userId == null || userId.isEmpty) {
      onError?.call('ERROR', 'User ID is null. End trip failed.');
      throw Exception('User ID is null. End trip failed.');
    }

    String? tripId = await getTripId();
    if (Platform.isIOS) {
      final res =
          await _platform.getCurrentTrip(apiKey: _apiKey!, userId: userId);
      if (res['active'] == true) {
        tripId = res['trip']['_id'] as String;
      }
    }

    if (tripId == null || tripId.isEmpty) {
      onError?.call('ERROR', 'Trip ID is null. End trip failed.');
      throw Exception('Trip ID is null. End trip failed.');
    }

    try {
      await _platform.endTrip(
        apiKey: _apiKey!,
        userId: fieldForceId ?? userId,
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
