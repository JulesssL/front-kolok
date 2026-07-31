import 'kolok.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? iban;
  final String? preferredBank;
  final Kolok? kolok;

  User({
    required this.id, 
    required this.name, 
    required this.email, 
    this.avatarUrl,
    this.iban,
    this.preferredBank, 
    this.kolok
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      iban: json['iban'],
      preferredBank: json['preferredBank'] ?? json['preferred_bank'],
      kolok: json['kolok'] != null ? Kolok.fromJson(json['kolok']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'iban': iban,
      'preferredBank': preferredBank,
      if (kolok != null) 'kolok': kolok!.toJson(),
    };
  }
}
