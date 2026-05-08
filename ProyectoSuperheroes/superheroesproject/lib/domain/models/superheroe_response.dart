/// [QUÉ ES]: Modelo de respuesta genérica para actualizaciones
/// [PARA QUÉ SIRVE]: Encapsula respuestas del servidor cuando se crean/actualizan superhéroes
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Modelo de dominio para respuestas de API

class SuperheroeResponse {
  final bool success;
  final String? message;
  final int? id;

  const SuperheroeResponse({
    required this.success,
    this.message,
    this.id,
  });

  factory SuperheroeResponse.fromJson(Map<String, dynamic> json) {
    return SuperheroeResponse(
      success: json['success'] ?? true,
      message: json['message']?.toString(),
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
    );
  }
}
