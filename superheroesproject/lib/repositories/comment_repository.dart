import '../models/comment.dart';

abstract class ICommentRepository {
  Future<List<Comment>> fetchCommentsBySuperheroe(int superheroeId);
  Future<Comment> createComment(int superheroeId, String content);
  Future<int> countCommentsBySuperheroe(int superheroeId);
  void dispose();
}