import 'package:get/get.dart';
import 'package:getlery_client/controllers/category_controller.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/image_controller.dart';
import 'package:getlery_client/controllers/set_controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageController>(() => ImageController());
    Get.lazyPut<GroupController>(() => GroupController());
    Get.lazyPut<CategoryController>(() => CategoryController());
    Get.lazyPut<SetController>(() => SetController());
  }
}
