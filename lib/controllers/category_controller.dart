import 'package:get/get.dart';
import 'package:getlery_client/services/category_service.dart';
import 'package:getlery_client/models/category_model.dart';

class CategoryController extends GetxController {
  final CategoryService categoryService = CategoryService();
  var categories = <Category>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  void fetchCategories() async {
    categories.value = await categoryService.fetchCategories();
  }

  void updateCategoryName(String id, String newName) async {
    await categoryService.updateCategoryName(id, newName);
    fetchCategories(); // 업데이트 후 새로고침
  }
}
