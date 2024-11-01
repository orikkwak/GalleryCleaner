// 파일 위치: lib/bindings/main_content_binding.dart
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';

class MainContentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageController>(() => ImageController());
  }
}
