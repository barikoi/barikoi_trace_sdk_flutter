import 'package:barikoi_trace_sdk_flutter_platform_interface/src/method_channel_barikoi_trace_sdk_flutter.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of barikoi_trace_sdk_flutter must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `BarikoiTraceSdkFlutter`.
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that `implements`
///  this interface will be broken by newly added [BarikoiTraceSdkFlutterPlatform] methods.
abstract class BarikoiTraceSdkFlutterPlatform extends PlatformInterface {
  /// Constructs a BarikoiTraceSdkFlutterPlatform.
  BarikoiTraceSdkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static BarikoiTraceSdkFlutterPlatform _instance =
      MethodChannelBarikoiTraceSdkFlutter();

  /// The default instance of [BarikoiTraceSdkFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelBarikoiTraceSdkFlutter].
  static BarikoiTraceSdkFlutterPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [BarikoiTraceSdkFlutterPlatform] when they register themselves.
  static set instance(BarikoiTraceSdkFlutterPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Return the current platform name.
  Future<String?> getPlatformName();

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
    required String userId,
    required String apiKey,
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
