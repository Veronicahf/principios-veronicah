import '../models/reaction.dart';
import '../models/superheroe_reaction.dart';

abstract class IReactionRepository {
  Future<List<Reaction>> fetchAvailableReactions();
  Future<List<SuperheroeReaction>> fetchReactionsBySuperheroe(int superheroeId);
  Future<SuperheroeReaction> createOrUpdateReaction(int superheroeId, int reactionId);
  Future<void> removeMyReaction(int superheroeId);
  void dispose();
}