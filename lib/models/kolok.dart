import 'user.dart';

class Kolok {
  final String id;
  final String name;
  final String address;
  final String joinCode;
  final List<User>? users;

  Kolok({
    required this.id,
    required this.name,
    required this.address,
    required this.joinCode,
    this.users,
  });

  factory Kolok.fromJson(Map<String, dynamic> json) {
    return Kolok(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      joinCode: json['joinCode'] ?? json['join_code'] ?? '',
      users: json['users'] != null 
          ? (json['users'] as List).map((u) => User.fromJson(u)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'joinCode': joinCode,
      if (users != null) 'users': users!.map((u) => u.toJson()).toList(),
    };
  }
}
