import 'barikoi_trace_sdk_flutter_platform_interface.dart';

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
  final BarikoiTraceSdkFlutterPlatform sdkPlatform;

  // Static field to hold the single instance of the class
  static BarikoiTraceSdkFlutter? _instance;

  // Private named constructor to prevent external instantiation
  BarikoiTraceSdkFlutter._({required this.sdkPlatform});

  // Factory constructor to return the singleton instance
  factory BarikoiTraceSdkFlutter(
      {required BarikoiTraceSdkFlutterPlatform sdkPlatform}) {
    // Check if the instance is null, if so, create it
    _instance ??= BarikoiTraceSdkFlutter._(sdkPlatform: sdkPlatform);
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

  /// Initializes the SDK with the given API key.
  ///
  /// This method must be called before using any other SDK methods. It configures the SDK with the provided API key.
  ///
  /// Throws an exception if the SDK is not initialized properly.
  Future<void> initializeSdk({required String apiKey}) async {
    await sdkPlatform.initialize(apiKey: apiKey);
    _instance ??= BarikoiTraceSdkFlutter._(sdkPlatform: sdkPlatform);
  }

  /// Sets or creates a user with the given details.
  ///
  /// If the user is created or updated successfully, the `onSuccess` callback will be invoked with the user's ID.
  /// If there is an error during the operation, the `onError` callback will be invoked with an error code and message.
  ///
  /// Parameters:
  /// - [name]: The name of the user.
  /// - [email]: Optional email of the user.
  /// - [phone]: The phone number of the user.
  /// - [onSuccess]: Callback function invoked on success with the user ID.
  /// - [onError]: Callback function invoked on error with an error code and message.
  Future<void> setOrCreateUser({
    required String name,
    String? email,
    required String phone,
    Function(String? userId)? onSuccess,
    Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    try {
      await sdkPlatform.setOrCreateUser(name: name, email: email, phone: phone);
      onSuccess?.call(await sdkPlatform.getUserId());
    } catch (e) {
      onError?.call('ERROR', e.toString());
    }
  }

  /// Starts tracking the user's location with the specified parameters.
  ///
  /// Parameters:
  /// - [updateInterval]: Optional update interval in seconds.
  /// - [distaceInterval]: Optional distance interval in meters.
  /// - [accuracyfilter]: Optional accuracy filter in meters.
  /// - [tag]: Optional tag for tracking.
  Future<void> startTracking({
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
  }) async {
    await sdkPlatform.startTracking(
      updateInterval: updateInterval,
      distaceInterval: distaceInterval,
      accuracyfilter: accuracyfilter,
      tag: tag,
    );
  }

  /// Stops the location tracking.
  Future<void> stopTracking() async {
    await sdkPlatform.stopTracking();
  }

  /// Begins a trip with the specified parameters.
  ///
  /// If the trip is started successfully, the `onSuccess` callback will be invoked with the trip ID.
  /// If there is an error during the operation, the `onError` callback will be invoked with an error code and message.
  ///
  /// Parameters:
  /// - [updateInterval]: Optional update interval in seconds.
  /// - [distaceInterval]: Optional distance interval in meters.
  /// - [accuracyfilter]: Optional accuracy filter in meters.
  /// - [tag]: Optional tag for the trip.
  /// - [onSuccess]: Callback function invoked on success with the trip ID.
  /// - [onError]: Callback function invoked on error with an error code and message.
  Future<void> startTrip({
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
    Function(String? tripId)? onSuccess,
    Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    try {
      await sdkPlatform.startTrip(
        updateInterval: updateInterval,
        distaceInterval: distaceInterval,
        accuracyfilter: accuracyfilter,
        tag: tag,
      );
      onSuccess?.call(await sdkPlatform.getUserId());
    } catch (e) {
      onError?.call('ERROR', e.toString());
    }
  }

  /// Ends the current trip.
  ///
  /// If the trip ends successfully, the `onSuccess` callback will be invoked with the trip ID.
  /// If there is an error during the operation, the `onError` callback will be invoked with an error code and message.
  ///
  /// Parameters:
  /// - [onSuccess]: Callback function invoked on success with the trip ID.
  /// - [onError]: Callback function invoked on error with an error code and message.
  Future<void> endTrip({
    Function(String? tripId)? onSuccess,
    Function(String? errorCode, String? errorMessage)? onError,
  }) async {
    try {
      await sdkPlatform.endTrip();
      onSuccess?.call(await sdkPlatform.getUserId());
    } catch (e) {
      onError?.call('ERROR', e.toString());
    }
  }
}
