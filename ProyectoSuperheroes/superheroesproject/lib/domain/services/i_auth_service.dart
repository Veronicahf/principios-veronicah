/// [QUÉ ES]: Interfaz que define el contrato del servicio de autenticación
/// [PARA QUÉ SIRVE]: Abstrae la implementación de autenticación
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Cumple DIP (SOLID): servicios y presentación dependen de la interfaz, no de la implementación. 
/// Facilita testing con mocks y permite cambiar implementaciones sin afectar dependientes.

import '../models/user.dart';

abstract class IAuthService {
  /// Inicializa el servicio (carga preferencias, etc.)
  Future<void> init();

  /// Login con usuario y contraseña
  Future<User> login(String username, String password);

  /// Registro de nuevo usuario
  Future<User> register(String username, String email, String password);

  /// Logout del usuario actual
  Future<void> logout();

  /// Verifica si está autenticado
  bool isAuthenticated();

  /// Obtiene el usuario actual
  User? getUser();

  /// Obtiene el token de autenticación
  String? getToken();

  /// Limpia recursos
  void dispose();
}
