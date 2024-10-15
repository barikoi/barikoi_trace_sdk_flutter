part of '../../barikoi_trace_sdk_flutter_platform_interface.dart';

class TraceUserResponse {
  User user;

  TraceUserResponse({
    required this.user,
  });

  factory TraceUserResponse.fromJson(Map<String, dynamic> json) {
    return TraceUserResponse(
      user: User.fromJson(json["user"] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
      };
}

class User {
  String id;

  User({
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"] as String, // Only keep _id
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id, // Only serialize _id
      };
}
