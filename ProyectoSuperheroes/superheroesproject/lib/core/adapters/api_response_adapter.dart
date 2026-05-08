/// [QUÉ ES]: Adaptador que normaliza respuestas heterogéneas de la API
/// [PARA QUÉ SIRVE]: Convierte diferentes formatos de respuesta API a un formato estándar
/// [PATRÓN DE DISEÑO]: Adapter - Estructural
/// [RAZÓN Y UTILIDAD]: La API retorna respuestas inconsistentes (List, Map con 'content', etc.). El Adapter desacopla 
/// la lógica de negocio de estos cambios, cumpliendo con OCP: si la API cambia, solo cambia el adapter (SOLID).

/// Representa una respuesta genérica normalizada de la API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, {int statusCode = 200}) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String error, {int statusCode = 500}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

/// Adaptador para normalizar respuestas de lista desde la API
class ListResponseAdapter {
  /// Convierte cualquier respuesta en una lista normalizada
  /// Maneja formatos: List directo, Map con 'content', Map con 'data'
  static List<T> adaptList<T>(
    dynamic response, {
    required T Function(Map<String, dynamic>) parser,
  }) {
    try {
      if (response is List) {
        return response
            .map((item) => parser(item as Map<String, dynamic>))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        // Intenta con 'content'
        if (response['content'] is List) {
          return (response['content'] as List)
              .map((item) => parser(item as Map<String, dynamic>))
              .toList();
        }

        // Intenta con 'data'
        if (response['data'] is List) {
          return (response['data'] as List)
              .map((item) => parser(item as Map<String, dynamic>))
              .toList();
        }

        // Intenta con 'items'
        if (response['items'] is List) {
          return (response['items'] as List)
              .map((item) => parser(item as Map<String, dynamic>))
              .toList();
        }
      }

      throw Exception('Formato de respuesta no soportado');
    } catch (e) {
      throw Exception('Error al adaptar respuesta de lista: $e');
    }
  }

  /// Convierte una respuesta individual
  static T adaptSingle<T>(
    dynamic response, {
    required T Function(Map<String, dynamic>) parser,
  }) {
    try {
      if (response is Map<String, dynamic>) {
        return parser(response);
      }

      if (response is Map) {
        return parser(response.cast<String, dynamic>());
      }

      throw Exception('Formato de respuesta individual no soportado');
    } catch (e) {
      throw Exception('Error al adaptar respuesta individual: $e');
    }
  }
}
