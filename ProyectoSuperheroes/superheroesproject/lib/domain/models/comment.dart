class Comment {
  final int id;
  final String content;
  final String authorUsername;
  final DateTime? createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.authorUsername,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // 🔍 Print para ver en tu consola qué llega exactamente
    print('DEBUG COMENTARIO: $json');
    
    String parsedUsername = 'Usuario';
    
    // Extracción profunda y segura del usuario
    if (json['user'] != null && json['user'] is Map) {
      parsedUsername = json['user']['username']?.toString() ?? 'Usuario';
    } else if (json['username'] != null) {
      parsedUsername = json['username'].toString();
    }

    return Comment(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      content: json['content']?.toString() ?? json['texto']?.toString() ?? '',
      authorUsername: parsedUsername,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }

  String get authorLabel {
    if (authorUsername.isEmpty || authorUsername == 'Usuario') {
      return 'Usuario';
    }
    return '@$authorUsername';
  }
}