// // lib/controllers/delete_controller.dart
// import 'package:get/get.dart';
// class DeleteController extends GetxController {
//   RxBool isLoading = false.obs;
//   @override
//   void onInit() {
//     super.onInit();
//     _getData();
//   }
//   void onRefresh() {
//     _getData();
//   }
//   Future<void> _getData() async {
//     isLoading(true);
//     // 데이터 로딩 로직
//     isLoading(false);
//   }
// }

// getlery/lib/controllers/delete_controller.dart
import 'package:get/get.dart';
import 'package:getlery/controllers/image_controller.dart';
import 'package:getlery/services/photo_service.dart';

class DeleteController extends GetxController {
  final ImageController imageController = Get.find<ImageController>();
  final PhotoService photoService = Get.find<PhotoService>();

  RxBool isDeleting = false.obs;

  Future<void> deleteSelectedPhotos() async {
    isDeleting.value = true;
    await photoService.deletePhotos(imageController.selectedPhotos);
    imageController.selectedItems.clear();
    isDeleting.value = false;
    Get.snackbar('Success', 'Selected photos deleted');
  }
}
