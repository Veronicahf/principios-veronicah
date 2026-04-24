import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  final String baseUrl = 'https://superheroes-api-iy4v.onrender.com/api';
  late http.Client _httpClient;
  SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthService._internal() {
    _httpClient = http.Client();
  }

  factory AuthService() {
    return _instance;
  }

  Future<void> _ensureInit() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> init() async {
    await _ensureInit();
  }

  Future<User> login(String username, String password) async {
    await _ensureInit();

    debugPrint('DEBUG LOGIN: username=$username');
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/signin'),
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

    await _prefs!.setString(_tokenKey, token);
    await _prefs!.setString(_userKey, jsonEncode(user.toJson()));

    debugPrint('DEBUG LOGIN: token saved len=${token.length}');
    debugPrint('DEBUG LOGIN: user saved=${user.username}');

    return user;
  }

  Future<void> register(
    String username,
    String email,
    String password, {
    List<String>? roles,
  }) async {
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
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    debugPrint('DEBUG SIGNUP: status=${response.statusCode}');
    debugPrint('DEBUG SIGNUP: body=${_shorten(response.body)}');

    if (response.statusCode != 200) {
      throw Exception('No se pudo registrar (${response.statusCode}): ${response.body}');
    }
  }

  String? getToken() {
    if (_prefs == null) {
      return null;
    }
    return _prefs!.getString(_tokenKey);
  }

  User? getUser() {
    if (_prefs == null) {
      return null;
    }
    final userJson = _prefs!.getString(_userKey);
    if (userJson == null) {
      return null;
    }
    return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  bool isAuthenticated() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _ensureInit();
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_userKey);
    debugPrint('DEBUG LOGOUT: local session cleared');
  }

  void dispose() {
    _httpClient.close();
  }

  String _shorten(String text, [int max = 220]) {
    if (text.length <= max) {
      return text;
    }
    return '${text.substring(0, max)}...';
  }
}
