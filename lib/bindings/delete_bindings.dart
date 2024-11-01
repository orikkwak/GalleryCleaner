// 파일 위치: lib/bindings/delete_scheduled_images_binding.dart
import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';

class DeleteScheduledImagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageController>(() => ImageController());
  }
}
