import 'package:get/get.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';

class DeleteDialogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageController>(() => ImageController());
    Get.lazyPut<SelectionController>(() => SelectionController());
  }
}
