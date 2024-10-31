import 'image_model.dart';

class Category {
  String id;
  String label; // 분류에 사용되는 라벨명
  String name; // 사용자에게 보여지는 이름
  List<ImageModel> images; // ImageModel 리스트로 변경
  bool isCustomName;

  Category({
    required this.id,
    required this.label,
    required this.name,
    required this.images, // ImageModel 리스트로 변경
    this.isCustomName = false,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final label =
        json['label'] ?? json['name']; // 서버의 label 또는 name 필드에서 초기값을 가져옴
    final name = json['name'] ?? label; // name 초기값은 label에서 가져옴
    return Category(
      id: json['_id'],
      label: label,
      name: name,
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
