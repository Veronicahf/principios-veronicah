/// [QUÉ ES]: Modelo de dominio que representa una Reacción de Superhéroe
/// [PARA QUÉ SIRVE]: Encapsula la relación entre usuario, superhéroe y reacción
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Modelo puro de dominio que agrupa contexto de reacción

import 'reaction.dart';
import 'user.dart';

class SuperheroeReaction {
  final int id;
  final int userId;
  final String username;
  final Reaction? reaction;
  final User? user;

  const SuperheroeReaction({
    required this.id,
    required this.userId,
    this.username = '',
    this.reaction,
    this.user,
  });

  factory SuperheroeReaction.fromJson(Map<String, dynamic> json) {
    return SuperheroeReaction(
      id: _asInt(json['id']),
      userId: _asInt(json['userId'] ?? json['user_id'] ?? json['user']?['id']),
      username: json['username']?.toString() ?? json['user']?['username']?.toString() ?? '',
      reaction: _parseReaction(json['reaction']),
      user: _parseUser(json['user']),
    );
  }

  String get reactionLabel {
    return reaction?.description ?? 'Sin reacción';
  }

  static Reaction? _parseReaction(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Reaction.fromJson(raw);
    }
    return null;
  }

  static User? _parseUser(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return User.fromJson(raw);
    }
    return null;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
