/// [QUÉ ES]: Implementación concreta del servicio de superhéroes
/// [PARA QUÉ SIRVE]: Maneja CRUD de superhéroes con llamadas HTTP
/// [PATRÓN DE DISEÑO]: Singleton - Creacional | DIP de SOLID
/// [RAZÓN Y UTILIDAD]: Implementa ISuperheroeService. Preserva lógica HTTP exacta, 
/// headers con token, parseo seguro JSON y fallback de endpoints.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/factories/superheroe_factory.dart';
import '../../domain/models/superheroe.dart';
import '../../domain/services/i_superheroe_service.dart';
import 'auth_service_impl.dart';

class SuperheroeServiceImpl implements ISuperheroeService {
  static final SuperheroeServiceImpl _instance = SuperheroeServiceImpl._internal();

  late http.Client _httpClient;

  SuperheroeServiceImpl._internal() {
    _httpClient = http.Client();
  }

  factory SuperheroeServiceImpl() => _instance;

  @override
  Future<List<Superheroe>> fetchSuperheroes() async {
    debugPrint('DEBUG HEROES: GET ${ApiConfig.superheroesAll}');
    final response = await _httpClient.get(Uri.parse(ApiConfig.superheroesAll));
    debugPrint('DEBUG HEROES: status /all=${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        return List<Superheroe>.from(
          jsonData.map((item) => SuperheroeFactory.fromJson(item as Map<String, dynamic>)),
        );
      }

      if (jsonData is Map<String, dynamic> && jsonData['content'] is List) {
        return List<Superheroe>.from(
          (jsonData['content'] as List).map(
            (item) => SuperheroeFactory.fromJson(item as Map<String, dynamic>),
          ),
        );
      }

      throw Exception('Formato de respuesta invalido');
    }

    // Fallback: intenta endpoint alternativo
    debugPrint('DEBUG HEROES: fallback GET ${ApiConfig.superheroes}');
    final fallbackResponse = await _httpClient.get(Uri.parse(ApiConfig.superheroes));
    debugPrint('DEBUG HEROES: status fallback=${fallbackResponse.statusCode}');

    if (fallbackResponse.statusCode == 200) {
      final jsonData = jsonDecode(fallbackResponse.body);
      if (jsonData is List) {
        return List<Superheroe>.from(
          jsonData.map((item) => SuperheroeFactory.fromJson(item as Map<String, dynamic>)),
        );
      }
    }

    throw Exception('Error al cargar héroes');
  }

  @override
  Future<Superheroe> createSuperheroe(Superheroe heroe) async {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para crear superheroes');
    }

    debugPrint('DEBUG HEROES: POST ${ApiConfig.superheroes}');

    late http.Response response;
    try {
      response = await _httpClient.post(
        Uri.parse(ApiConfig.superheroes),
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
      return SuperheroeFactory.fromJson(jsonDecode(response.body));
    }
    throw Exception('Error al crear héroe');
  }

  @override
  Future<void> deleteSuperheroe(int id) async {
    final authService = AuthServiceImpl();
    final token = authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Debes iniciar sesion para eliminar superheroes');
    }

    debugPrint('DEBUG HEROES: DELETE ${ApiConfig.superheroes}/$id');

    final response = await _httpClient.delete(
      Uri.parse('${ApiConfig.superheroes}/$id'),
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
