import 'package:barikoi_trace_sdk_flutter_platform_interface/barikoi_trace_sdk_flutter_platform_interface.dart';

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

  startTracking({required String userId}) {
    if (_apiKey == null) {
      throw Exception('SDK not initialized. API key is required.');
    }
    _platform.startTracking(userId: userId, apiKey: _apiKey!);
  }

  stopTracking() {
    if (_apiKey == null) {
      throw Exception('SDK not initialized. API key is required.');
    }
    _platform.stopTracking();
  }
}
