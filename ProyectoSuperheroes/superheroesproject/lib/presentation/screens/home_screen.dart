/// [QUÉ ES]: Pantalla principal que lista superhéroes
/// [PARA QUÉ SIRVE]: Muestra lista de superhéroes y permite CRUD
/// [PATRÓN DE DISEÑO]: Facade (AppCoordinator) - Estructural
/// [RAZÓN Y UTILIDAD]: Usa AppCoordinator para acceso simplificado a servicios (SOLID - DIP)

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/facades/app_coordinator.dart';
import '../../domain/models/superheroe.dart';
import '../widgets/superhero_card.dart';

class SuperHeroHomePage extends StatefulWidget {
  const SuperHeroHomePage({super.key});

  @override
  State<SuperHeroHomePage> createState() => _SuperHeroHomePageState();
}

class _SuperHeroHomePageState extends State<SuperHeroHomePage> {
  late Future<List<Superheroe>> _heroesFuture;
  final AppCoordinator _coordinator = AppCoordinator();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _heroesFuture = _coordinator.getAllSuperheroes();
    });
  }

  Future<void> _logout() async {
    await _coordinator.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _openForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5FBFF),
      builder: (context) => _HeroForm(onSave: _refresh),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSkyBackground,
      appBar: AppBar(
        title: const Text(
          'SUPERHEROES',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: kSkyPrimaryDark),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Cerrar sesion'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Superheroe>>(
        future: _heroesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error de conexión', style: TextStyle(color: kSkyPrimaryDark)),
            );
          }

          final heroes = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: heroes.length,
            itemBuilder: (context, i) => _buildHeroCard(heroes[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        backgroundColor: kSkyPrimary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeroCard(Superheroe hero) {
    return SuperHeroCard(
      hero: hero,
      onDelete: _delete,
      onRefresh: _refresh,
    );
  }

  Future<void> _delete(int id) async {
    try {
      await _coordinator.deleteSuperheroe(id);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }
}

/// Modal para crear nuevo superhéroe
class _HeroForm extends StatefulWidget {
  final VoidCallback onSave;

  const _HeroForm({required this.onSave});

  @override
  State<_HeroForm> createState() => _HeroFormState();
}

class _HeroFormState extends State<_HeroForm> {
  final _nC = TextEditingController();
  final _hC = TextEditingController();
  final _dC = TextEditingController();
  final _eC = TextEditingController();
  final _fC = TextEditingController();
  bool _loading = false;

  final AppCoordinator _coordinator = AppCoordinator();

  @override
  void dispose() {
    _nC.dispose();
    _hC.dispose();
    _dC.dispose();
    _eC.dispose();
    _fC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'NUEVO HÉROE',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSkyPrimaryDark),
          ),
          const SizedBox(height: 20),
          _input(_nC, 'Nombre'),
          _input(_hC, 'Habilidades'),
          _input(_dC, 'Debilidades'),
          _input(_eC, 'Enemigos'),
          _input(_fC, 'URL Foto'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kSkyPrimary),
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('GUARDAR', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await _coordinator.createSuperheroe(
        Superheroe(
          id: 0,
          nombre: _nC.text,
          habilidades: _hC.text,
          debilidades: _dC.text,
          enemigos: _eC.text,
          urlPhoto: _fC.text,
        ),
      );
      widget.onSave();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
