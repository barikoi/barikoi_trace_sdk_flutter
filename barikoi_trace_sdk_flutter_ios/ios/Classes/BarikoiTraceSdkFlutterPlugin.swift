import Flutter
import UIKit
import CoreLocation

public class BarikoiTraceSdkFlutterPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate, FlutterStreamHandler {

    var locationManager: CLLocationManager?
    var eventSink: FlutterEventSink?
    var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var userId: String?
    var apiKey: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: "barikoi_trace_sdk_flutter_ios", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "barikoi_trace_sdk_flutter_ios_stream", binaryMessenger: registrar.messenger())

        let instance = BarikoiTraceSdkFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startTracking":
            if let args = call.arguments as? [String: Any] {
                if let userId = args["userId"] as? String, let apiKey = args["apiKey"] as? String {
                    self.userId = userId
                    self.apiKey = apiKey
                    startTracking()
                    result("Tracking started with userId: \(userId)")
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing userId or apiKey", details: nil))
                }
            }
        case "stopTracking":
            stopTracking()
            result("Tracking stopped")
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func startTracking() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self

            locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
            locationManager?.startUpdatingLocation()
            locationManager?.startMonitoringSignificantLocationChanges()

            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.pausesLocationUpdatesAutomatically = false
        }
    }

    public func stopTracking() {
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringSignificantLocationChanges()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        // Send location to the server
        sendLocationToServer(latitude: latitude, longitude: longitude)

        // Send location updates to Flutter
        if let eventSink = eventSink {
            eventSink(["latitude": latitude, "longitude": longitude])
        }

        // Ensure background task is started
        startBackgroundTask()
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // Background task management
    func startBackgroundTask() {
        if bgTask != UIBackgroundTaskIdentifier.invalid {
            UIApplication.shared.endBackgroundTask(bgTask)
        }
        bgTask = UIApplication.shared.beginBackgroundTask(withName: "LocationUpdate") {
            UIApplication.shared.endBackgroundTask(self.bgTask)
            self.bgTask = UIBackgroundTaskIdentifier.invalid
        }
    }

    // Send location to server
    func sendLocationToServer(latitude: Double, longitude: Double) {
        guard let userId = self.userId, let apiKey = self.apiKey else {
            print("User ID or API Key is not set.")
            return
        }

        let gpxTime = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)

        let url = URL(string: "https://tracev2.barikoimaps.dev/sdk/add-gpx")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "user_id": userId,
            "accuracy": 0,
            "latitude": latitude,
            "longitude": longitude,
            "altitude": 50,
            "speed": 10,
            "bearing": 299,
            "gpx_time": gpxTime,
            "api_key": apiKey
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making API call: \(error.localizedDescription)")
                return
            }
            if let response = response as? HTTPURLResponse, let data = data {
                print("API Response: \(response.statusCode) - \(String(data: data, encoding: .utf8) ?? "")")
            }
        }

        task.resume()
    }

    // FlutterStreamHandler methods for location updates
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
