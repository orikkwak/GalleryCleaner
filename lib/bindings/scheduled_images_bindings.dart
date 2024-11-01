// 파일 위치: lib/bindings/scheduled_images_binding.dart

import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';

class ScheduledImagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageController>(() => ImageController());
  }
}
