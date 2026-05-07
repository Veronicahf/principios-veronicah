import 'user.dart';

class Comment {
  final int id;
  final String content;
  final DateTime? createdAt;
  final User? user;

  const Comment({
    required this.id,
    required this.content,
    this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: _asInt(json['id']),
      content: json['content']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt']),
      user: _parseUser(json['user']),
    );
  }

  String get authorLabel {
    return user?.username ?? 'Usuario';
  }

  static User? _parseUser(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return User.fromJson(raw);
    }
    return null;
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
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