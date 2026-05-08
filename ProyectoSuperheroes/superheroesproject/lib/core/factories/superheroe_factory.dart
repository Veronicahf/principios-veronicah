/// [QUÉ ES]: Factory Method para crear instancias de Superheroe desde JSON
/// [PARA QUÉ SIRVE]: Centraliza la lógica de parsing y creación de objetos Superheroe
/// [PATRÓN DE DISEÑO]: Factory Method - Creacional
/// [RAZÓN Y UTILIDAD]: Desacopla la lógica de creación del modelo, permitiendo cambios en parsing sin tocar 
/// el modelo. Facilita testeo y escalabilidad si hay nuevos tipos. Cumple SRP y OCP (SOLID).

import '../../domain/models/superheroe.dart';
import '../../domain/models/comment.dart';
import '../../domain/models/superheroe_reaction.dart';
import '../../domain/models/reaction.dart';
import '../../domain/models/user.dart';

class SuperheroeFactory {
  /// Crea un Superheroe desde JSON (respuesta API)
  static Superheroe fromJson(Map<String, dynamic> json) {
    final postedBy = json['postedBy'];
    String postedByUsername = '';
    User? postedByUser;

    if (postedBy is Map<String, dynamic>) {
      postedByUsername = postedBy['username']?.toString() ?? '';
      postedByUser = UserFactory.fromJson(postedBy);
    } else if (postedBy is String) {
      postedByUsername = postedBy;
    }

    final likes = _parseSuperheroeReactions(json['likes']);
    final comments = _parseComments(json['comments']);

    return Superheroe(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      habilidades: json['habilidades'] ?? '',
      debilidades: json['debilidades'] ?? '',
      enemigos: json['enemigos'] ?? '',
      urlPhoto: json['urlPhoto'] ?? '',
      postedByUsername: postedByUsername,
      postedBy: postedByUser,
      likes: likes,
      comments: comments,
    );
  }

  /// Convierte Superheroe a JSON para enviar a API
  static Map<String, dynamic> toJson(Superheroe heroe) {
    return {
      'nombre': heroe.nombre,
      'habilidades': heroe.habilidades,
      'debilidades': heroe.debilidades,
      'enemigos': heroe.enemigos,
      'urlPhoto': heroe.urlPhoto,
    };
  }

  static List<SuperheroeReaction> _parseSuperheroeReactions(dynamic data) {
    if (data is! List) return [];
    return data
        .map((item) {
          if (item is Map<String, dynamic>) {
            final reactionData = item['reaction'];
            Reaction? reaction;
            if (reactionData is Map<String, dynamic>) {
              reaction = ReactionFactory.fromJson(reactionData);
            }
            return SuperheroeReaction(
              id: item['id'] ?? 0,
              userId: item['userId'] ?? 0,
              username: item['username'] ?? '',
              reaction: reaction,
            );
          }
          return null;
        })
        .whereType<SuperheroeReaction>()
        .toList();
  }

  static List<Comment> _parseComments(dynamic data) {
    if (data is! List) return [];
    return data
        .map((item) {
          if (item is Map<String, dynamic>) {
            return CommentFactory.fromJson(item);
          }
          return null;
        })
        .whereType<Comment>()
        .toList();
  }
}

class UserFactory {
  static User fromJson(Map<String, dynamic> json) {
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
}

class ReactionFactory {
  static Reaction fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '',
    );
  }
}

class CommentFactory {
  static Comment fromJson(Map<String, dynamic> json) {
    // Delegate to domain model factory for resilient parsing
    return Comment.fromJson(json);
  }
}
