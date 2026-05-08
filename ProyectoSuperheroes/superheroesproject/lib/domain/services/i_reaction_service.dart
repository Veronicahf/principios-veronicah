/// [QUÉ ES]: Interfaz que define el contrato del servicio de reacciones
/// [PARA QUÉ SIRVE]: Abstrae la implementación de operaciones de reacciones y emojis
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Cumple DIP (SOLID): desacopla presentación de implementación. Facilita testing 
/// y permite cambiar el sistema de reacciones sin afectar la UI.

import '../models/reaction.dart';
import '../models/superheroe_reaction.dart';

abstract class IReactionService {
  /// Obtiene reacciones disponibles
  Future<List<Reaction>> fetchAvailableReactions();

  /// Obtiene reacciones de un superhéroe específico
  Future<List<SuperheroeReaction>> fetchReactionsBySuperheroe(int superheroeId);

  /// Obtiene reacción del usuario actual para un superhéroe
  Future<SuperheroeReaction?> getCurrentUserReaction(int superheroeId);

  /// Agrega una reacción
  Future<void> addReaction(int superheroeId, int reactionId);

  /// Elimina una reacción
  Future<void> removeReaction(int superheroeId);

  /// Limpia recursos
  void dispose();
}
