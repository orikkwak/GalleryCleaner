// 파일 위치: lib/bindings/group_bindings.dart

import 'package:get/get.dart';
import 'package:getlery_client/controllers/group_controller.dart';
import 'package:getlery_client/controllers/selection_controller.dart';
import 'package:getlery_client/repositories/group_repository.dart';

class GroupBindings extends Bindings {
  @override
  void dependencies() {
    // GroupController 및 SelectionController 주입
    // Get.lazyPut<GroupRepository>(() => GroupRepository());
    Get.lazyPut<GroupController>(() => GroupController());
    Get.lazyPut<SelectionController>(() => SelectionController());
  }
}
