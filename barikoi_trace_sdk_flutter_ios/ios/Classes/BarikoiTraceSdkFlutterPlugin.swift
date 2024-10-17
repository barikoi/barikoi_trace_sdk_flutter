import Flutter
import UIKit
import CoreLocation
import Foundation

public class BarikoiTraceSdkFlutterPlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate, FlutterStreamHandler {

    var locationManager: CLLocationManager?
    var eventSink: FlutterEventSink?
    var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var userId: String?
    var apiKey: String?
    var latestLocation: CLLocation?
    
    // Declare locationUpdateHandler
    var locationUpdateHandler: ((CLLocation) -> Void)?

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
            if let args = call.arguments as? [String: Any],
               let userId = args["userId"] as? String,
               let apiKey = args["apiKey"] as? String {
                self.userId = userId
                self.apiKey = apiKey
                startTracking()
                result("Tracking started with userId: \(userId)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing userId or apiKey", details: nil))
            }

        case "getOrCreateUser":
            if let args = call.arguments as? [String: Any],
               let phoneNumber = args["phoneNumber"] as? String,
               let email = args["email"] as? String,
               let name = args["name"] as? String,
               let apiKey = args["apiKey"] as? String {
               getOrCreateUser(name:name, email: email, phoneNumber: phoneNumber, apiKey: apiKey, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                   message: "Missing phoneNumber or apiKey",
                                   details: nil))
            }
            
        case "createTrip":
            if let args = call.arguments as? [String: Any],
               let userId = args["userId"] as? String,
               let fieldForceId = args["fieldForceId"] as? String,
               let apiKey = args["apiKey"] as? String {
                createTrip(userId: userId, fieldForceId: fieldForceId, apiKey: apiKey, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                   message: "Missing userId or apiKey",
                                   details: nil))
            }
            
        case "startTrip":
            if let args = call.arguments as? [String: Any],
               let tag = args["tag"] as? String,
               let userId = args["user_id"] as? String,
               let apiKey = args["apiKey"] as? String {
                startTrip(tag:tag,apiKey: apiKey, userId: userId,result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                   message: "Missing userId or apiKey",
                                   details: nil))
            }
        case "endTrip":
            if let args = call.arguments as? [String: Any],
               let userId = args["userId"] as? String,
               let apiKey = args["apiKey"] as? String {
                endTrip(userId: userId, apiKey: apiKey, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                   message: "Missing userId or apiKey",
                                   details: nil))
            }
        case "stopTracking":
            stopTracking()
            result("Tracking stopped")
        case "getCurrentTrip":
                   if let args = call.arguments as? [String: Any],
                      let userId = args["userId"] as? String,
                      let apiKey = args["apiKey"] as? String {
                       getCurrentTrip(apiKey: apiKey, userId: userId, result: result)
                   } else {
                       result(FlutterError(code: "INVALID_ARGUMENT",
                                          message: "Missing userId or apiKey",
                                          details: nil))
                   }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func startTracking() {
            // Re-initialize the location manager every time startTracking is called
            if locationManager == nil {
                locationManager = CLLocationManager()
            }
            locationManager?.delegate = self

            // Request the necessary permissions
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()

            // Ensure the location manager is set up to handle location updates
            locationManager?.startUpdatingLocation()
            locationManager?.startMonitoringSignificantLocationChanges()

            // Enable background location updates
            locationManager?.allowsBackgroundLocationUpdates = true
            locationManager?.pausesLocationUpdatesAutomatically = false

            // Start a new background task
            startBackgroundTask()
        }


    public func stopTracking() {
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringSignificantLocationChanges()
    }

    var lastSentTime: Date?

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        latestLocation = location
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
        
        // Call the location update handler if set
        locationUpdateHandler?(location)
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

        // Use ISO 8601 format for gpx_time
        let gpxTimeFormatter = ISO8601DateFormatter()
        let gpxTime = gpxTimeFormatter.string(from: Date())

        let url = URL(string: Api.gpxUrl)!
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
            "gpx_time": gpxTime,  // Use the formatted gpxTime
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

    
    public func getOrCreateUser(name: String, email: String, phoneNumber: String, apiKey: String, result: @escaping FlutterResult) {
        // Replace 'BASE_URL' with your actual base URL
        guard let url = URL(string: Api.createUserUrl) else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
            return
        }

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the request body according to the API structure
        let requestBody: [String: Any] = ["phone": phoneNumber, "api_key": apiKey, "name": name,"email": email]

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

    public func createTrip(
        userId: String,
        fieldForceId: String,
        apiKey: String,
        result: @escaping FlutterResult
    ) {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
              var currentLoc: CLLocation!
              if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
              CLLocationManager.authorizationStatus() == .authorizedAlways) {
                 currentLoc = locationManager.location
                 print(currentLoc.coordinate.latitude)
                 print(currentLoc.coordinate.longitude)
              }
        guard let url = URL(string: "https://tracev2.barikoimaps.dev/realtime-trip/create") else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
            return
        }

        // Ensure we have a valid location
        guard let latestLocation = currentLoc else {
            result(FlutterError(code: "LOCATION_UNAVAILABLE", message: "Current location is not available", details: nil))
            return
        }

        let latitude = latestLocation.coordinate.latitude
        let longitude = latestLocation.coordinate.longitude

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the request body according to the API structure
        let requestBody: [String: Any] = [
            "user_id": userId,
            "fieldforce_id": fieldForceId,
            "api_key": apiKey,
            "latitude": String(latitude),
            "longitude": String(longitude)
        ]
        
        print(requestBody)

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
                if let responseString = String(data: data, encoding: .utf8) {
                            print("Response String: \(responseString)")
                        }
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
    
    public func startTrip(
        tag: String?,
        apiKey: String,
        userId: String,
        result: @escaping FlutterResult
    ) {
        self.apiKey = apiKey
        self.userId = userId
        startTracking()

        // Use ISO 8601 format for gpx_time
       let gpxTimeFormatter = ISO8601DateFormatter()
       gpxTimeFormatter.timeZone = TimeZone(secondsFromGMT: 6 * 3600) // UTC+6 offset
       let gpxTime = gpxTimeFormatter.string(from: Date())

        print(gpxTime)
        // Define the URL for the start trip API
        guard let url = URL(string: Api.startTripUrl) else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
            return
        }

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the request body according to the API structure
        var requestBody: [String: Any] = [
            "api_key": apiKey,
            "user_id": userId,
            "start_time": gpxTime
        ]
        if let tag = tag {
            requestBody["tag"] = tag
        }

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

    
    public func endTrip(
        userId: String,
        apiKey: String,
        result: @escaping FlutterResult
    ) {
        // Stop tracking before ending the trip
        stopTracking()

        // Use ISO 8601 format for end_time
       let isoDateFormatter = ISO8601DateFormatter()
       isoDateFormatter.timeZone = TimeZone(secondsFromGMT: 6 * 3600) // UTC+6 offset
       let endTime = isoDateFormatter.string(from: Date())

        
        print(endTime)
        // Define the URL for the end trip API
        guard let url = URL(string: Api.endTripUrl) else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
            return
        }

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the request body according to the API structure
        let requestBody: [String: Any] = [
            "api_key": apiKey,
            "user_id": userId,
            "end_time": endTime
        ]

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
                        print(jsonResponse)
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



    public func getCurrentTrip(apiKey: String, userId: String, result: @escaping FlutterResult) {
        print("Fetching current trip...")
        print(userId)
        // Create URL components using the base URL
        var components = URLComponents(string: Api.activeTripUrl)!
        components.queryItems = [
            URLQueryItem(name: "user_id", value: userId),
            URLQueryItem(name: "api_key", value: apiKey)
        ]

        // Ensure the URL is valid
        guard let url = components.url else {
            result(FlutterError(code: "INVALID_URL", message: "Invalid API URL", details: nil))
            return
        }

        // Create a URL request
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Set the request method to GET
        print("Request URL: \(url)")
        // Perform the network request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                result(FlutterError(code: "NETWORK_ERROR", message: "Network error occurred", details: nil))
                return
            }

            // Check for data
            guard let data = data else {
                result(FlutterError(code: "NO_DATA", message: "No data received", details: nil))
                return
            }

            // Attempt to parse the JSON response
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonResponse) // Print the JSON response for debugging
                    result(jsonResponse) // Return the parsed JSON
                } else {
                    result(FlutterError(code: "INVALID_RESPONSE", message: "Invalid response format", details: nil))
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                result(FlutterError(code: "JSON_PARSING_ERROR", message: "Failed to parse JSON response", details: error.localizedDescription))
            }
        }

        // Start the network request
        task.resume()
    }

    

    func syncOfflineTrip(trip: Trip, apiKey: String, userId: String, completion: @escaping (Trip?, BarikoiTraceError?) -> Void) {
        // Create a [String: Any] dictionary with the parameters
        let params: [String: Any] = [
            "api_key": apiKey,
            "user_id": userId,
            "start_time": trip.startTime,
            "end_time": trip.endTime,
            "tag": trip.tag ?? "",
            "state": trip.state
        ]

        // Convert to [String: String] dictionary
        var stringParams: [String: String] = [:]
        for (key, value) in params {
            if let stringValue = value as? String {
                stringParams[key] = stringValue
            } else if let intValue = value as? Int {
                stringParams[key] = String(intValue) // Convert Int to String
            }
            // Handle other types if necessary
        }

        guard let url = URL(string: Api.tripSyncUrl) else {
            completion(nil, .invalidUrlError)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = paramString(stringParams).data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, .networkError)
                return
            }

            guard let data = data else {
                completion(nil, .noDataError)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = json["status"] as? Int {
                    if status == 200 || status == 201 {
                        completion(trip, nil) // Success
                    } else if json["message"] is String {
                        let error = BarikoiTraceError.networkError
                        completion(nil, error)
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(nil, .jsonError(error))
            }
        }

        task.resume()
    }



    private func paramString(_ params: [String: String]) -> String {
        return params.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    enum BarikoiTraceError: Error {
        case networkError
        case jsonError(Error)
        case noDataError
        case invalidUrlError
    }
    
    // Flutter Stream Handler methods
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

public class Trip {
    var tripId: String
    var startTime: String
    var endTime: String
    var tag: String?
    var state: Int
    var userId: String
    var synced: Int

    // Initializer
    public init(tripId: String, startTime: String, endTime: String, tag: String?, state: Int, userId: String, synced: Int) {
        self.tripId = tripId
        self.startTime = startTime
        self.endTime = endTime
        self.tag = tag
        self.state = state
        self.userId = userId
        self.synced = synced
    }

    // Getters and Setters (optional in Swift)
    public func getTripId() -> String {
        return tripId
    }

    public func setTripId(_ tripId: String) {
        self.tripId = tripId
    }

    public func getStartTime() -> String {
        return startTime
    }

    public func setStartTime(_ startTime: String) {
        self.startTime = startTime
    }

    public func getEndTime() -> String {
        return endTime
    }

    public func setEndTime(_ endTime: String) {
        self.endTime = endTime
    }

    public func getTag() -> String? {
        return tag
    }

    public func setTag(_ tag: String?) {
        self.tag = tag
    }

    public func getState() -> Int {
        return state
    }

    public func setState(_ state: Int) {
        self.state = state
    }

    public func getSynced() -> Int {
        return synced
    }

    public func setSynced(_ synced: Int) {
        self.synced = synced
    }

    public func getUserId() -> String {
        return userId
    }

    public func setUserId(_ userId: String) {
        self.userId = userId
    }
}

class Api {
    static let baseUrl = "https://tracev2.barikoimaps.dev"

    static let startTripUrl = "\(baseUrl)/trip/create"
    static let endTripUrl = "\(baseUrl)/trip/end"
    static let tripSyncUrl = "\(baseUrl)/trip/offline"
    static let gpxUrl = "\(baseUrl)/sdk/add-gpx"
    static let bulkUrl = "\(baseUrl)/sdk/bulk-gpx"
    static let userUrl = "\(baseUrl)/sdk/user"
    static let createUserUrl = "\(baseUrl)/sdk/authenticate"
    static let activeTripUrl = "\(baseUrl)/trip/check-active-trip"
    static let companySettingsUrl = "\(baseUrl)/sdk/get-company-settings"
    static let appLogUrl = "\(baseUrl)/app/log"
}

