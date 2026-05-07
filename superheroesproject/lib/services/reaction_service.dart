import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/reaction.dart';
import '../models/superheroe_reaction.dart';
import '../repositories/reaction_repository.dart';
import 'auth_service.dart';

class ReactionService implements IReactionRepository {
  static final ReactionService _instance = ReactionService._internal();

  final String baseUrl = 'https://superheroes-api-iy4v.onrender.com/api';
  late http.Client _httpClient;

  ReactionService._internal() {
    _httpClient = http.Client();
  }

  factory ReactionService() => _instance;

  static const List<Reaction> _availableReactions = [
    Reaction(id: 1, description: 'REACTION_LIKE'),
    Reaction(id: 2, description: 'REACTION_LOVE'),
    Reaction(id: 3, description: 'REACTION_HATE'),
    Reaction(id: 4, description: 'REACTION_SAD'),
    Reaction(id: 5, description: 'REACTION_ANGRY'),
  ];

  @override
  Future<List<Reaction>> fetchAvailableReactions() async {
    return List.unmodifiable(_availableReactions);
  }

  Map<String, String> _authHeaders({bool json = false}) {
    final token = AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para ver reacciones');
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
  Future<List<SuperheroeReaction>> fetchReactionsBySuperheroe(int superheroeId) async {
    final response = await _httpClient.get(
      Uri.parse('$baseUrl/reactions/superheroe/$superheroeId'),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las reacciones (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SuperheroeReaction.fromJson)
        .toList();
  }

  Future<SuperheroeReaction?> getCurrentUserReaction(int superheroeId) async {
    final currentUser = AuthService().getUser();
    if (currentUser?.id == null) {
      return null;
    }

    final reactions = await fetchReactionsBySuperheroe(superheroeId);
    for (final reaction in reactions) {
      if (reaction.userId == currentUser!.id) {
        return reaction;
      }
    }
    return null;
  }

  @override
  Future<SuperheroeReaction> createOrUpdateReaction(int superheroeId, int reactionId) async {
    final token = AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para reaccionar');
    }

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/reactions/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'superheroeId': superheroeId,
        'reactionId': reactionId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('No se pudo guardar la reacción (${response.statusCode})');
    }

    return SuperheroeReaction.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> removeMyReaction(int superheroeId) async {
    final response = await _httpClient.delete(
      Uri.parse('$baseUrl/reactions/superheroe/$superheroeId'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('No se pudo quitar la reacción (${response.statusCode})');
    }
  }

  @override
  void dispose() => _httpClient.close();
}