import 'reaction.dart';
import 'user.dart';

class SuperheroeReaction {
  final int id;
  final int reactionId;
  final int userId;
  final int superheroeId;
  final Reaction? reaction;
  final User? user;

  const SuperheroeReaction({
    required this.id,
    required this.reactionId,
    required this.userId,
    required this.superheroeId,
    this.reaction,
    this.user,
  });

  factory SuperheroeReaction.fromJson(Map<String, dynamic> json) {
    return SuperheroeReaction(
      id: _asInt(json['id']),
      reactionId: _asInt(json['reactionId'] ?? json['reaction_id'] ?? json['reaction']?['id']),
      userId: _asInt(json['userId'] ?? json['user_id'] ?? json['user']?['id']),
      superheroeId: _asInt(json['superheroeId'] ?? json['superheroe_id'] ?? json['superheroe']?['id']),
      reaction: _parseReaction(json['reaction']),
      user: _parseUser(json['user']),
    );
  }

  String get reactionLabel {
    return reaction?.description ?? 'Sin reacción';
  }

  static Reaction? _parseReaction(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return Reaction.fromJson(raw);
    }
    return null;
  }

  static User? _parseUser(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return User.fromJson(raw);
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