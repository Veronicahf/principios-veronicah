/// [QUÉ ES]: Modelo compartido de interacciones de un superhéroe
/// [PARA QUÉ SIRVE]: Agrupa reacciones, comentarios y estado actual del usuario
/// [PATRÓN DE DISEÑO]: DTO / Shared Presentation Model
/// [RAZÓN Y UTILIDAD]: Evita pasar tipos privados entre widgets de distintos archivos

import '../../domain/models/comment.dart';
import '../../domain/models/reaction.dart';
import '../../domain/models/superheroe_reaction.dart';

class HeroInteractionData {
  final List<Reaction> availableReactions;
  final List<SuperheroeReaction> reactions;
  final List<Comment> comments;
  final Map<String, int> reactionCounts;
  final SuperheroeReaction? currentUserReaction;

  const HeroInteractionData({
    required this.availableReactions,
    required this.reactions,
    required this.comments,
    required this.reactionCounts,
    required this.currentUserReaction,
  });
}