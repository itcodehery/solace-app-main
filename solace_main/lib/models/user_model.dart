class UserModel {
  final String? id;
  final DateTime? createdAt;
  final String? username;
  final String? email;
  final String? bio;
  final DateTime? moodLastChecked;
  final String? favoritesList;

  UserModel(
      {required this.id,
      required this.createdAt,
      required this.username,
      required this.email,
      required this.bio,
      required this.moodLastChecked,
      required this.favoritesList});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      favoritesList: json['favorites_list'] as String,
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      username: json['user_name'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String,
      moodLastChecked: DateTime.parse(json['mood_last_checked'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt!.toIso8601String(),
      'user_name': username,
      'email': email,
      'bio': bio,
      'mood_last_checked': moodLastChecked,
      'favorites_list': favoritesList,
    };
  }
}
