# Barikoi Trace SDK Flutter

## Installation

To use the `BarikoiTraceSdkFlutter`, add the following dependency to your `pubspec.yaml` file:

``` yaml
dependencies:
  barikoi_trace_sdk_flutter: ^<latest_version>
```

## Setup Instructions

To set up the Barikoi Trace SDK for your project, please refer to the specific instructions for your platform:

- [iOS Setup](./barikoi_trace_sdk_flutter_ios/README.md)
- [Android Setup](./barikoi_trace_sdk_flutter_android/README.md)

## Usage

### Initializing the SDK
To start using the SDK, you need to initialize it with your API key.

``` dart
BarikoiTraceSdkFlutter(apiKey: 'YOUR_API_KEY');

// optional. you can direct use `BarikoiTraceSdkFlutter.instance`
final sdk  = BarikoiTraceSdkFlutter.instance;

```

### Setting or Creating a User

You can set or create a user using the following method:

``` dart
await sdk.setOrCreateUser(
  name: 'John Doe',
  phone: '1234567890',
  onSuccess: (userId) {
    print('User ID: $userId');
  },
  onError: (errorCode, errorMessage) {
    print('Error: $errorMessage');
  },
);


```

### Starting and Stopping Tracking
**To start tracking the user's location:**
``` dart 
 await BarikoiTraceSdkFlutter.instance.startTracking();
```

**To stop tracking:**

``` dart
 await BarikoiTraceSdkFlutter.instance.stopTracking();
```


### Starting and Ending a Trip
**To start a new trip:**
``` dart
 await BarikoiTraceSdkFlutter.instance.startTrip(
  onSuccess: (id) {
    print(id);
    tripId = id;
    setState(() {});
  },
);
```

**To end the current trip:**

``` dart
await BarikoiTraceSdkFlutter.instance.endTrip(
  onSuccess: (tripId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(tripId ?? ''),
      ),
    );
  },
  onError: (errorCode, errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).primaryColor,
        content: Text(errorMessage ?? ''),
      ),
    );
  },
);
```
