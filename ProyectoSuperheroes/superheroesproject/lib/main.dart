/// [QUÉ ES]: Punto de entrada de la aplicación
/// [PARA QUÉ SIRVE]: Configura tema, rutas e inicializa la app
/// [PATRÓN DE DISEÑO]: Facade (AppCoordinator) - Estructural
/// [RAZÓN Y UTILIDAD]: main.dart limpio, responsable solo de configuración (SOLID - SRP)

import 'package:flutter/material.dart';

import 'core/facades/app_coordinator.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final coordinator = AppCoordinator();
  await coordinator.initApp();
  runApp(const SuperHeroApp());
}

class SuperHeroApp extends StatelessWidget {
  const SuperHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heroes Registry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      home: const _AppHome(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const SuperHeroHomePage(),
      },
    );
  }
}

class _AppHome extends StatelessWidget {
  const _AppHome();

  @override
  Widget build(BuildContext context) {
    final coordinator = AppCoordinator();
    if (coordinator.isAuthenticated()) {
      return const SuperHeroHomePage();
    }
    return const LoginScreen();
  }
}
