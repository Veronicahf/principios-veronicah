/// [QUÉ ES]: Constantes centralizadas de la aplicación
/// [PARA QUÉ SIRVE]: Centraliza URLs, colores, strings y configuraciones globales
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Facilita mantenimiento, cambios centralizados y evita magic strings/valores diseminados en el código (SOLID - SRP)

import 'package:flutter/material.dart';

// ============= COLORES =============
const Color kSkyBackground = Color(0xFFEAF7FF);
const Color kSkySurface = Color(0xFFFFFFFF);
const Color kSkyPrimary = Color(0xFF4DA3F7);
const Color kSkyPrimaryDark = Color(0xFF1E5FA8);
const Color kSkyAccent = Color(0xFF7CCBFF);

// ============= URLs DE API =============
class ApiConfig {
  static const String baseUrl = 'https://superheroes-api-iy4v.onrender.com/api';
  static const String authSignIn = '$baseUrl/auth/signin';
  static const String authSignUp = '$baseUrl/auth/signup';
  static const String superheroesAll = '$baseUrl/superheroes/all';
  static const String superheroes = '$baseUrl/superheroes';
  static const String reactions = '$baseUrl/reactions';
  static const String comments = '$baseUrl/comments';
}

// ============= CLAVES DE ALMACENAMIENTO LOCAL =============
class StorageKeys {
  static const String authToken = 'auth_token';
  static const String authUser = 'auth_user';
  static const String lastRefresh = 'last_refresh';
}

// ============= STRINGS =============
class AppStrings {
  static const String appTitle = 'Heroes Registry';
  static const String loginTitle = 'Login Superheroes';
  static const String heroesTitle = 'SUPERHEROES';
  static const String newHeroTitle = 'NUEVO HÉROE';
  static const String logoutLabel = 'Cerrar sesion';
  static const String errorConnection = 'Error de conexión';
  static const String errorUnauthorized = 'Debes iniciar sesion para ver esta sección';
}

// ============= TIMEOUT Y CONFIGURACIÓN =============
class AppConfig {
  static const Duration httpTimeout = Duration(seconds: 15);
  static const Duration cacheExpiration = Duration(minutes: 5);
  static const int maxRetries = 3;
}
