class User {
  final int? id;
  final String username;
  final String? email;
  final List<String> roles;

  User({
    this.id,
    required this.username,
    this.email,
    this.roles = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final username = json['username'];
    final email = json['email'];
    final rolesJson = json['roles'];

    final roles = rolesJson is List
        ? rolesJson.map((role) => role.toString()).toList()
        : <String>[];

    return User(
      id: id is int ? id : (id is String ? int.tryParse(id) : null),
      username: username is String ? username : username?.toString() ?? '',
      email: email is String ? email : email?.toString(),
      roles: roles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
    };
  }
}
