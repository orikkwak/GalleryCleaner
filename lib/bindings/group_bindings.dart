// 파일 위치: lib/bindings/group_bindings.dart

import 'package:get/get.dart';
import 'package:getlery/controllers/group_controller.dart';

class GroupBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(GroupController()); // 그룹 컨트롤러 주입
  }
}
