/// [QUÉ ES]: Modelo de dominio que representa un Superhéroe
/// [PARA QUÉ SIRVE]: Encapsula datos y comportamiento central de superhéroes
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Modelo puro de negocio, independiente de capas de datos o presentación. 
/// Contiene métodos de análisis y cálculo (SOLID - SRP).

import 'comment.dart';
import 'superheroe_reaction.dart';
import 'user.dart';

class Superheroe {
  final int id;
  final String nombre;
  final String habilidades;
  final String debilidades;
  final String enemigos;
  final String urlPhoto;
  final String postedByUsername;
  final User? postedBy;
  final List<SuperheroeReaction> likes;
  final List<Comment> comments;

  Superheroe({
    required this.id,
    required this.nombre,
    required this.habilidades,
    required this.debilidades,
    required this.enemigos,
    required this.urlPhoto,
    this.postedByUsername = '',
    this.postedBy,
    this.likes = const [],
    this.comments = const [],
  });

  factory Superheroe.fromJson(Map<String, dynamic> json) {
    final postedBy = json['postedBy'];
    String postedByUsername = '';
    User? postedByUser;

    if (postedBy is Map<String, dynamic>) {
      postedByUsername = postedBy['username']?.toString() ?? '';
      postedByUser = User.fromJson(postedBy);
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

  // ============= PROPIEDADES COMPUTADAS =============

  int get reactionCount => likes.length;
  int get commentCount => comments.length;

  bool get hasReactions => likes.isNotEmpty;
  bool get hasComments => comments.isNotEmpty;

  // ============= MÉTODOS DE ANÁLISIS =============

  Map<String, int> reactionBreakdown() {
    final breakdown = <String, int>{};
    for (final reaction in likes) {
      final key = reaction.reaction?.description ?? 'UNKNOWN';
      breakdown[key] = (breakdown[key] ?? 0) + 1;
    }
    return breakdown;
  }

  List<Comment> getCommentsByAuthor(String authorUsername) {
    return comments
        .where((c) => c.authorUsername.toLowerCase() == authorUsername.toLowerCase())
        .toList();
  }

  // ============= PARSING PRIVADO =============

  static List<SuperheroeReaction> _parseSuperheroeReactions(dynamic raw) {
    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(SuperheroeReaction.fromJson)
        .toList();
  }

  static List<Comment> _parseComments(dynamic raw) {
    if (raw is! List) {
      return const [];
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
