class ResourceModel {
  final int id;
  final DateTime createdAt;
  final String resourceName;
  final String resourceUrl;
  final String resourceDescription;

  ResourceModel(
      {required this.id,
      required this.createdAt,
      required this.resourceName,
      required this.resourceUrl,
      required this.resourceDescription});

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at']),
      resourceName: json['resource_name'] as String,
      resourceUrl: json['link'] as String,
      resourceDescription: json['resource_desc'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'resource_name': resourceName,
      'link': resourceUrl,
      'resource_desc': resourceDescription,
    };
  }
}
