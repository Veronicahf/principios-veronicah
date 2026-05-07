class Reaction {
  final int id;
  final String description;

  const Reaction({required this.id, required this.description});

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: _asInt(json['id']),
      description: json['description']?.toString() ?? '',
    );
  }

  String get label {
    return description.replaceFirst('REACTION_', '').toLowerCase();
  }

  String get emoji {
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