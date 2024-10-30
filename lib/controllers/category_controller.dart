// 파일 위치: lib/controllers/category_controller.dart

import 'package:get/get.dart';
import 'package:getlery_client/services/category_service.dart';
import 'package:getlery_client/models/category_model.dart';
import 'package:getlery_client/models/image_model.dart';

class CategoryController extends GetxController {
  final CategoryService categoryService = CategoryService();
  var categories = <Category>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  // 서버에서 카테고리 목록 가져오기
  void fetchCategories() async {
    categories.value = await categoryService.fetchCategories();
  }

  // 카테고리 이름 업데이트
  void updateCategoryName(String id, String newName) async {
    await categoryService.updateCategoryName(id, newName);
    fetchCategories();
  }

  // 카테고리에 이미지 추가
  Future<void> addImageToCategory(String categoryId, ImageModel image) async {
    await categoryService.addImageToCategory(categoryId, image.filePath);
    fetchCategories(); // UI 업데이트
  }
}
