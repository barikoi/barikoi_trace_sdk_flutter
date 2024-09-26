/// An abstract class that defines the platform interface for the Barikoi Trace SDK.
///
/// This class serves as a blueprint for different platform-specific implementations of the Barikoi Trace SDK,
/// such as Android and iOS. It declares the methods that must be implemented to manage user settings,
/// location tracking, and trip management within the SDK.
///
/// Implementing classes are responsible for providing the actual functionality for each method, which may
/// involve platform-specific code using method channels or other interop mechanisms.
///
/// Usage:
/// To use the Barikoi Trace SDK, create a concrete implementation of this class (e.g., for Android or iOS)
/// and invoke the methods as needed. Example usage:
/// ```dart
/// BarikoiTraceSdkFlutterPlatform sdkPlatform = BarikoiTraceSdkFlutterAndroid();
/// await sdkPlatform.initialize(apiKey: 'YOUR_API_KEY');
/// ```
///
abstract class BarikoiTraceSdkFlutterPlatform {
  /// Initializes the SDK with the provided API key.
  ///
  /// This method must be implemented to handle SDK initialization.
  ///
  /// Parameters:
  /// - [apiKey]: The API key required for SDK initialization.
  Future<void> initialize({required String apiKey});

  /// Sets or creates a user with the provided details.
  ///
  /// This method must be implemented to manage user creation or updating.
  ///
  /// Parameters:
  /// - [name]: The name of the user.
  /// - [email]: Optional email of the user.
  /// - [phone]: The phone number of the user.
  Future<void> setOrCreateUser({
    required String name,
    String? email,
    required String phone,
  });

  /// Starts tracking the user's location with the specified parameters.
  ///
  /// This method must be implemented to initiate location tracking.
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
  });

  /// Stops the location tracking.
  ///
  /// This method must be implemented to halt location tracking.
  Future<void> stopTracking();

  /// Starts a trip with the specified parameters.
  ///
  /// This method must be implemented to initiate a trip.
  ///
  /// Parameters:
  /// - [updateInterval]: Optional update interval in seconds.
  /// - [distaceInterval]: Optional distance interval in meters.
  /// - [accuracyfilter]: Optional accuracy filter in meters.
  /// - [tag]: Optional tag for the trip.
  Future<String?> startTrip({
    int? updateInterval,
    int? distaceInterval,
    int? accuracyfilter,
    String? tag,
  });

  /// Ends the current trip.
  ///
  /// This method must be implemented to stop the current trip.
  Future<String?> endTrip();

  /// Retrieves the user ID.
  ///
  /// This method must be implemented to fetch the user ID.
  ///
  /// Returns:
  /// - A [String] containing the user ID, or `null` if not available.
  Future<String?> getUserId();
}
