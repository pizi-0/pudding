// ignore_for_file: non_constant_identifier_names, public_member_api_docs, sort_constructors_first
import 'dart:convert';

class JellyPeople {
  final String Name;
  final String Id;
  final String Role;
  final String Type;

  JellyPeople({
    required this.Name,
    required this.Id,
    required this.Role,
    required this.Type,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'Name': Name,
      'Id': Id,
      'Role': Role,
      'Type': Type,
    };
  }

  factory JellyPeople.fromMap(Map<String, dynamic> map) {
    return JellyPeople(
      Name: map['Name'] as String,
      Id: map['Id'] as String,
      Role: map['Role'] as String,
      Type: map['Type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory JellyPeople.fromJson(String source) =>
      JellyPeople.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'JellyPeople(Name: $Name, Id: $Id, Role: $Role, Type: $Type)';
  }

  @override
  bool operator ==(covariant JellyPeople other) {
    if (identical(this, other)) return true;

    return other.Name == Name &&
        other.Id == Id &&
        other.Role == Role &&
        other.Type == Type;
  }

  @override
  int get hashCode {
    return Name.hashCode ^ Id.hashCode ^ Role.hashCode ^ Type.hashCode;
  }
}
