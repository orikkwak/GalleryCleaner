// 파일 위치: lib/bindings/category_binding.dart
import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    // CategoryController와 관련된 서비스 주입
    Get.lazyPut<CategoryController>(() => CategoryController());
    // Get.lazyPut<CategoryService>(() => CategoryService());
  }
}
