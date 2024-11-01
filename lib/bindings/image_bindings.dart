// 파일 위치: lib/bindings/image_bindings.dart

import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/repositories/image_repository.dart';

class ImageBindings extends Bindings {
  @override
  void dependencies() {
    // ImageRepository를 주입
    Get.lazyPut<ImageRepository>(() => ImageRepository());
    Get.lazyPut<ImageController>(() => ImageController());
  }
}
