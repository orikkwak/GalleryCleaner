// lib/models/photo_model.dart

class Photo {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final DateTime createdAt;

  Photo({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
