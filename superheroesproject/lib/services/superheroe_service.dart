import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/superheroe.dart';
import '../repositories/superheroe_repository.dart';
import 'auth_service.dart';

class SuperheroeService implements ISuperheroeRepository {
  static final SuperheroeService _instance = SuperheroeService._internal();

  // Reemplaza esto con tu URL de Render de Superhéroes
  final String baseUrl = 'https://superheroes-api-iy4v.onrender.com/api';
  late http.Client _httpClient;

  SuperheroeService._internal() {
    _httpClient = http.Client();
  }

  factory SuperheroeService() => _instance;

  @override
  Future<List<Superheroe>> fetchSuperheroes() async {
    debugPrint('DEBUG HEROES: GET $baseUrl/superheroes/all');
    final response = await _httpClient.get(Uri.parse('$baseUrl/superheroes/all'));
    debugPrint('DEBUG HEROES: status /all=${response.statusCode}');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        return jsonData
            .map((item) => Superheroe.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (jsonData is Map<String, dynamic> && jsonData['content'] is List) {
        return (jsonData['content'] as List)
            .map((item) => Superheroe.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Formato de respuesta invalido');
    }

    debugPrint('DEBUG HEROES: fallback GET $baseUrl/superheroes');
    final fallbackResponse = await _httpClient.get(Uri.parse('$baseUrl/superheroes'));
    debugPrint('DEBUG HEROES: status fallback=${fallbackResponse.statusCode}');
    if (fallbackResponse.statusCode == 200) {
      final jsonData = jsonDecode(fallbackResponse.body);
      if (jsonData is List) {
        return jsonData
            .map((item) => Superheroe.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    throw Exception('Error al cargar héroes');
  }

  @override
  Future<Superheroe> createSuperheroe(Superheroe heroe) async {
    final token = AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para crear superheroes');
    }

    debugPrint('DEBUG HEROES: POST $baseUrl/superheroes');

    late http.Response response;
    try {
      response = await _httpClient.post(
        Uri.parse('$baseUrl/superheroes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': heroe.nombre,
          'habilidades': heroe.habilidades,
          'debilidades': heroe.debilidades,
          'enemigos': heroe.enemigos,
          'urlPhoto': heroe.urlPhoto,
        }),
      );
    } catch (e) {
      debugPrint('DEBUG HEROES: create network error=$e');
      throw Exception(
        'Error de red/CORS al crear. En web, revisa preflight OPTIONS en backend.',
      );
    }

    debugPrint('DEBUG HEROES: create status=${response.statusCode}');
    debugPrint('DEBUG HEROES: create body=${_shorten(response.body)}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Superheroe.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear héroe');
  }

  @override
  Future<void> deleteSuperheroe(int id) async {
    final token = AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para eliminar superheroes');
    }

    debugPrint('DEBUG HEROES: DELETE $baseUrl/superheroes/$id');

    final response = await _httpClient.delete(
      Uri.parse('$baseUrl/superheroes/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('DEBUG HEROES: delete status=${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 403) {
        throw Exception('No eres el propietario de esta publicación');
      }
      if (response.statusCode == 404) {
        throw Exception('El superheroe no existe');
      }
      throw Exception('Error al eliminar (${response.statusCode})');
    }
  }

  @override
  void dispose() => _httpClient.close();

  String _shorten(String text, [int max = 220]) {
    if (text.length <= max) {
      return text;
    }
    return '${text.substring(0, max)}...';
  }
}