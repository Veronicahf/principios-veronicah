/// [QUÉ ES]: Tarjeta visual que representa un superhéroe con interacciones
/// [PARA QUÉ SIRVE]: Muestra detalles, reacciones y comentarios de un superhéroe
/// [PATRÓN DE DISEÑO]: Facade (AppCoordinator) - Estructural
/// [RAZÓN Y UTILIDAD]: Usa AppCoordinator para operaciones complejas (SOLID - DIP)

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/facades/app_coordinator.dart';
import '../../domain/models/comment.dart';
import '../../domain/models/reaction.dart';
import '../../domain/models/superheroe.dart';
import '../../domain/models/superheroe_reaction.dart';
import '../models/hero_interaction_data.dart';
import 'comments_sheet.dart';

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
  final AppCoordinator _coordinator = AppCoordinator();

  late Future<HeroInteractionData> _interactionFuture;

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

  Future<HeroInteractionData> _loadInteractions() async {
    try {
      print('🔄 Cargando interacciones para superhéroe ${widget.hero.id}...');

      final availableReactions = await _coordinator.getAvailableReactions();
      print('✅ Reacciones disponibles cargadas: ${availableReactions.length}');

      final reactions = await _coordinator.getReactionsForSuperheroe(widget.hero.id);
      print('✅ Reacciones del superhéroe cargadas: ${reactions.length}');

      final comments = await _coordinator.getCommentsForSuperheroe(widget.hero.id);
      print('✅ Comentarios cargados: ${comments.length}');

      final currentReaction = await _coordinator.getCurrentUserReaction(widget.hero.id);
      print('✅ Reacción del usuario: ${currentReaction?.reaction?.description ?? "Sin reacción"}');

      final counts = <String, int>{};
      for (final reaction in availableReactions) {
        if (reactions is List<SuperheroeReaction>) {
          counts[reaction.description] =
              reactions.where((item) => item.reaction?.description == reaction.description).length;
        }
      }

      return HeroInteractionData(
        availableReactions: availableReactions,
        reactions: reactions is List<SuperheroeReaction> ? reactions : [],
        comments: comments is List<Comment> ? comments : [],
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
    final currentUser = _coordinator.getCurrentUser();
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
    final currentUser = _coordinator.getCurrentUser();
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

  Future<void> _openCommentsSheet(BuildContext context, HeroInteractionData data) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5FBFF),
      builder: (context) {
        return CommentsSheet(
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
        return FutureBuilder<HeroInteractionData>(
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
                    const Text('Elegir reacción',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              Text(reaction.getEmoji(), style: const TextStyle(fontSize: 32)),
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
      await _coordinator.addReaction(widget.hero.id, selectedReactionId);
      widget.onRefresh();
      _reloadInteractions();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  Future<void> _showReactionsModal(BuildContext context, HeroInteractionData data) async {
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
                        text: '${reaction.getEmoji()} $count',
                      );
                    }).toList(),
                    labelColor: kSkyPrimary,
                    unselectedLabelColor: Colors.grey,
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: data.availableReactions.map((reaction) {
                      final reactorsForThisType =
                          data.reactions.where((r) => r.reaction?.description == reaction.description).toList();

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
                                    reaction.getEmoji(),
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

  Widget _buildReactionBar(BuildContext context, HeroInteractionData data) {
    final totalReactions = data.reactions.length;
    if (totalReactions == 0) {
      return const SizedBox.shrink();
    }

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
                        Text(reaction.getEmoji(), style: const TextStyle(fontSize: 16)),
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
            child: FutureBuilder<HeroInteractionData>(
              future: _interactionFuture,
              builder: (context, snapshot) {
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
                              color: canDelete ? Colors.redAccent : Colors.redAccent.withAlpha(179),
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
                          const Divider(color: Color(0xFFD6E8F5), height: 16),
                          _infoRow(Icons.bolt, 'Habilidades', widget.hero.habilidades),
                          _infoRow(Icons.priority_high, 'Debilidades', widget.hero.debilidades),
                          _infoRow(Icons.group_off, 'Enemigos', widget.hero.enemigos),
                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFD6E8F5), height: 16),
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
                                          ? Border.all(color: Colors.red.withAlpha(128))
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
                                            interactionData!.currentUserReaction!.reaction?.getEmoji() ?? '👌',
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
                                          ? Border.all(color: Colors.red.withAlpha(128))
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

