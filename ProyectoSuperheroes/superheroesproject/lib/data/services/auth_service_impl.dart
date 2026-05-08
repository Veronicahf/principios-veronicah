/// [QUÉ ES]: Implementación concreta del servicio de autenticación
/// [PARA QUÉ SIRVE]: Maneja login, registro y gestión de tokens
/// [PATRÓN DE DISEÑO]: Singleton - Creacional | DIP de SOLID
/// [RAZÓN Y UTILIDAD]: Implementa IAuthService. Singleton garantiza única instancia. 
/// Maneja SharedPreferences de forma segura, token storage y User serialization.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/user.dart';
import '../../domain/services/i_auth_service.dart';

class AuthServiceImpl implements IAuthService {
  static final AuthServiceImpl _instance = AuthServiceImpl._internal();

  late http.Client _httpClient;
  SharedPreferences? _prefs;

  AuthServiceImpl._internal() {
    _httpClient = http.Client();
  }

  factory AuthServiceImpl() {
    return _instance;
  }

  /// Asegura que SharedPreferences esté inicializado
  Future<void> _ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> init() async {
    await _ensureInit();
  }

  @override
  Future<User> login(String username, String password) async {
    await _ensureInit();

    debugPrint('DEBUG LOGIN: username=$username');
    final response = await _httpClient.post(
      Uri.parse(ApiConfig.authSignIn),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    debugPrint('DEBUG LOGIN: status=${response.statusCode}');
    debugPrint('DEBUG LOGIN: body=${_shorten(response.body)}');

    if (response.statusCode != 200) {
      throw Exception('Login invalido (${response.statusCode})');
    }

    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    final token = jsonData['accessToken']?.toString() ?? '';
    if (token.isEmpty) {
      throw Exception('No se recibio token');
    }

    final user = User.fromJson({
      'id': jsonData['id'],
      'username': jsonData['username'],
      'email': jsonData['email'],
      'roles': jsonData['roles'],
    });

    await _prefs!.setString(StorageKeys.authToken, token);
    await _prefs!.setString(StorageKeys.authUser, jsonEncode(user.toJson()));

    debugPrint('DEBUG LOGIN: token saved len=${token.length}');
    debugPrint('DEBUG LOGIN: user saved=${user.username}');

    return user;
  }

  @override
  Future<User> register(
    String username,
    String email,
    String password, {
    List<String>? roles,
  }) async {
    await _ensureInit();
    debugPrint('DEBUG SIGNUP: username=$username email=$email');

    final payload = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
    };

    if (roles != null && roles.isNotEmpty) {
      payload['role'] = roles;
    }

    final response = await _httpClient.post(
      Uri.parse(ApiConfig.authSignUp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('DEBUG SIGNUP: status=${response.statusCode}');
    debugPrint('DEBUG SIGNUP: body=${_shorten(response.body)}');

    if (response.statusCode != 200) {
      throw Exception('No se pudo registrar (${response.statusCode}): ${response.body}');
    }

    // Si el registro es exitoso, intenta hacer login automático
    return login(username, password);
  }

  @override
  String? getToken() {
    if (_prefs == null) {
      return null;
    }
    return _prefs!.getString(StorageKeys.authToken);
  }

  @override
  User? getUser() {
    if (_prefs == null) {
      return null;
    }
    final userJson = _prefs!.getString(StorageKeys.authUser);
    if (userJson == null) {
      return null;
    }
    return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  @override
  bool isAuthenticated() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    await _ensureInit();
    await _prefs!.remove(StorageKeys.authToken);
    await _prefs!.remove(StorageKeys.authUser);
    debugPrint('DEBUG LOGOUT: local session cleared');
  }

  @override
  void dispose() {
    _httpClient.close();
  }

  /// Utilidad para acortar strings en logs
  String _shorten(String text, [int max = 220]) {
    if (text.length <= max) {
      return text;
    }
    return '${text.substring(0, max)}...';
  }
}
