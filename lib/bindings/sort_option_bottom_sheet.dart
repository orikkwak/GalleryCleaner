import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';

class SortOptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageController>(() => ImageController());
    Get.lazyPut<GroupController>(() => GroupController());
  }
}
