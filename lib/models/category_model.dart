class Category {
  final String id;
  final String name;
  final List<String> imageUrls;
  bool isCustomName;

  Category({
    required this.id,
    required this.name,
    required this.imageUrls,
    this.isCustomName = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      imageUrls: List<String>.from(json['imageUrls']),
      isCustomName: json['isCustomName'] ?? false,
    );
  }
}
