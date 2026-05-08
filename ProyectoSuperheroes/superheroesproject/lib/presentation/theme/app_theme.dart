/// [QUÉ ES]: Configuración centralizada del tema de la aplicación
/// [PARA QUÉ SIRVE]: Define colores, estilos, tipografías y componentes UI
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Centraliza todo el estilo visual. SOLID - SRP: responsable solo de tema.

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AppTheme {
  static ThemeData buildTheme() {
    return ThemeData(
      scaffoldBackgroundColor: kSkyBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kSkyPrimary,
        brightness: Brightness.light,
        primary: kSkyPrimary,
        surface: kSkySurface,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: kSkyAccent,
        foregroundColor: kSkyPrimaryDark,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: kSkySurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB7E1FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB7E1FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kSkyPrimary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kSkyPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
