import 'superheroe.dart';

class SuperheroeResponse {
  final List<Superheroe> content;

  SuperheroeResponse({required this.content});

  factory SuperheroeResponse.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return SuperheroeResponse(
      content: contentList
          .map((item) => Superheroe.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}