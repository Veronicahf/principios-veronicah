import 'package:flutter/material.dart';

import 'models/superheroe.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_service.dart';
import 'services/superheroe_service.dart';

const Color kSkyBackground = Color(0xFFEAF7FF);
const Color kSkySurface = Color(0xFFFFFFFF);
const Color kSkyPrimary = Color(0xFF4DA3F7);
const Color kSkyPrimaryDark = Color(0xFF1E5FA8);
const Color kSkyAccent = Color(0xFF7CCBFF);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(const SuperHeroApp());
}

class SuperHeroApp extends StatelessWidget {
  const SuperHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heroes Registry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
      ),
      home: _buildHome(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const SuperHeroHomePage(),
      },
    );
  }

  Widget _buildHome() {
    final authService = AuthService();
    if (authService.isAuthenticated()) {
      return const SuperHeroHomePage();
    }
    return const LoginScreen();
  }
}

class SuperHeroHomePage extends StatefulWidget {
  const SuperHeroHomePage({super.key});

  @override
  State<SuperHeroHomePage> createState() => _SuperHeroHomePageState();
}

class _SuperHeroHomePageState extends State<SuperHeroHomePage> {
  final AuthService _authService = AuthService();
  final SuperheroeService _service = SuperheroeService();
  late Future<List<Superheroe>> _heroesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _heroesFuture = _service.fetchSuperheroes();
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
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

  bool _canDeleteHero(Superheroe hero) {
    final currentUser = _authService.getUser();
    if (currentUser == null) {
      return false;
    }

    final roles = currentUser.roles;
    if (roles.contains('ROLE_ADMIN') || roles.contains('ROLE_MODERATOR')) {
      return true;
    }

    return hero.postedByUsername.isNotEmpty && hero.postedByUsername == currentUser.username;
  }

  bool _isMine(Superheroe hero) {
    final currentUser = _authService.getUser();
    if (currentUser == null) {
      return false;
    }
    return hero.postedByUsername.isNotEmpty && hero.postedByUsername == currentUser.username;
  }

  String _authorLabel(Superheroe hero) {
    if (hero.postedByUsername.isEmpty) {
      return 'Autor desconocido';
    }
    return '@${hero.postedByUsername}';
  }

  Widget _buildHeroCard(Superheroe hero) {
    final isMine = _isMine(hero);
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMine ? const Color(0xFFD6F0FF) : Colors.white;
    final borderColor = isMine ? const Color(0xFF8ED0FF) : const Color(0xFFD6E8F5);
    final canDelete = _canDeleteHero(hero);

    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: 0.88,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(isMine ? 22 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 22),
            ),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(isMine ? 22 : 6),
              bottomRight: Radius.circular(isMine ? 6 : 22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF7FF),
                    border: Border(bottom: BorderSide(color: Color(0xFFD6E8F5))),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hero.nombre.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: kSkyPrimaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _authorLabel(hero),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_sweep,
                          color: canDelete
                              ? Colors.redAccent
                              : Colors.redAccent.withValues(alpha: 0.7),
                        ),
                        tooltip: canDelete ? 'Eliminar publicación' : 'No eres el propietario',
                        onPressed: () => _delete(hero.id),
                      ),
                    ],
                  ),
                ),
                if (hero.urlPhoto.trim().isNotEmpty)
                  Image.network(
                    hero.urlPhoto,
                    height: 240,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      width: double.infinity,
                      color: const Color(0xFFE0F3FF),
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: kSkyPrimaryDark),
                    ),
                  )
                else
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: const Color(0xFFE0F3FF),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, size: 50, color: kSkyPrimaryDark),
                        SizedBox(height: 8),
                        Text(
                          'Sin imagen',
                          style: TextStyle(color: kSkyPrimaryDark, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isMine)
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.chat_bubble_outline, size: 18, color: kSkyPrimaryDark),
                        ),
                      const SizedBox(height: 8),
                      const Divider(color: Color(0xFFD6E8F5)),
                      _infoRow(Icons.bolt, 'Habilidades', hero.habilidades),
                      _infoRow(Icons.priority_high, 'Debilidades', hero.debilidades),
                      _infoRow(Icons.group_off, 'Enemigos', hero.enemigos),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kSkyPrimaryDark),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Future<void> _delete(int id) async {
    try {
      await _service.deleteSuperheroe(id);
      _refresh();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }
}

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
      await SuperheroeService().createSuperheroe(
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
      if (!mounted) {
        return;
      }
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