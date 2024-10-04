import 'package:get/get.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/services/image_service.dart';

class DeleteController extends GetxController {
  final ImageController imageController = Get.find<ImageController>();
  final ImageService imageService = ImageService();

  RxBool isDeleting = false.obs;

  // 선택된 이미지 삭제
  Future<void> deleteSelectedPhotos() async {
    if (imageController.images.isEmpty) {
      Get.snackbar('Error', 'No photos selected');
      return;
    }

    isDeleting.value = true;

    try {
      for (var image in imageController.images) {
        await imageService.deleteImage(image.id);
      }

      imageController.images.clear(); // 삭제 후 선택된 사진 리스트 초기화
      Get.snackbar('Success', 'Selected photos deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete photos: $e');
    } finally {
      isDeleting.value = false;
    }
  }
}
