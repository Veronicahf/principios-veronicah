import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/comment.dart';
import '../repositories/comment_repository.dart';
import 'auth_service.dart';

class CommentService implements ICommentRepository {
  static final CommentService _instance = CommentService._internal();

  final String baseUrl = 'https://superheroes-api-iy4v.onrender.com/api';
  late http.Client _httpClient;

  CommentService._internal() {
    _httpClient = http.Client();
  }

  factory CommentService() => _instance;

  Map<String, String> _authHeaders({bool json = false}) {
    final token = AuthService().getToken();
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
      Uri.parse('$baseUrl/comments/superheroe/$superheroeId'),
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar los comentarios (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }

  @override
  Future<Comment> createComment(int superheroeId, String content) async {
    final token = AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para comentar');
    }

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/comments/create'),
      headers: _authHeaders(json: true),
      body: jsonEncode({
        'superheroeId': superheroeId,
        'content': content,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo crear el comentario (${response.statusCode})');
    }

    return Comment(
      id: 0,
      content: content,
    );
  }

  @override
  Future<int> countCommentsBySuperheroe(int superheroeId) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/comments/superheroe/$superheroeId/count'),
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudo contar los comentarios (${response.statusCode})');
    }

    return int.tryParse(response.body.trim()) ?? 0;
  }

  @override
  void dispose() => _httpClient.close();
}