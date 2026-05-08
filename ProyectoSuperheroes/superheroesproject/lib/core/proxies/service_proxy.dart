/// [QUÉ ES]: Proxy que controla el acceso a servicios
/// [PARA QUÉ SIRVE]: Actúa como intermediario entre clientes y servicios para lazy-loading, control de acceso, etc.
/// [PATRÓN DE DISEÑO]: Proxy - Estructural
/// [RAZÓN Y UTILIDAD]: Permite lazy-loading de servicios (crear solo cuando se usan), control de acceso basado en 
/// permisos/autenticación, y caching a nivel de proxy. Cumple SRP e ISP (SOLID): proxy responsable del control de acceso.

import '../../domain/services/i_auth_service.dart';

/// Proxy que controla el acceso a servicios basado en autenticación
class AuthenticationProxy<T> {
  final T target;
  final IAuthService authService;

  AuthenticationProxy({required this.target, required this.authService});

  /// Verifica si el usuario está autenticado
  /// Lanza excepción si no está autenticado
  void ensureAuthenticated(String operationName) {
    if (!authService.isAuthenticated()) {
      throw UnauthorizedException(
        'No autenticado. La operación "$operationName" requiere autenticación.',
      );
    }
  }

  /// Obtiene el servicio target si está autenticado
  T? getIfAuthenticated(String operationName) {
    try {
      ensureAuthenticated(operationName);
      return target;
    } catch (e) {
      return null;
    }
  }
}

/// Proxy para lazy-loading de servicios (instanciación diferida)
class LazyServiceProxy<T> {
  T? _instance;
  final T Function() _factory;

  LazyServiceProxy(this._factory);

  /// Obtiene la instancia (la crea la primera vez)
  T getInstance() {
    _instance ??= _factory();
    return _instance!;
  }

  /// Reinicia el proxy (fuerza re-creación en próximo acceso)
  void reset() {
    _instance = null;
  }
}

/// Proxy con rate limiting (limita llamadas por unidad de tiempo)
class RateLimitingProxy<T> {
  final T target;
  final Map<String, List<DateTime>> _callHistory = {};
  final int maxCallsPerMinute;

  RateLimitingProxy({
    required this.target,
    this.maxCallsPerMinute = 60,
  });

  /// Verifica si se ha excedido el rate limit para una operación
  bool isRateLimited(String operationName) {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    _callHistory.putIfAbsent(operationName, () => []);

    // Limpia registros antiguos
    _callHistory[operationName]!.removeWhere((time) => time.isBefore(oneMinuteAgo));

    // Verifica si se excedió el límite
    if (_callHistory[operationName]!.length >= maxCallsPerMinute) {
      return true;
    }

    // Registra la llamada actual
    _callHistory[operationName]!.add(now);
    return false;
  }

  /// Envoltura segura con rate limiting
  Future<R> executeWithRateLimit<R>(
    String operationName,
    Future<R> Function() operation,
  ) async {
    if (isRateLimited(operationName)) {
      throw RateLimitExceededException(
        'Se ha excedido el límite de $maxCallsPerMinute llamadas por minuto para "$operationName"',
      );
    }
    return operation();
  }
}

/// Excepción: No autenticado
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Excepción: Rate limit excedido
class RateLimitExceededException implements Exception {
  final String message;
  RateLimitExceededException(this.message);

  @override
  String toString() => 'RateLimitExceededException: $message';
}
