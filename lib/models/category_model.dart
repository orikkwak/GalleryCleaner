// Category 모델
import 'dart:io';

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

  // imageUrls를 File 객체로 변환하는 헬퍼 메서드
  List<File> get imageFiles => imageUrls.map((url) => File(url)).toList();
}
