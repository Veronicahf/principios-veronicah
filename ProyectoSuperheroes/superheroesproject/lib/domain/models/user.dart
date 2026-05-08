/// [QUÉ ES]: Modelo de dominio que representa un Usuario
/// [PARA QUÉ SIRVE]: Encapsula datos y comportamiento de usuarios
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Modelo puro de negocio, independiente de capas de datos o presentación (SOLID - SRP)

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

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool isAdmin() => hasRole('ROLE_ADMIN');
  bool isModerator() => hasRole('ROLE_MODERATOR');
}
