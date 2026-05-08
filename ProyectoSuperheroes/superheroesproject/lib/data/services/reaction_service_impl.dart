/// [QUÉ ES]: Implementación concreta del servicio de reacciones
/// [PARA QUÉ SIRVE]: Maneja reacciones (likes, loves, etc.) de superhéroes
/// [PATRÓN DE DISEÑO]: Singleton - Creacional | DIP de SOLID
/// [RAZÓN Y UTILIDAD]: Implementa IReactionService. Mantiene reacciones predefinidas 
/// en memoria y maneja sincronización con API.

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/factories/superheroe_factory.dart';
import '../../domain/models/user.dart';
import '../../domain/models/reaction.dart';
import '../../domain/models/superheroe_reaction.dart';
import '../../domain/services/i_reaction_service.dart';
import 'auth_service_impl.dart';

class ReactionServiceImpl implements IReactionService {
  static final ReactionServiceImpl _instance = ReactionServiceImpl._internal();

  late http.Client _httpClient;

  // Reacciones predefinidas (inmutables)
  static const List<Reaction> _availableReactions = [
    Reaction(id: 1, description: 'REACTION_LIKE', emoji: '👍'),
    Reaction(id: 2, description: 'REACTION_LOVE', emoji: '❤️'),
    Reaction(id: 3, description: 'REACTION_HATE', emoji: '😠'),
    Reaction(id: 4, description: 'REACTION_SAD', emoji: '😢'),
    Reaction(id: 5, description: 'REACTION_ANGRY', emoji: '🔥'),
  ];

  ReactionServiceImpl._internal() {
    _httpClient = http.Client();
  }

  factory ReactionServiceImpl() => _instance;

  /// Construye headers con autenticación
  Map<String, String> _authHeaders({bool json = false}) {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
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
  Future<List<Reaction>> fetchAvailableReactions() async {
    // Retorna lista inmutable de reacciones predefinidas
    return List<Reaction>.unmodifiable(_availableReactions);
  }

  @override
  Future<List<SuperheroeReaction>> fetchReactionsBySuperheroe(int superheroeId) async {
    final response = await _httpClient.get(
      Uri.parse('${ApiConfig.reactions}/superheroe/$superheroeId'),
    );

    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las reacciones (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return List<SuperheroeReaction>.from(
      decoded
          .whereType<Map<String, dynamic>>()
          .map(SuperheroeReactionFactory.fromJson),
    );
  }

  @override
  Future<SuperheroeReaction?> getCurrentUserReaction(int superheroeId) async {
    final authService = AuthServiceImpl();
    final currentUser = authService.getUser();
    if (currentUser?.id == null) {
      return null;
    }

    try {
      final reactions = await fetchReactionsBySuperheroe(superheroeId);
      for (final reaction in reactions) {
        if (reaction.userId == currentUser!.id) {
          return reaction;
        }
      }
    } catch (e) {
      // Si hay error, retorna null en lugar de fallar
      return null;
    }

    return null;
  }

  @override
  Future<void> addReaction(int superheroeId, int reactionId) async {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para reaccionar');
    }

    final response = await _httpClient.post(
      Uri.parse('${ApiConfig.reactions}/create'),
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
  }

  @override
  Future<void> removeReaction(int superheroeId) async {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para quitar reacciones');
    }

    final response = await _httpClient.delete(
      Uri.parse('${ApiConfig.reactions}/superheroe/$superheroeId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('No se pudo quitar la reacción (${response.statusCode})');
    }
  }

  @override
  void dispose() => _httpClient.close();
}

/// Factory adicional para SuperheroeReaction
class SuperheroeReactionFactory {
  static SuperheroeReaction fromJson(Map<String, dynamic> json) {
    return SuperheroeReaction(
      id: _asInt(json['id']),
      userId: _asInt(json['userId'] ?? json['user_id'] ?? json['user']?['id']),
      username: json['username']?.toString() ?? json['user']?['username']?.toString() ?? '',
      reaction: _parseReaction(json['reaction']),
      user: _parseUser(json['user']),
    );
  }

  static Reaction? _parseReaction(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return ReactionFactory.fromJson(raw);
    }
    return null;
  }

  static User? _parseUser(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return UserFactory.fromJson(raw);
    }
    return null;
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

/// Factory para Reaction
class ReactionFactory {
  static Reaction fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: _asInt(json['id']),
      description: json['description']?.toString() ?? '',
      emoji: json['emoji']?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

/// Factory para User
class UserFactory {
  static User fromJson(Map<String, dynamic> json) {
    return User.fromJson(json);
  }

  static List<String> _parseRoles(dynamic roles) {
    if (roles is List) {
      return roles.map((r) => r.toString()).toList();
    }
    return [];
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
