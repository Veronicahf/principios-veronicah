import 'package:flutter/material.dart';

import 'models/comment.dart';
import 'models/reaction.dart';
import 'models/superheroe.dart';
import 'models/superheroe_reaction.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'services/auth_service.dart';
import 'services/comment_service.dart';
import 'services/reaction_service.dart';
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

  Widget _buildHeroCard(Superheroe hero) {
    return SuperHeroCard(
      hero: hero,
      onDelete: _delete,
      onRefresh: _refresh,
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

class SuperHeroCard extends StatefulWidget {
  final Superheroe hero;
  final Future<void> Function(int id) onDelete;
  final VoidCallback onRefresh;

  const SuperHeroCard({
    super.key,
    required this.hero,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<SuperHeroCard> createState() => _SuperHeroCardState();
}

class _SuperHeroCardState extends State<SuperHeroCard> {
  final AuthService _authService = AuthService();
  final ReactionService _reactionService = ReactionService();
  final CommentService _commentService = CommentService();

  late Future<_HeroInteractionData> _interactionFuture;

  @override
  void initState() {
    super.initState();
    _reloadInteractions();
  }

  void _reloadInteractions() {
    _interactionFuture = _loadInteractions();
    if (mounted) {
      setState(() {});
    }
  }

  Future<_HeroInteractionData> _loadInteractions() async {
    try {
      print('🔄 Cargando interacciones para superhéroe ${widget.hero.id}...');
      
      final availableReactions = await _reactionService.fetchAvailableReactions();
      print('✅ Reacciones disponibles cargadas: ${availableReactions.length}');
      
      final reactions = await _reactionService.fetchReactionsBySuperheroe(widget.hero.id);
      print('✅ Reacciones del superhéroe cargadas: ${reactions.length}');
      
      final comments = await _commentService.fetchCommentsBySuperheroe(widget.hero.id);
      print('✅ Comentarios cargados: ${comments.length}');
      
      final currentReaction = await _reactionService.getCurrentUserReaction(widget.hero.id);
      print('✅ Reacción del usuario: ${currentReaction?.reaction?.description ?? "Sin reacción"}');

      final counts = <String, int>{};
      for (final reaction in availableReactions) {
        counts[reaction.description] = reactions
            .where((item) => item.reaction?.description == reaction.description)
            .length;
      }

      return _HeroInteractionData(
        availableReactions: availableReactions,
        reactions: reactions,
        comments: comments,
        reactionCounts: counts,
        currentUserReaction: currentReaction,
      );
    } catch (e, stackTrace) {
      print('❌ Error en _loadInteractions: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
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

Future<void> _openCommentsSheet(BuildContext context, _HeroInteractionData data) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5FBFF),
      builder: (context) {
        // Ahora llamamos a un widget independiente que maneja su propio estado
        return _CommentsSheet(
          hero: widget.hero,
          data: data,
          onRefresh: widget.onRefresh,
          onReload: _reloadInteractions,
        );
      },
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

  Future<void> _showReactionSelector(BuildContext context) async {
    final selectedReactionId = await showDialog<int>(
      context: context,
      builder: (context) {
        return FutureBuilder<_HeroInteractionData>(
          future: _interactionFuture,
          builder: (context, snapshot) {
            final reactions = snapshot.data?.availableReactions ?? const <Reaction>[];
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Elegir reacción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: reactions.map((reaction) {
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pop(reaction.id),
                          child: Column(
                            children: [
                              Text(reaction.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 4),
                              Text(
                                reaction.label,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (selectedReactionId == null) {
      return;
    }

    try {
      await _reactionService.createOrUpdateReaction(widget.hero.id, selectedReactionId);
      widget.onRefresh();
      _reloadInteractions();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _showReactionsModal(BuildContext context, _HeroInteractionData data) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5FBFF),
      builder: (context) {
        return DefaultTabController(
          length: data.availableReactions.length,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Color(0xFFD6E8F5))),
                  ),
                  child: TabBar(
                    tabs: data.availableReactions.map((reaction) {
                      final count = data.reactionCounts[reaction.description] ?? 0;
                      return Tab(
                        text: '${reaction.emoji} $count',
                      );
                    }).toList(),
                    labelColor: kSkyPrimary,
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: data.availableReactions.map((reaction) {
                      final reactorsForThisType = data.reactions
                          .where((r) => r.reaction?.description == reaction.description)
                          .toList();

                      return reactorsForThisType.isEmpty
                          ? const Center(child: Text('Sin reacciones de este tipo'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: reactorsForThisType.length,
                              itemBuilder: (context, index) {
                                final reactor = reactorsForThisType[index];
                                return ListTile(
                                  leading: const Icon(Icons.person, color: kSkyPrimaryDark),
                                  title: Text(reactor.user?.username ?? 'Usuario'),
                                  trailing: Text(
                                    reaction.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                );
                              },
                            );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return 'Hace unos segundos';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} h';
    } else {
      return 'Hace ${diff.inDays} d';
    }
  }

  Widget _buildReactionBar(BuildContext context, _HeroInteractionData data) {
    final totalReactions = data.reactions.length;
    if (totalReactions == 0) {
      return const SizedBox.shrink();
    }

    // Agrupar por tipo de reacción y contar
    final reactionGroups = <String, List<SuperheroeReaction>>{};
    for (final reaction in data.reactions) {
      final key = reaction.reaction?.description ?? 'UNKNOWN';
      reactionGroups.putIfAbsent(key, () => []).add(reaction);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ...reactionGroups.entries.map((entry) {
              final reaction = data.availableReactions.firstWhere(
                (r) => r.description == entry.key,
                orElse: () => const Reaction(id: 0, description: 'UNKNOWN'),
              );
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _showReactionsModal(context, data),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7FF),
                      border: Border.all(color: const Color(0xFFB7E1FF)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text(reaction.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.value.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isMine = _isMine(widget.hero);
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMine ? const Color(0xFFD6F0FF) : Colors.white;
    final borderColor = isMine ? const Color(0xFF8ED0FF) : const Color(0xFFD6E8F5);
    final canDelete = _canDeleteHero(widget.hero);

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
            child: FutureBuilder<_HeroInteractionData>(
              future: _interactionFuture,
              builder: (context, snapshot) {
                // Debug: Log estado
                if (snapshot.hasError) {
                  print('Error en FutureBuilder: ${snapshot.error}');
                }
                
                final interactionData = snapshot.data;
                return Column(
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
                                  widget.hero.nombre.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: kSkyPrimaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _authorLabel(widget.hero),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // Mostrar estado de carga si está en progreso
                                if (snapshot.connectionState == ConnectionState.waiting)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Cargando...',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                // Mostrar error si ocurrió
                                if (snapshot.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                            onPressed: () => widget.onDelete(widget.hero.id),
                          ),
                        ],
                      ),
                    ),
                    if (widget.hero.urlPhoto.trim().isNotEmpty)
                      Image.network(
                        widget.hero.urlPhoto,
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
                          if (interactionData != null) ...[
                            _buildReactionBar(context, interactionData),
                          ] else
                            const SizedBox(height: 8),

                          // Divisor
                          const Divider(color: Color(0xFFD6E8F5), height: 16),

                          // Información del superhéroe
                          _infoRow(Icons.bolt, 'Habilidades', widget.hero.habilidades),
                          _infoRow(Icons.priority_high, 'Debilidades', widget.hero.debilidades),
                          _infoRow(Icons.group_off, 'Enemigos', widget.hero.enemigos),
                          const SizedBox(height: 12),

                          // Divisor antes de botones
                          const Divider(color: Color(0xFFD6E8F5), height: 16),

                          // Botones de interacción tipo Facebook
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _showReactionSelector(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF7FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: snapshot.hasError
                                          ? Border.all(color: Colors.red.withValues(alpha: 0.5))
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (snapshot.hasError)
                                          const Tooltip(
                                            message: 'Error cargando reacciones',
                                            child: Icon(Icons.error_outline, size: 18, color: Colors.red),
                                          )
                                        else if (interactionData?.currentUserReaction != null)
                                          Text(
                                            interactionData!.currentUserReaction!.reaction?.emoji ?? '👌',
                                            style: const TextStyle(fontSize: 18),
                                          )
                                        else
                                          const Icon(Icons.emoji_emotions_outlined, size: 18, color: kSkyPrimary),
                                        const SizedBox(width: 6),
                                        Text(
                                          interactionData?.currentUserReaction != null
                                              ? 'Cambiar'
                                              : snapshot.hasError
                                                  ? 'Reintentar'
                                                  : 'Reaccionar',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: snapshot.hasError
                                      ? () => _reloadInteractions()
                                      : interactionData == null
                                          ? null
                                          : () => _openCommentsSheet(context, interactionData),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF7FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: snapshot.hasError
                                          ? Border.all(color: Colors.red.withValues(alpha: 0.5))
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (snapshot.hasError)
                                          const Tooltip(
                                            message: 'Error cargando comentarios',
                                            child: Icon(Icons.error_outline, size: 18, color: Colors.red),
                                          )
                                        else
                                          const Icon(Icons.mode_comment_outlined, size: 18, color: kSkyPrimary),
                                        const SizedBox(width: 6),
                                        Text(
                                          snapshot.hasError
                                              ? 'Reintentar'
                                              : '${interactionData?.comments.length ?? 0}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroInteractionData {
  final List<Reaction> availableReactions;
  final List<SuperheroeReaction> reactions;
  final List<Comment> comments;
  final Map<String, int> reactionCounts;
  final SuperheroeReaction? currentUserReaction;

  const _HeroInteractionData({
    required this.availableReactions,
    required this.reactions,
    required this.comments,
    required this.reactionCounts,
    required this.currentUserReaction,
  });
}
class _CommentsSheet extends StatefulWidget {
  final Superheroe hero;
  final _HeroInteractionData data;
  final VoidCallback onRefresh;
  final VoidCallback onReload;

  const _CommentsSheet({
    required this.hero,
    required this.data,
    required this.onRefresh,
    required this.onReload,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _controller = TextEditingController();
  final CommentService _commentService = CommentService();
  bool _sending = false;

  @override
  void dispose() {
    // Aquí el controlador se destruye de forma segura SOLO cuando 
    // el modal termina por completo su animación y desaparece.
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);
    
    try {
      await _commentService.createComment(widget.hero.id, content);
      _controller.clear();
      
      // Actualizamos los datos antes de cerrar
      widget.onRefresh();
      widget.onReload();
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      // Solo quitamos el loader si falló, para que el usuario pueda reintentar
      setState(() => _sending = false);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Hace unos segundos';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comentarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSkyPrimaryDark),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: widget.data.comments.isEmpty
                  ? const Center(child: Text('Todavía no hay comentarios'))
                  : ListView.separated(
                      itemCount: widget.data.comments.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final comment = widget.data.comments[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD6E8F5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.authorLabel,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              if (comment.createdAt != null)
                                Text(
                                  _formatDate(comment.createdAt!),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              const SizedBox(height: 6),
                              Text(comment.content, style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe un comentario...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : _submitComment,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publicar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}