// getlery/lib/bindings/image_bindings.dart
import 'package:get/get.dart';
import 'package:getlery/controllers/image_controller.dart'; // 경로 변경
import 'package:getlery/repositories/image_repository.dart'; // 경로 변경

class ImageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageController());
    Get.lazyPut(() => ImageRepository());
  }
}
