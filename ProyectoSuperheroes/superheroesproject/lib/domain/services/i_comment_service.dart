/// [QUÉ ES]: Interfaz que define el contrato del servicio de comentarios
/// [PARA QUÉ SIRVE]: Abstrae la implementación de operaciones CRUD de comentarios
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Cumple DIP (SOLID): desacopla presentación de implementación. Permite testing 
/// con mocks y facilita extensiones como caché de comentarios.

import '../models/comment.dart';

abstract class ICommentService {
  /// Obtiene comentarios de un superhéroe
  Future<List<Comment>> fetchCommentsBySuperheroe(int superheroeId);

  /// Crea un nuevo comentario
  Future<Comment> createComment(int superheroeId, String text);

  /// Elimina un comentario
  Future<void> deleteComment(int commentId);

  /// Limpia recursos
  void dispose();
}
