/// [QUÉ ES]: Facade que simplifica el acceso a múltiples servicios
/// [PARA QUÉ SIRVE]: Proporciona una interfaz unificada y simplificada para operaciones complejas que involucran varios servicios
/// [PATRÓN DE DISEÑO]: Facade - Estructural
/// [RAZÓN Y UTILIDAD]: La presentación (UI) accede a un único punto (AppCoordinator) en lugar de múltiples servicios. 
/// Reduce complejidad, desacopla UI de detalles de servicios. Cumple SRP: facade responsable de orquestar, no de negocio.

import '../../domain/models/superheroe.dart';
import '../../domain/models/comment.dart';
import '../../domain/models/reaction.dart';
import '../../domain/models/superheroe_reaction.dart';
import '../../domain/models/user.dart';
import '../../domain/services/i_auth_service.dart';
import '../../domain/services/i_superheroe_service.dart';
import '../../domain/services/i_comment_service.dart';
import '../../domain/services/i_reaction_service.dart';
import '../factories/service_factory.dart';

/// Facade principal que coordina toda la lógica de la aplicación
class AppCoordinator {
  static final AppCoordinator _instance = AppCoordinator._internal();

  late final IAuthService _authService;
  late final ISuperheroeService _superheroService;
  late final ICommentService _commentService;
  late final IReactionService _reactionService;

  factory AppCoordinator() {
    return _instance;
  }

  AppCoordinator._internal() {
    _initializeServices();
  }

  void _initializeServices() {
    final factory = ServiceFactory();
    _authService = factory.getAuthService();
    _superheroService = factory.getSuperheroeService();
    _commentService = factory.getCommentService();
    _reactionService = factory.getReactionService();
  }

  // ============= AUTENTICACIÓN =============

  /// Login del usuario
  Future<User> login(String username, String password) async {
    return _authService.login(username, password);
  }

  /// Registro de usuario
  Future<User> register(String username, String email, String password) async {
    return _authService.register(username, email, password);
  }

  /// Logout
  Future<void> logout() async {
    return _authService.logout();
  }

  /// Verifica si está autenticado
  bool isAuthenticated() {
    return _authService.isAuthenticated();
  }

  /// Obtiene el usuario actual
  User? getCurrentUser() {
    return _authService.getUser();
  }

  // ============= SUPERHÉROES =============

  /// Obtiene todos los superhéroes
  Future<List<Superheroe>> getAllSuperheroes() async {
    return _superheroService.fetchSuperheroes();
  }

  /// Crea un nuevo superhéroe
  Future<Superheroe> createSuperheroe(Superheroe heroe) async {
    return _superheroService.createSuperheroe(heroe);
  }

  /// Elimina un superhéroe
  Future<void> deleteSuperheroe(int id) async {
    return _superheroService.deleteSuperheroe(id);
  }

  // ============= COMENTARIOS =============

  /// Obtiene comentarios de un superhéroe
  Future<List<Comment>> getCommentsForSuperheroe(int superheroId) async {
    return _commentService.fetchCommentsBySuperheroe(superheroId);
  }

  /// Crea un comentario
  Future<Comment> createComment(int superheroId, String text) async {
    return _commentService.createComment(superheroId, text);
  }

  /// Elimina un comentario
  Future<void> deleteComment(int commentId) async {
    return _commentService.deleteComment(commentId);
  }

  // ============= REACCIONES =============

  /// Obtiene reacciones disponibles
  Future<List<Reaction>> getAvailableReactions() async {
    return _reactionService.fetchAvailableReactions();
  }

  /// Obtiene reacciones de un superhéroe
  Future<List<SuperheroeReaction>> getReactionsForSuperheroe(int superheroId) async {
    return _reactionService.fetchReactionsBySuperheroe(superheroId);
  }

  /// Obtiene reacción del usuario actual
  Future<SuperheroeReaction?> getCurrentUserReaction(int superheroId) async {
    return _reactionService.getCurrentUserReaction(superheroId);
  }

  /// Agrega una reacción
  Future<void> addReaction(int superheroId, int reactionId) async {
    return _reactionService.addReaction(superheroId, reactionId);
  }

  /// Elimina una reacción
  Future<void> removeReaction(int superheroId) async {
    return _reactionService.removeReaction(superheroId);
  }

  // ============= UTILIDADES =============

  /// Reinicia el coordinador (limpia servicios)
  void reset() {
    _initializeServices();
  }

  /// Inicializa la aplicación (setup inicial)
  Future<void> initApp() async {
    await _authService.init();
  }

  /// Verifica conectividad y estado de servicios
  Future<bool> checkHealth() async {
    try {
      // Intenta operación simple para verificar conectividad
      if (isAuthenticated()) {
        await getAllSuperheroes();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
