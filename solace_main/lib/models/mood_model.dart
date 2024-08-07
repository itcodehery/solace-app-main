class MoodModel {
  final int? id;
  final String? userMail;
  final DateTime? createdAt;
  final String? mood;
  final int? intensity;

  MoodModel({
    required this.id,
    required this.userMail,
    required this.createdAt,
    required this.mood,
    required this.intensity,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      id: json['id'] as int?,
      userMail: json['usermail'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      mood: json['mood'] as String?,
      intensity: json['intensity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usermail': userMail,
      'created_at': createdAt?.toIso8601String(),
      'mood': mood,
      'intensity': intensity,
    };
  }
}
