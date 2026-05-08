/// [QUÉ ES]: Decorador que agrega logging a cualquier servicio
/// [PARA QUÉ SIRVE]: Envuelve servicios para registrar llamadas sin modificar la implementación original
/// [PATRÓN DE DISEÑO]: Decorator - Estructural
/// [RAZÓN Y UTILIDAD]: Permite agregar logging, debugging, métricas de rendimiento sin tocar el servicio original. 
/// Cumple OCP: extendemos funcionamiento sin modificar. Ejemplo: `LoggingServiceDecorator<ISuperheroeService>(originalService)`

import 'package:flutter/foundation.dart';

/// Decorador base para agregar logging a servicios
abstract class LoggingDecorator<T> {
  final T wrappedService;
  final String serviceName;

  LoggingDecorator(this.wrappedService, this.serviceName);

  /// Registra una operación con entrada
  void logOperation(String methodName, {dynamic args}) {
    debugPrint('✅ [$serviceName] → $methodName() iniciado');
    if (args != null) {
      debugPrint('   Argumentos: $args');
    }
  }

  /// Registra el resultado de una operación
  void logSuccess(String methodName, {dynamic result}) {
    debugPrint('✅ [$serviceName] ← $methodName() completado');
    if (result != null && result is! void) {
      debugPrint('   Resultado: ${result.toString().substring(0, 100)}...');
    }
  }

  /// Registra un error en una operación
  void logError(String methodName, dynamic error, StackTrace stackTrace) {
    debugPrint('❌ [$serviceName] ✗ $methodName() ERROR: $error');
    debugPrint('   Stack trace: $stackTrace');
  }

  /// Envoltura genérica para ejecutar un método con logging
  Future<R> executeWithLogging<R>(
    String methodName,
    Future<R> Function() operation, {
    dynamic args,
  }) async {
    try {
      logOperation(methodName, args: args);
      final result = await operation();
      logSuccess(methodName, result: result);
      return result;
    } catch (e, stackTrace) {
      logError(methodName, e, stackTrace);
      rethrow;
    }
  }
}

/// Ejemplo: Decorador para servicios que retornan genéricos
/// Puede extenderse para servicios específicos (IAuthService, ISuperheroeService, etc.)
class ServiceLogDecorator<T> extends LoggingDecorator<T> {
  ServiceLogDecorator(T wrappedService, String serviceName)
      : super(wrappedService, serviceName);
}
