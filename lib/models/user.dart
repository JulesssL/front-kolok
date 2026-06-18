import 'kolok.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final Kolok? kolok;

  User({required this.id, required this.name, required this.email, this.avatarUrl, this.kolok});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      kolok: json['kolok'] != null ? Kolok.fromJson(json['kolok']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      if (kolok != null) 'kolok': kolok!.toJson(),
    };
  }
}
