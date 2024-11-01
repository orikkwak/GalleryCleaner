// 파일 위치: lib/bindings/group_grid_binding.dart
import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';

class GroupGridBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupController>(() => GroupController());
  }
}
