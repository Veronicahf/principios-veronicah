/// [QUÉ ES]: Modal para visualizar y crear comentarios
/// [PARA QUÉ SIRVE]: Muestra lista de comentarios y permite agregar nuevos
/// [PATRÓN DE DISEÑO]: Facade (AppCoordinator) - Estructural
/// [RAZÓN Y UTILIDAD]: Usa AppCoordinator para operaciones de comentarios (SOLID - DIP)

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/facades/app_coordinator.dart';
import '../../domain/models/superheroe.dart';
import '../models/hero_interaction_data.dart';

class CommentsSheet extends StatefulWidget {
  final Superheroe hero;
  final HeroInteractionData data;
  final VoidCallback onRefresh;
  final VoidCallback onReload;

  const CommentsSheet({
    required this.hero,
    required this.data,
    required this.onRefresh,
    required this.onReload,
  });

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();
  final AppCoordinator _coordinator = AppCoordinator();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await _coordinator.createComment(widget.hero.id, content);
      _controller.clear();

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
