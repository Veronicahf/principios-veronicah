/// [QUÉ ES]: Pantalla de registro de usuarios
/// [PARA QUÉ SIRVE]: Permite crear nuevas cuentas de usuario
/// [PATRÓN DE DISEÑO]: Facade (AppCoordinator) - Estructural
/// [RAZÓN Y UTILIDAD]: Usa AppCoordinator para registro simplificado (SOLID - DIP)

import 'package:flutter/material.dart';

import '../../core/facades/app_coordinator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AppCoordinator _coordinator = AppCoordinator();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _roleUser = true;
  bool _roleMod = false;
  bool _roleAdmin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roles = <String>[];
      if (_roleUser) roles.add('user');
      if (_roleMod) roles.add('mod');
      if (_roleAdmin) roles.add('admin');

      await _coordinator.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado. Ahora inicia sesion.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear usuario')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Usuario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Contrasena',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Roles (puedes seleccionar mas de uno):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('USER'),
                value: _roleUser,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _roleUser = value ?? false;
                        });
                      },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('MODERATOR (mod)'),
                value: _roleMod,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _roleMod = value ?? false;
                        });
                      },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('ADMIN'),
                value: _roleAdmin,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _roleAdmin = value ?? false;
                        });
                      },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
