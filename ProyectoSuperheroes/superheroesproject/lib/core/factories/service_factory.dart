/// [QUÉ ES]: Abstract Factory que produce todas las instancias de servicios de la aplicación
/// [PARA QUÉ SIRVE]: Centraliza la creación de servicios con Singleton garantizado
/// [PATRÓN DE DISEÑO]: Abstract Factory - Creacional
/// [RAZÓN Y UTILIDAD]: Desacopla la creación de servicios, permite cambiar implementaciones fácilmente, 
/// garantiza instancias Singleton únnicas y cumple DIP (SOLID): el código depende de la factory, no de clases concretas.

import '../../domain/services/i_auth_service.dart';
import '../../domain/services/i_superheroe_service.dart';
import '../../domain/services/i_comment_service.dart';
import '../../domain/services/i_reaction_service.dart';
import '../../data/services/auth_service_impl.dart';
import '../../data/services/superheroe_service_impl.dart';
import '../../data/services/comment_service_impl.dart';
import '../../data/services/reaction_service_impl.dart';

/// Factory singleton que produce todos los servicios
class ServiceFactory {
  static final ServiceFactory _instance = ServiceFactory._internal();

  late IAuthService _authService;
  late ISuperheroeService _superheroService;
  late ICommentService _commentService;
  late IReactionService _reactionService;

  factory ServiceFactory() {
    return _instance;
  }

  ServiceFactory._internal() {
    _initializeServices();
  }

  void _initializeServices() {
    _authService = AuthServiceImpl();
    _superheroService = SuperheroeServiceImpl();
    _commentService = CommentServiceImpl();
    _reactionService = ReactionServiceImpl();
  }

  /// Obtiene la instancia Singleton del servicio de autenticación
  IAuthService getAuthService() => _authService;

  /// Obtiene la instancia Singleton del servicio de superhéroes
  ISuperheroeService getSuperheroeService() => _superheroService;

  /// Obtiene la instancia Singleton del servicio de comentarios
  ICommentService getCommentService() => _commentService;

  /// Obtiene la instancia Singleton del servicio de reacciones
  IReactionService getReactionService() => _reactionService;

  /// Obtiene todos los servicios en un objeto contenedor
  AllServices getAllServices() {
    return AllServices(
      auth: _authService,
      superheroe: _superheroService,
      comment: _commentService,
      reaction: _reactionService,
    );
  }

  /// Reinicia todos los servicios (útil para testing o limpieza)
  void reset() {
    _initializeServices();
  }
}

/// Contenedor que encapsula todos los servicios
class AllServices {
  final IAuthService auth;
  final ISuperheroeService superheroe;
  final ICommentService comment;
  final IReactionService reaction;

  AllServices({
    required this.auth,
    required this.superheroe,
    required this.comment,
    required this.reaction,
  });
}
