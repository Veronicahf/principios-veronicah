/// [QUÉ ES]: Interfaz que define el contrato para acceso a datos de reacciones
/// [PARA QUÉ SIRVE]: Abstrae la fuente de datos de reacciones
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Cumple DIP (SOLID): facilita testing y extensibilidad.

import '../models/reaction.dart';
import '../models/superheroe_reaction.dart';

abstract class IReactionRepository {
  Future<List<Reaction>> fetchAvailableReactions();
  Future<List<SuperheroeReaction>> fetchReactionsBySuperheroe(int superheroeId);
  Future<SuperheroeReaction?> getCurrentUserReaction(int superheroeId);
  Future<void> addReaction(int superheroeId, int reactionId);
  Future<void> removeReaction(int superheroeId);
  void dispose();
}
