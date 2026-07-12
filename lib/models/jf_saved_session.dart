// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class JfSavedSession {
  final String token;
  final String userId;
  final String serverAddresss;
  JfSavedSession({
    required this.token,
    required this.userId,
    required this.serverAddresss,
  });

  JfSavedSession copyWith({
    String? token,
    String? userId,
    String? serverAddresss,
  }) {
    return JfSavedSession(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      serverAddresss: serverAddresss ?? this.serverAddresss,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'userId': userId,
      'serverAddresss': serverAddresss,
    };
  }

  factory JfSavedSession.fromMap(Map<String, dynamic> map) {
    return JfSavedSession(
      token: map['token'] as String,
      userId: map['userId'] as String,
      serverAddresss: map['serverAddresss'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory JfSavedSession.fromJson(String source) =>
      JfSavedSession.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'JfSavedSession(token: $token, userId: $userId, serverAddresss: $serverAddresss)';

  @override
  bool operator ==(covariant JfSavedSession other) {
    if (identical(this, other)) return true;

    return other.token == token &&
        other.userId == userId &&
        other.serverAddresss == serverAddresss;
  }

  @override
  int get hashCode =>
      token.hashCode ^ userId.hashCode ^ serverAddresss.hashCode;
}
