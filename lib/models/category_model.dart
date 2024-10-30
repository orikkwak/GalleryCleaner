import 'image_model.dart';

class Category {
  String id;
  String name;
  List<ImageModel> images; // ImageModel 리스트로 변경
  bool isCustomName;

  Category({
    required this.id,
    required this.name,
    required this.images, // ImageModel 리스트로 변경
    this.isCustomName = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      name: json['name'],
      images: (json['images'] as List)
          .map((imageJson) => ImageModel.fromJson(imageJson))
          .toList(),
      isCustomName: json['isCustomName'] ?? false,
    );
  }

  // 이름을 업데이트하는 메서드
  void updateName(String newName) {
    name = newName;
    isCustomName = true;
  }
}
