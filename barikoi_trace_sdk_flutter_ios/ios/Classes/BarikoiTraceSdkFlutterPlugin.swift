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

        case "getOrCreateUser":
            if let args = call.arguments as? [String: Any],
               let phoneNumber = args["phoneNumber"] as? String,
               let apiKey = args["apiKey"] as? String {
               getOrCreateUser(phoneNumber: phoneNumber, apiKey: apiKey, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                   message: "Missing userId or apiKey",
                                   details: nil))
            }

        case "stopTracking":
            stopTracking()
            result("Tracking stopped")
        default:
            result(FlutterMethodNotImplemented)
        }
    }
public func getOrCreateUser(phoneNumber: String, apiKey: String, result: @escaping FlutterResult) {
    // Replace 'BASE_URL' with your actual base URL
    guard let url = URL(string: "https://tracev2.barikoimaps.dev/sdk/authenticate") else {
        result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
        return
    }

    // Prepare the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Create the request body according to the API structure
    let requestBody: [String: Any] = ["phone": phoneNumber, "api_key": apiKey]

    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        result(FlutterError(code: "INVALID_REQUEST_BODY", message: "Failed to create request body", details: nil))
        return
    }

    // Perform the network request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            result(FlutterError(code: "NETWORK_ERROR", message: "Error making request: \(error.localizedDescription)", details: nil))
            return
        }

        // Check for a valid response
        if let data = data {
            do {
                // Parse the JSON response
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Send the response back to Flutter
                    result(jsonResponse)
                } else {
                    result(FlutterError(code: "INVALID_RESPONSE", message: "Invalid response format", details: nil))
                }
            } catch {
                result(FlutterError(code: "JSON_PARSING_ERROR", message: "Failed to parse JSON response", details: nil))
            }
        } else {
            result(FlutterError(code: "NO_RESPONSE", message: "No response from server", details: nil))
        }
    }

    // Start the network request
    task.resume()
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

    var lastSentTime: Date?

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        // Send location updates to Flutter
        if let eventSink = eventSink {
            eventSink(["latitude": latitude, "longitude": longitude])
        }

        // Ensure that at least 5 seconds have passed since the last API request
        let currentTime = Date()
        if let lastTime = lastSentTime {
            let timeInterval = currentTime.timeIntervalSince(lastTime)
            if timeInterval < 6 {
                return
            }
        }

        // Update the last sent time and send the location to the server
        lastSentTime = currentTime
        sendLocationToServer(latitude: latitude, longitude: longitude)

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
