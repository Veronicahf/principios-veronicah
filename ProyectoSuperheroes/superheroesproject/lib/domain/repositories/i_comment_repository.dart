/// [QUÉ ES]: Interfaz que define el contrato para acceso a datos de comentarios
/// [PARA QUÉ SIRVE]: Abstrae la fuente de datos de comentarios
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Cumple DIP (SOLID): facilita testing y cambio de fuente de datos.

import '../models/comment.dart';

abstract class ICommentRepository {
  Future<List<Comment>> fetchCommentsBySuperheroe(int superheroeId);
  Future<Comment> createComment(int superheroeId, String text);
  Future<void> deleteComment(int commentId);
  void dispose();
}
