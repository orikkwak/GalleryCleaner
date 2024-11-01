// 파일 위치: lib/bindings/category_detail_binding.dart
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';

class CategoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoryController>(() => CategoryController());
  }
}
