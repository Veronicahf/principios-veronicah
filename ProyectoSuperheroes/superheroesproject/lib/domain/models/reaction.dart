/// [QUÉ ES]: Modelo de dominio que representa una Reacción
/// [PARA QUÉ SIRVE]: Encapsula datos y comportamiento de reacciones (likes, loves, etc.)
/// [PATRÓN DE DISEÑO]: -
/// [RAZÓN Y UTILIDAD]: Modelo puro de negocio con comportamiento relacionado (emoji, label)

class Reaction {
  final int id;
  final String description;
  final String? emoji;

  const Reaction({
    required this.id,
    required this.description,
    this.emoji,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: _asInt(json['id']),
      description: json['description']?.toString() ?? '',
      emoji: json['emoji']?.toString(),
    );
  }

  String get label {
    return description.replaceFirst('REACTION_', '').toLowerCase();
  }

  String getEmoji() {
    if (emoji != null && emoji!.isNotEmpty) {
      return emoji!;
    }

    switch (description.toUpperCase()) {
      case 'REACTION_LIKE':
        return '👍';
      case 'REACTION_LOVE':
        return '❤️';
      case 'REACTION_HATE':
        return '😠';
      case 'REACTION_SAD':
        return '😢';
      case 'REACTION_ANGRY':
        return '🔥';
      default:
        return '👌';
    }
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
