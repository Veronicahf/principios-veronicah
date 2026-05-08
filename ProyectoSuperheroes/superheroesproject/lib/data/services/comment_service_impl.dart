/// [QUÉ ES]: Implementación concreta del servicio de comentarios
/// [PARA QUÉ SIRVE]: Maneja creación, lectura y eliminación de comentarios
/// [PATRÓN DE DISEÑO]: Singleton - Creacional | DIP de SOLID
/// [RAZÓN Y UTILIDAD]: Implementa ICommentService. Preserva parseo seguro JSON 
/// y manejo de headers con autenticación.

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/factories/superheroe_factory.dart';
import '../../domain/models/comment.dart';
import '../../domain/services/i_comment_service.dart';
import 'auth_service_impl.dart';

class CommentServiceImpl implements ICommentService {
  static final CommentServiceImpl _instance = CommentServiceImpl._internal();

  late http.Client _httpClient;

  CommentServiceImpl._internal() {
    _httpClient = http.Client();
  }

  factory CommentServiceImpl() => _instance;

  /// Construye headers con autenticación
  Map<String, String> _authHeaders({bool json = false}) {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para ver comentarios');
    }

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
    };

    if (json) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  @override
  Future<List<Comment>> fetchCommentsBySuperheroe(int superheroeId) async {
    final response = await _httpClient.get(
      Uri.parse('${ApiConfig.comments}/superheroe/$superheroeId'),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los comentarios (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return List<Comment>.from(
      decoded.whereType<Map<String, dynamic>>().map(CommentFactory.fromJson),
    );
  }

  @override
  Future<Comment> createComment(int superheroeId, String text) async {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para comentar');
    }

    final response = await _httpClient.post(
      Uri.parse('${ApiConfig.comments}/create'),
      headers: _authHeaders(json: true),
      body: jsonEncode({
        'superheroeId': superheroeId,
        'content': text,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo crear el comentario (${response.statusCode})');
    }

    return Comment(
      id: 0,
      content: text,
      authorUsername: authService.getUser()?.username ?? '',
    );
  }

  @override
  Future<void> deleteComment(int commentId) async {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para eliminar comentarios');
    }

    final response = await _httpClient.delete(
      Uri.parse('${ApiConfig.comments}/$commentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 403) {
        throw Exception('No eres el autor del comentario');
      }
      if (response.statusCode == 404) {
        throw Exception('El comentario no existe');
      }
      throw Exception('Error al eliminar comentario (${response.statusCode})');
    }
  }

  @override
  void dispose() => _httpClient.close();
}
