class TripResponse {
  final bool active;
  final Trip? trip;

  TripResponse({
    required this.active,
    this.trip,
  });

  factory TripResponse.fromJson(Map<String, dynamic> json) {
    return TripResponse(
      active: json['active'] as bool,
      trip: json['trip'] != null ? Trip.fromJson(json['trip'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active,
      'trip': trip?.toJson(),
    };
  }

  TripResponse copyWith({
    bool? active,
    Trip? trip,
  }) {
    return TripResponse(
      active: active ?? this.active,
      trip: trip ?? this.trip,
    );
  }
}

class Trip {
  final String tripId;
  final String startTime;
  final String endTime;
  final String tag;
  final int state;
  final String userId;
  final int synced;

  Trip({
    required this.tripId,
    required this.startTime,
    required this.endTime,
    required this.tag,
    required this.state,
    required this.userId,
    required this.synced,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      tripId: json['trip_id'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      tag: json['tag'] as String,
      state: json['state'] as int,
      userId: json['user_id'] as String,
      synced: json['synced'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'start_time': startTime,
      'end_time': endTime,
      'tag': tag,
      'state': state,
      'user_id': userId,
      'synced': synced,
    };
  }

  Trip copyWith({
    String? tripId,
    String? startTime,
    String? endTime,
    String? tag,
    int? state,
    String? userId,
    int? synced,
  }) {
    return Trip(
      tripId: tripId ?? this.tripId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      tag: tag ?? this.tag,
      state: state ?? this.state,
      userId: userId ?? this.userId,
      synced: synced ?? this.synced,
    );
  }
}
