class SocialPost {
  final String? id;
  final DateTime? createdAt;
  final String? userId;
  final String? title;
  final String? content;
  final String? tags;

  SocialPost(
      {this.id,
      this.createdAt,
      required this.userId,
      required this.title,
      required this.content,
      required this.tags});

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: json['tags'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'tags': tags,
    };
  }

  //to String
  @override
  String toString() {
    return 'SocialPost{userId: $userId, title: $title, content: $content, tags: $tags}';
  }
}
